# Design: The owner's project, and 5.1.0 (Sprint 25)

## Approach

Five records. The debts go first because the run reads them, and each is a small change with a free
smoke check, so nothing paid depends on them being guessed right. The run comes next and fixes
nothing. The roadmap takes what it found. The release is last, because a full run read before the
tip is final would have to be read twice.

---

## Decision: Two conditions, written out in the installer   (→ REQ-1, REQ-2, REQ-8)

**Context.** `install-stack.sh` copies every `stacks/<stack>/.claude/rules/*.md` and every section line
whatever the project is. `django.md` loads on any `models.py`, so a FastAPI project pays 583 bytes on
a matching read for advice about a framework it does not use. The section's `**Async DB:**` line
tells a sync project to use an async ORM. Each is one item in one stack.

**Alternatives.**
1. Two literal conditions in `install-stack.sh`: one on the rule's name, one on the section line.
2. A mechanism: a `when:` key in a rule's frontmatter and a marker on a section line, both read by the
   installer for any stack.
3. Keep installing `django.md`, correct setup's parenthesis to say what really loads it.

**Case for (1).** Two conditions, about six lines, read where the copying happens. Neither needs a new
format. Nothing in any other stack asks for one.

**Case against (1).** The installer now knows one stack's file names, a smell it has so far avoided. A
framework that setup could not detect reaches the script as `TODO: …`, reads as not Django, and a
Django project loses the rule until it re-runs setup. (2) would put the condition beside the thing it
governs and would make the next one free. (3) has no code at all and leaves the cost where it is.

**Decision.** We chose (1). The name match is a glob, `[Dd]jango*`, so that `Django 5.2` from a model
does not silently lose a real Django project its rule. `ASYNC_MODE` matches `no` or `No` and nothing
else, so that a `TODO:` value keeps the line: an undetected project keeps today's text.
**Falsifiability.** We would move to (2) if a third condition is asked for in any stack.
**Fired-if.** manual

---

## Decision: A section is cleaned from the template, whole comments included   (→ REQ-6, REQ-7, REQ-9)

**Context.** G8 names `<!-- a / b -->` alternatives. Read against the files, the 34 comment lines are
26 alternatives, 5 hints and 3 `<!-- /shipkit:setup fills these in from detection -->`. Setup reads a
hint from `CLAUDE.md.append` when it writes `TODO: <the hint>` (`setup/SKILL.md:134`), so the source
must keep them. The two markers are comments too, and must survive.

**Alternatives.**
1. Strip every comment from the template as it is read into the section, before `subst`, so that the
   markers (added around it) and every value are out of reach.
2. Strip only `a / b` alternatives, by pattern, and keep hints.
3. Strip after `subst`, on the finished section, skipping the markers.
4. Delete the comments from `CLAUDE.md.append` and give setup the hints another way.

**Case for (1).** One rule with no exceptions and one `sed`. A value is the user's and a template
comment is shipkit's, and this order cannot confuse them. `NEW` is built from the section as before,
so the sha is taken after, with no change to that code.

**Case against (1).** A script caller who passes a bare `KEY=TODO` loses the hint it would have seen.
A hint on a real `TODO:` value is lost if setup wrote the value without it. An installed section
drifts from its source by about 20% on Python, so a person comparing the two sees a difference. A
user who edited their section sees every comment line in the next setup's diff, once.

**Decision.** We chose (1). Setup writes the hint into the `TODO:` value, so the section keeps it
there. The sha needs no separate step, and check 81 shows it by a re-run reading "already current".
**Falsifiability.** We would keep hints if a run or a report shows a `TODO:` value written with no
hint and a user unable to fill it.
**Fired-if.** manual

---

## Decision: A stamp line holds a placeholder, and its file names the source   (→ REQ-4, REQ-5)

**Context.** Six stamp lines in five skills hold a literal date. `ROADMAP.md:60`: a real `intake.md`
was stamped 2026-10-05 on 2026-10-31, the template's own date, with no source named. Five of the
skills have no `allowed-tools` line, so `date` is available everywhere the stamp is written.
`portfolio-digest.sh` reads `Product reviewed on` and `Recorded on` with `[0-9-]*`.

**Alternatives.**
1. `<YYYY-MM-DD>` on each line, and one sentence before each template naming `date +%F`.
2. Keep each example date and add the sentence.
3. A `stamp.sh` the skills call.

**Case for (1).** A placeholder cannot be copied as if it were true, and `ship/SKILL.md:98` already
writes a report's filename this way. Six short sentences, none in anything always loaded.

**Case against (1).** A placeholder copied unfilled is worse than a wrong date in one way:
`portfolio-digest.sh` reads an empty date from it and says nothing. Six sentences repeat one fact. (3)
would make the date impossible to get wrong, at the price of a script for a job `date` does. And none
of this reaches the acceptance stamp, which §5 leaves alone.

