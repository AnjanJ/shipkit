#!/usr/bin/env python3
"""prop.py: five properties of spec-check.sh and brief.sh, checked on generated specs.

Both scripts read a spec's task list with their own awk, and every smoke check feeds them
inputs a person thought of. This script feeds them inputs nobody wrote: Hypothesis generates
a spec.md and a tasks.md in the documented form, and each property below must hold on all of
them. The inputs are the same on every run (derandomize, no example database), so a red run
means the scripts changed. They are the same only for one version of Hypothesis and of Python:
a failure is repeated from the files it prints, on any machine.

    uv run --with hypothesis==6.170.16 python3 scripts/prop.py
    python3 scripts/prop.py                       where Hypothesis is installed (CI)

    --only <name>          one property: agreement, no-side-effect, monotone, exactly-one,
                           round-trip
    --max-examples <n>     inputs for each property (40)
    --no-shrink            report the first failing input as found, not the smallest
    --spec-check <path>    the spec-check.sh to test (this checkout's)
    --brief <path>         the brief.sh to test (this checkout's)

Exit status: 0 every property holds; 1 one does not, and its input is printed; 2 Hypothesis
cannot be imported, or wrong usage. It writes only under one temporary directory, which it
removes, and starts no model. Spec: .shipkit/specs/tests-worth-having/ (design.md, "What
prop.py generates").
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile

HYPOTHESIS = "6.170.16"

try:
    import hypothesis
    import hypothesis.configuration
    from hypothesis import HealthCheck, Phase, Verbosity, given, settings
    from hypothesis import strategies as st
except ImportError:
    sys.stderr.write("prop: Hypothesis is not installed. Run it as: "
                     "uv run --with hypothesis==%s python3 scripts/prop.py\n" % HYPOTHESIS)
    sys.exit(2)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRIPTS = os.path.join(ROOT, "plugins", "shipkit", "scripts")
SPEC_CHECK = os.path.join(SCRIPTS, "spec-check.sh")
BRIEF = os.path.join(SCRIPTS, "brief.sh")
WORK = None       # the one temporary directory; set in main()
SERIAL = [0]      # each input gets a directory of its own under WORK


# ---- what is generated -------------------------------------------------------------------

ALPHABET = ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
            ".,;:'\"()[]{}<>/\\|!?*_`~@#$%^&=+-" "éß→")
# A line of text: something in it besides spaces, and none of the marks the format reads.
LINE = st.text(alphabet=st.sampled_from(ALPHABET), min_size=1, max_size=24).filter(
    lambda s: s.strip(" ") and "REQ-" not in s and "[untested:" not in s)
SLUG = st.from_regex(r"[a-z][a-z0-9-]{0,11}", fullmatch=True)
NAME = st.from_regex(r"[A-Za-z0-9_][A-Za-z0-9._/-]{0,11}", fullmatch=True)


class Case:
    """One generated project: a spec, its task list and the lines that cite it."""

    def __init__(self, slug, status, reqs, tasks, cited):
        self.slug, self.status, self.reqs, self.tasks = slug, status, reqs, tasks
        self.cited = list(cited)   # requirement numbers, one citation line each

    def spec_text(self):
        out = ["# Spec: %s" % self.slug, "", "> Spec accepted at commit `abc1234` on main.",
               "> Status: %s" % self.status, "", "## Purpose", "A generated spec.", "",
               "## Requirements (EARS)"]
        for r in self.reqs:
            out.extend(r["before"])
            out.extend(r["block"])
        out.extend(["", "## Out of scope", "Nothing."])
        return "\n".join(out) + "\n"

    def tasks_text(self):
        out = ["# Tasks: %s" % self.slug, ""]
        for t in self.tasks:
            out.append("- [%s] **%s** %s → %s" % (
                t["tick"], t["id"], t["title"], ", ".join("REQ-%d" % n for n in t["cites"])))
            files = t["sep"].join(("`%s`" % f) if q else f for f, q in t["files"])
            for label, text in (("Files", files), ("Test", t["test"]), ("After", "none"),
                                ("Done when", t["done"])):
                out.append("%s- %s: %s" % (t["indent"], label, text))
        return "\n".join(out) + "\n"

    def cites_text(self):
        return "".join("# %s/REQ-%d\n" % (self.slug, n) for n in self.cited)

    def files(self):
        d = ".shipkit/specs/%s/" % self.slug
        return [(d + "spec.md", self.spec_text()), (d + "tasks.md", self.tasks_text()),
                ("tests/test_gen.py", self.cites_text())]

    def write(self):
        SERIAL[0] += 1
        proj = os.path.join(WORK, "p%d" % SERIAL[0])
        for rel, text in self.files():
            path = os.path.join(proj, rel)
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8", newline="") as f:
                f.write(text)
        return proj

    def show(self):
        return "".join("--- %s\n%s" % (rel, text) for rel, text in self.files())


@st.composite
def requirements(draw):
    reqs = []
    for n in range(1, draw(st.integers(1, 6)) + 1):
        lines = draw(st.lists(LINE, min_size=1, max_size=3))
        block = ["- **REQ-%d.** %s" % (n, lines[0])] + ["  " + more for more in lines[1:]]
        waived = draw(st.booleans())
        if waived:
            if draw(st.booleans()):
                block[-1] += " [untested: prose, read by hand]"
            else:
                block.append("  [untested: prose, read by hand]")
        # What stands between this requirement and the one before: nothing, a blank line, or a
        # heading. Each of the three ends a requirement's text.
        before = [] if n == 1 else draw(st.sampled_from([[], [""], ["### More"], ["", "### More", ""]]))
        reqs.append({"n": n, "block": block, "waived": waived, "before": before})
    return reqs


@st.composite
def task_lists(draw, reqs, union_last):
    numbers = [r["n"] for r in reqs]
    pool = draw(st.lists(NAME, min_size=1, max_size=6, unique=True))
    tasks = []
    for i in range(1, draw(st.integers(1, 4 if union_last else 5)) + 1):
        names = draw(st.lists(st.sampled_from(pool), min_size=1, max_size=3, unique=True))
        tasks.append({
            "id": "T%d" % i, "tick": draw(st.sampled_from(" xX")), "title": draw(LINE),
            "cites": draw(st.lists(st.sampled_from(numbers), min_size=1, max_size=2, unique=True)),
            "files": [(f, draw(st.booleans())) for f in names],
            "sep": draw(st.sampled_from([", ", ",", " , "])),
            "indent": draw(st.sampled_from(["  ", "    ", "\t"])),
            "test": draw(LINE), "done": draw(LINE)})
    if union_last:   # every name any task lists, so that every task's every file is shared
        seen = []
        for t in tasks:
            seen.extend(f for f, _ in t["files"] if f not in seen)
        tasks.append({"id": "T%d" % (len(tasks) + 1), "tick": " ", "title": "everything",
                      "cites": [numbers[0]], "files": [(f, False) for f in seen], "sep": ", ",
                      "indent": "  ", "test": "all of it", "done": "all pass"})
    return tasks


@st.composite
def cases(draw, status=None, union_last=False, cite="some"):
    reqs = draw(requirements())
    if cite == "each":   # a shipped spec that owes nothing: one requirement at least has no waiver
        reqs[0]["waived"] = False
        reqs[0]["block"] = [line.replace(" [untested: prose, read by hand]", "")
                            for line in reqs[0]["block"] if line.strip() != "[untested: prose, read by hand]"]
        cited = [r["n"] for r in reqs if not r["waived"]]
    else:
        cited = [r["n"] for r in reqs if draw(st.booleans())]
    if status is None:
        status = st.sampled_from(["open", "shipped"])
    if not isinstance(status, str):
        status = draw(status)
    return Case(draw(SLUG), status, reqs, draw(task_lists(reqs, union_last)), cited)


# ---- running the two scripts ---------------------------------------------------------------

def run(*argv):
    done = subprocess.run(["sh"] + list(argv), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return done.returncode, done.stdout


def spec_check(proj, slug):
    code, out = run(SPEC_CHECK, proj, slug)
    lines = out.decode("utf-8", "replace").splitlines()
    m = re.match(r"spec-check: \d+ spec\(s\) checked, (\d+) gap\(s\)$", lines[-1] if lines else "")
    assert m, "spec-check.sh ended without its count: %r" % (lines[-3:],)
    return lines, int(m.group(1))


def brief(proj, slug, task):
    code, out = run(BRIEF, proj, slug, task)
    assert code == 0, "brief.sh %s exits %d: %r" % (task, code, out[-200:])
    return out


def snapshot(top):
    seen = {}
    for folder, _, names in os.walk(top):
        seen[os.path.relpath(folder, top) + "/"] = None
        for name in names:
            with open(os.path.join(folder, name), "rb") as f:
                seen[os.path.relpath(os.path.join(folder, name), top)] = f.read()
    return seen


def fresh(case):
    return case.write()


def done_with(proj):
    shutil.rmtree(proj, ignore_errors=True)


# ---- the five properties ---------------------------------------------------------------------

def agreement(case):
    # tests-worth-having/REQ-21
    proj = fresh(case)
    try:
        lines, _ = spec_check(proj, case.slug)
        said = sorted(tuple(line.split(" ", 4)[2:]) for line in lines if line.startswith("CONFLICT "))
        files = {}
        for t in case.tasks:
            body = brief(proj, case.slug, t["id"]).decode("utf-8", "replace")
            section = body.split("\n## You may edit\n", 1)[1].split("\nNothing else.", 1)[0]
            files[t["id"]] = [line[2:] for line in section.splitlines() if line.startswith("- ")]
        ids = [t["id"] for t in case.tasks]
        want = sorted((a, b, f) for i, a in enumerate(ids) for b in ids[i + 1:]
                      for f in files[a] if f in files[b])
        assert said == want, ("spec-check.sh's CONFLICT lines and brief.sh's files disagree.\n"
                              "  spec-check.sh: %r\n  from brief.sh: %r" % (said, want))
    finally:
        done_with(proj)


def no_side_effect(case):
    # tests-worth-having/REQ-22
    proj = fresh(case)
    try:
        before = snapshot(proj)
        first = run(SPEC_CHECK, proj, case.slug)
        second = run(SPEC_CHECK, proj, case.slug)
        after = snapshot(proj)
        changed = sorted(k for k in set(before) | set(after) if before.get(k, 0) != after.get(k, 0))
        assert not changed, "spec-check.sh changed the project: %r" % (changed,)
        assert first == second, "two runs of spec-check.sh differ:\n  %r\n  %r" % (first, second)
    finally:
        done_with(proj)


def monotone(pair):
    # tests-worth-having/REQ-23
    case, n = pair
    proj = fresh(case)
    try:
        _, before = spec_check(proj, case.slug)
        with open(os.path.join(proj, "tests", "test_more.py"), "w", encoding="utf-8") as f:
            f.write("# %s/REQ-%d\n" % (case.slug, n))
        _, after = spec_check(proj, case.slug)
        assert after <= before, ("a citation of REQ-%d was added in tests/test_more.py and the "
                                 "gap count went from %d to %d" % (n, before, after))
    finally:
        done_with(proj)


def exactly_one(pair):
    # tests-worth-having/REQ-24
    case, n = pair
    proj = fresh(case)
    try:
        before, gaps_before = spec_check(proj, case.slug)
        kept = [k for k in case.cited if k != n]
        with open(os.path.join(proj, "tests", "test_gen.py"), "w", encoding="utf-8") as f:
            f.write("".join("# %s/REQ-%d\n" % (case.slug, k) for k in kept))
        after, gaps_after = spec_check(proj, case.slug)

        def body(lines):   # every line but the two that count
            return sorted(line for line in lines[:-1] if not line.startswith("EVIDENCE "))
        added = list(body(after))
        for line in body(before):
            if line in added:
                added.remove(line)
        gone = list(body(before))
        for line in body(after):
            if line in gone:
                gone.remove(line)
        want = ["MISSING-TEST %s REQ-%d" % (case.slug, n)]
        assert added == want and not gone and gaps_after == gaps_before + 1, (
            "the only citation of REQ-%d was taken away.\n  lines added: %r\n  lines gone: %r\n"
            "  gap count: %d, then %d" % (n, added, gone, gaps_before, gaps_after))
    finally:
        done_with(proj)


def round_trip(pair):
    # tests-worth-having/REQ-25
    case, index = pair
    task = case.tasks[index % len(case.tasks)]
    proj = fresh(case)
    try:
        out = brief(proj, case.slug, task["id"])
        start = out.index(b"\n## Requirement\n") + len(b"\n## Requirement\n")
        got = out[start:out.index(b"\n\n## You may edit\n", start)] + b"\n"
        blocks = {r["n"]: r["block"] for r in case.reqs}
        want = "".join(line + "\n" for n in task["cites"] for line in blocks[n]).encode("utf-8")
        assert got == want, ("brief.sh %s does not print its requirement as spec.md has it.\n"
                             "  printed: %r\n  spec.md: %r" % (task["id"], got, want))
    finally:
        done_with(proj)


def with_requirement(case_strategy, unwaived_only):
    """A case and the number of one of its requirements."""
    def pick(case):
        numbers = [r["n"] for r in case.reqs if not (unwaived_only and r["waived"])]
        return st.tuples(st.just(case), st.sampled_from(numbers))
    return case_strategy.flatmap(pick)


def not_yet_cited(pair):
    """The same case with no line that cites the chosen requirement. A citation is then new
    when the property adds it: one that repeats a line already there can change nothing."""
    case, n = pair
    return Case(case.slug, case.status, case.reqs, case.tasks, [k for k in case.cited if k != n]), n


# An open spec's gap count does not read citations, so two specs in three are shipped.
MOSTLY_SHIPPED = st.sampled_from(["shipped", "shipped", "open"])


PROPERTIES = [
    ("agreement", agreement, cases(status="open", union_last=True)),
    ("no-side-effect", no_side_effect, cases()),
    ("monotone", monotone, with_requirement(cases(status=MOSTLY_SHIPPED), unwaived_only=False).map(not_yet_cited)),
    ("exactly-one", exactly_one, with_requirement(cases(status="shipped", cite="each"), unwaived_only=True)),
    ("round-trip", round_trip, st.tuples(cases(), st.integers(0, 4))),
]


def check(name, prop, strategy, args):
    """Run one property. Returns None when it holds, or the lines that say how it failed."""
    tried, failing = [0], [None]

    def body(value):
        tried[0] += 1
        try:
            prop(value)
        except BaseException:
            failing[0] = value
            raise

    phases = [Phase.explicit, Phase.generate] + ([] if args.no_shrink else [Phase.shrink])
    test = settings(max_examples=args.max_examples, derandomize=True, database=None, deadline=None,
                    phases=phases, verbosity=Verbosity.quiet, report_multiple_bugs=False,
                    suppress_health_check=list(HealthCheck))(given(strategy)(body))
    try:
        test()
    except Exception as failure:   # an assertion, or anything the property could not read
        value = failing[0]
        case = value[0] if isinstance(value, tuple) else value
        said = str(failure) or failure.__class__.__name__
        return "%s\n%s" % (said, case.show() if isinstance(case, Case) else "")
    print("PASS %s (%d inputs)" % (name, tried[0]))
    return None


def main():
    global SPEC_CHECK, BRIEF, WORK
    names = [name for name, _, _ in PROPERTIES]
    ap = argparse.ArgumentParser(description="Five properties of spec-check.sh and brief.sh.")
    ap.add_argument("--only", choices=names)
    ap.add_argument("--max-examples", type=int, default=40)
    ap.add_argument("--no-shrink", action="store_true")
    ap.add_argument("--spec-check", default=SPEC_CHECK)
    ap.add_argument("--brief", default=BRIEF)
    args = ap.parse_args()
    SPEC_CHECK, BRIEF = os.path.abspath(args.spec_check), os.path.abspath(args.brief)
    for script in (SPEC_CHECK, BRIEF):
        if not os.path.isfile(script):
            ap.error("no such script: %s" % script)
    wanted = [p for p in PROPERTIES if args.only in (None, p[0])]
    failed = 0
    with tempfile.TemporaryDirectory(prefix="shipkit-prop.") as work:
        WORK = work
        # Hypothesis keeps tables of its own in a .hypothesis folder of the working directory,
        # whatever the database setting says. They go with the rest, into the directory that
        # is removed.
        hypothesis.configuration.set_hypothesis_home_dir(os.path.join(work, "hypothesis"))
        for name, prop, strategy in wanted:
            why = check(name, prop, strategy, args)
            if why is not None:
                failed += 1
                print("FAIL %s" % name)
                sys.stdout.write(why if why.endswith("\n") else why + "\n")
    print("prop: %d of %d hold (hypothesis %s, python %s)" % (
        len(wanted) - failed, len(wanted), hypothesis.__version__, sys.version.split()[0]))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