**Decision.** We chose (1), G8's. The run reads every stamp it writes against the run's date, because
a check on the template shows the template and not what a model does with it.
**Falsifiability.** We would move to (3) if any stamp the run writes holds a date that is not the
run's, or the placeholder itself.
**Fired-if.** manual

---

## Decision: The `Fired-if` sentence goes where the line is taught   (→ REQ-10)

**Context.** `grep -rl expires_at src` from `sh -c` fired on `__pycache__/*.pyc` after the first
`pytest`, because `decision-check.sh` runs over untracked files too (`ROADMAP.md:138`). The plan names
`spec/SKILL.md`, but that file only runs the check. `spec/reference.md:82` teaches the line, and
`decide/SKILL.md:51` sends its reader to the same place.

**Alternatives.**
1. One sentence in `spec/reference.md`.
2. One sentence in `spec/SKILL.md`, as the plan's Files line says.
3. Have `decision-check.sh` run each command on a clean checkout of tracked files.

**Case for (1).** One sentence serves both skills, where the form is taught, in a file read on demand.

**Case against (1).** It is advice: nothing enforces it, a `grep -r` still runs, and the bug it answers
stays possible. (3) would remove the whole class, not one spelling of it. And `reference.md` is read
only if the model opens it, which a model writing a `Fired-if` from memory will not do.

**Decision.** We chose (1), G8's scope, and correct the plan's Files line at approval. (3) is a change
to a check every decision depends on, and nothing has yet paid for it.
**Falsifiability.** We would take (3) if a `Fired-if` written after 5.1.0 fires on an untracked file.
**Fired-if.** manual

---

## Decision: The run reads what happens, on a database of its own   (→ REQ-11, REQ-12, REQ-13, REQ-14, REQ-15)

**Context.** G10 chose `~/code/office_bestie`. Its tests run `ecto.create` and `ecto.migrate` first
(`mix.exs:84`) against `office_bestie_test` plus `MIX_TEST_PARTITION` (`config/test.exs:12`), and the
owner's checkout has 29 dirty entries, so a worktree on the default name would migrate the database
that checkout tests against. G1, G2 and G3 are read as held or not shown, and a real item may never
contradict a decision.

**Alternatives.**
1. A real item, headless, `MIX_TEST_PARTITION=_shipkit5` set for every step, nothing forced.
2. The same, and seed a contradiction into the build so that G3 has something to catch.
3. The default database name, as the plan reads.

**Case for (1).** It changes nothing of the owner's but one new local database, which goes on their
yes. A partition is the project's own mechanism. A run that stays real can say "not shown" and be
believed. `S23-T-MERGE` already forced the gate.

**Case against (1).** G2 and G3 will probably read "not shown", so the most important change in this
release may get no reading from its $2 to $8 run. A headless run answers no question a person would
have asked, so it reads less than a person's session. Nothing fixed means a finding that matters waits
for the next plan, even one found days before the tag. And `TODO.md:204`, the same item as 4.9, reads
like with like, where a fresh item would have read more.

**Decision.** We chose (1), on the owner's item. A finding that would stop the release goes to the
owner at once, and they decide; the plan's rule stands otherwise.
**Falsifiability.** We would seed a contradiction in the plan after if this run and the next both read
G3 as not shown.
**Fired-if.** manual

---

## Decision: The full run goes on the tip, then the gates   (→ REQ-17, REQ-18, REQ-19, REQ-20, REQ-21, REQ-22)

**Context.** The plan's order: the exit checklist, `/shipkit:ship` on three specs one at a time, the
`placeholder` count, the pull request, the tag. The budget is $25 to $33 (the run $2 to $8, three
gates about $1.50, the full run $21 to $23). Gates and smoke check 29 share `$TMPDIR/shipkit-ship-*.out`.

**Alternatives.**
1. The plan's order: the version bump and CHANGELOG, then the full run, then the gates.
2. Gates first, the full run last.

**Case for (1).** The costly run comes once, on what ships. Gates write only `.shipkit/`, so a READY
does not stale the run's reading.

**Case against (1).** A case that fails on a real bug means a change under `plugins/`, and then the
tip the run read is not the tip that ships. A gate's reviewer then costs more than the plan allowed,
and the $25 to $33 stops being true. The `placeholder` count will add few sessions, and they are on a
different model from the 3 of 74, so it shows almost nothing.

**Decision.** We chose (1). A change under `plugins/` after the run re-runs the groups it touches, and
any gate already read, each named to the owner first as outside the budget line.
**Falsifiability.** We would reverse the order if the full run exits 1 on a case that needs a change
under `plugins/`.
**Fired-if.** manual
