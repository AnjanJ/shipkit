#!/usr/bin/env python3
"""Shipkit plugin lint.

Validates the markdown/JSON surfaces this plugin ships. Every check here exists
because its bug class either happened or is one typo away:

  1.2.1  a template under agents/ registered as a bogus agent
  1.2.x  interactive checkpoints inside forked skills that can never reach the user
  2.7.0  (audit) agents/ is scanned RECURSIVELY by Claude Code, so a template in
         agents/templates/ registered as an agent with all tools; a plugin-root
         knowledge/ directory and settings.json that Claude Code does not load;
         {{PLACEHOLDERS}} in shipped files with no substitution step; dead
         `… || echo` fallbacks in !`…` injections; doc counts drifting from reality.

Run before every release (PyYAML gives full frontmatter parsing):

    uv run --with pyyaml python3 scripts/lint.py      # or ./scripts/lint.sh

Exits non-zero on any error. stdlib only; degrades to structural checks when
PyYAML is missing.
"""

import json
import re
import shlex
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# The repo is a MARKETPLACE holding several plugins (since 3.0). Per-plugin checks run
# against each root listed in marketplace.json; repo-level checks (version consistency,
# CHANGELOG) run once. PLUGIN_ROOTS is derived, never hard-coded, so adding a third
# plugin needs no lint change.
def _plugin_roots():
    mp_path = ROOT / ".claude-plugin" / "marketplace.json"
    try:
        mp = json.loads(mp_path.read_text())
    except (OSError, json.JSONDecodeError):
        return [ROOT]
    roots = []
    for entry in mp.get("plugins", []):
        src = entry.get("source")
        if isinstance(src, str):
            roots.append((ROOT / src).resolve())
    return roots or [ROOT]


PLUGIN_ROOTS = _plugin_roots()

# The CORE plugin owns the hook, the rules, the stacks and the install scripts. Checks that
# are about those surfaces run against it specifically, not against every plugin.
CORE = next((r for r in PLUGIN_ROOTS if r.name == "shipkit"), PLUGIN_ROOTS[0])

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None

errors = []
warnings = []


def err(path, msg):
    errors.append(f"ERROR {path.relative_to(ROOT)}: {msg}")


def warn(path, msg):
    warnings.append(f"warn  {path.relative_to(ROOT)}: {msg}")


def split_frontmatter(path):
    """Return (frontmatter_text or None, body). None = no frontmatter block."""
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return None, text
    end = text.find("\n---", 4)
    if end == -1:
        return None, text
    return text[4:end], text[end + 4:]


def parse_frontmatter(path, fm_text):
    """Parse frontmatter; fall back to a key-scrape if PyYAML is missing."""
    if yaml is not None:
        try:
            data = yaml.safe_load(fm_text)
        except yaml.YAMLError as e:
            err(path, f"frontmatter is not valid YAML: {e}")
            return {}
        if not isinstance(data, dict):
            err(path, "frontmatter is not a YAML mapping")
            return {}
        return data
    # Degraded mode: top-level "key:" scrape, enough for required-field checks.
    keys = {}
    for line in fm_text.splitlines():
        m = re.match(r"^([A-Za-z][A-Za-z0-9_-]*):\s*(.*)$", line)
        if m:
            v = m.group(2).strip().strip('"')
            keys[m.group(1)] = {"true": True, "false": False}.get(v, v)
    return keys


def strip_html_comments(text):
    return re.sub(r"<!--.*?-->", "", text, flags=re.DOTALL)


def shipped_text_files():
    """Every text file the plugin ships (excluding VCS, local state, and scripts)."""
    for path in sorted(ROOT.rglob("*")):
        rel = path.relative_to(ROOT)
        if rel.parts[0] in (".git", ".claude", "scripts") or not path.is_file():
            continue
        if path.suffix not in (".md", ".json", ".yml", ".yaml", ".append", ".sh"):
            continue
        yield path


# --- Collect files -----------------------------------------------------------

skill_files, agent_files, agent_files_recursive, rule_files = [], [], [], []
for _r in PLUGIN_ROOTS:
    skill_files += list(_r.glob("skills/*/SKILL.md")) + list(_r.glob("stacks/*/.claude/skills/*/SKILL.md"))
    agent_files += list(_r.glob("agents/*.md"))
    agent_files_recursive += [p for p in _r.rglob("agents/**/*.md") if p.is_file()]
    rule_files += list(_r.glob("rules/*.md")) + list(_r.glob("stacks/*/.claude/rules/*.md"))
skill_files = sorted(skill_files)
agent_files = sorted(agent_files)
agent_files_recursive = sorted(agent_files_recursive)
rule_files = sorted(rule_files)

# --- 1. Skill frontmatter ----------------------------------------------------

FORK_INTERACTIVE = [
    (r"AskUserQuestion", "uses AskUserQuestion"),
    (r"CHECKPOINT", "has a CHECKPOINT"),
    (r"[Ww]ait for (the )?user", "waits for the user"),
    (r"(?<!cannot )(?<!can't )(?<!never )(?<!no )[Aa]sk the user", "asks the user"),
    (r"[Aa]fter user feedback", "expects user feedback mid-run"),
    (r"[Pp]resent(ed)? to (the )?[Uu]ser", "presents to the user mid-run"),
]

for path in skill_files:
    fm_text, body = split_frontmatter(path)
    if fm_text is None:
        err(path, "missing frontmatter block")
        continue
    fm = parse_frontmatter(path, fm_text)
    if not fm.get("description"):
        err(path, "frontmatter missing required field: description")

    # 2. @references must resolve (relative to the skill's directory)
    for ref in re.findall(r"@([A-Za-z0-9_\-./]+\.md)", strip_html_comments(body)):
        if not (path.parent / ref).exists():
            err(path, f"@{ref} does not resolve (expected {path.parent / ref})")

    # 3. Forked skills must be non-interactive. AskUserQuestion is blocked in
    # subagents, so any mid-run question/checkpoint silently never reaches the
    # user. Checked across EVERY .md in the skill directory (reference files
    # are read by the fork too). Negated mentions ("cannot ask the user") pass.
    if fm.get("context") == "fork":
        for md in sorted(path.parent.glob("*.md")):
            clean = strip_html_comments(md.read_text(encoding="utf-8"))
            for pattern, label in FORK_INTERACTIVE:
                for i, line in enumerate(clean.splitlines(), 1):
                    if re.search(pattern, line):
                        err(md, f"forked skill {label} (line ~{i}: {line.strip()[:80]!r}) "
                                "— forked skills are non-interactive")
        # A fork cannot spawn subagents either.
        clean = strip_html_comments(body)
        for i, line in enumerate(clean.splitlines(), 1):
            if re.search(r"(via|use|delegate to|launch) (the )?`?codebase-explorer`? agent", line):
                err(path, f"forked skill tries to delegate to a subagent (line ~{i}) — "
                          "subagents cannot spawn subagents; the fork must read directly")

# --- 4. agents/ purity (RECURSIVE) ------------------------------------------
# Claude Code scans agents/ recursively: every .md under it, at any depth,
# registers as an agent. A frontmatter-less file becomes an agent with all
# tools. Nothing but real agents may live under agents/.

for path in agent_files_recursive:
    fm_text, _ = split_frontmatter(path)
    if fm_text is None:
        err(path, "file under agents/ has no frontmatter — it registers as a broken agent "
                  "with all tools; agents/ may contain only real agents (recursively)")
        continue
    if path.parent.name != "agents":
        err(path, "agent file in a subdirectory of agents/ — Claude Code registers it under a "
                  "nested name; keep agents flat")
    fm = parse_frontmatter(path, fm_text)
    for field in ("name", "description"):
        if not fm.get(field):
            err(path, f"agent frontmatter missing required field: {field}")
    if fm.get("name") and fm["name"] != path.stem:
        err(path, f"agent name {fm['name']!r} does not match filename {path.stem!r}")

# --- 5. Rule files -----------------------------------------------------------
# Frontmatter is optional (no frontmatter = always-on rule) but if present its
# paths: must be a non-empty list of non-empty strings.

for path in rule_files:
    fm_text, _ = split_frontmatter(path)
    if fm_text is None:
        continue
    fm = parse_frontmatter(path, fm_text)
    if "paths" in fm and yaml is not None:
        paths = fm["paths"]
        if not isinstance(paths, list) or not paths:
            err(path, "rule paths: must be a non-empty list")
        else:
            for g in paths:
                if not isinstance(g, str) or not g.strip():
                    err(path, f"rule paths: contains an invalid glob: {g!r}")

# --- 6. Version consistency + doc counts ------------------------------------

marketplace_json = ROOT / ".claude-plugin" / "marketplace.json"
version = None
for _r in PLUGIN_ROOTS:
    pj = _r / ".claude-plugin" / "plugin.json"
    try:
        v = json.loads(pj.read_text())["version"]
    except (OSError, json.JSONDecodeError, KeyError) as e:
        err(pj, f"cannot read version: {e}")
        continue
    if version is None:
        version = v
    elif v != version:
        err(pj, f"version is {v!r} but another plugin in this marketplace says {version!r} "
                f"(versions are lockstep)")

mp = None
if version:
    try:
        mp = json.loads(marketplace_json.read_text())
        for label, v in [("metadata.version", mp.get("metadata", {}).get("version"))] + [
            (f"plugins[{i}].version", p.get("version")) for i, p in enumerate(mp.get("plugins", []))
        ]:
            if v != version:
                err(marketplace_json, f"{label} is {v!r} but plugin.json says {version!r}")
    except (OSError, json.JSONDecodeError) as e:
        err(marketplace_json, f"cannot parse: {e}")

    changelog = ROOT / "CHANGELOG.md"
    if f"[{version}]" not in changelog.read_text():
        err(changelog, f"no entry for current version [{version}]")

# Counts in the marketplace description must match reality. "N skills" counts
# user-invocable skills (knowledge bases are user-invocable: false and are
# described separately); "N agents" counts files directly under agents/.
if mp:
    for i, p in enumerate(mp.get("plugins", [])):
        src = p.get("source")
        proot = (ROOT / src).resolve() if isinstance(src, str) else ROOT
        user_skills = 0
        for sp in proot.glob("skills/*/SKILL.md"):
            fm_text, _ = split_frontmatter(sp)
            fm = parse_frontmatter(sp, fm_text) if fm_text else {}
            if fm.get("user-invocable") is True:
                user_skills += 1
        actual_agents = len(list(proot.glob("agents/*.md")))
        desc = p.get("description", "")
        m = re.search(r"(\d+) skills", desc)
        if m and int(m.group(1)) != user_skills:
            err(marketplace_json, f"plugins[{i}].description says {m.group(1)} skills but "
                                  f"{user_skills} user-invocable skills exist")
        m = re.search(r"(\d+) agents", desc)
        if m and int(m.group(1)) != actual_agents:
            err(marketplace_json, f"plugins[{i}].description says {m.group(1)} agents but "
                                  f"{actual_agents} exist")

# --- 7. No machine-specific absolute paths -----------------------------------
# Shipped content must work on any machine. /Users/<name>, /home/<name>, and
# C:\Users\ paths are always someone's laptop leaking into the plugin.

ABS_PATH = re.compile(r"(/Users/[A-Za-z]|/home/[A-Za-z]|C:\\\\Users\\\\)")
for path in shipped_text_files():
    for i, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        if ABS_PATH.search(line):
            err(path, f"machine-specific absolute path (line {i}: {line.strip()[:80]!r})")

# --- 8. Directories/files Claude Code does not load --------------------------
# A plugin's knowledge/ and rules/ are not plugin components; rules/ is kept
# because the session hook injects it and /setup installs it, but knowledge/
# would be dead content. settings.json at plugin root is a documented file
# whose only keys are `agent` (name of an agent to run as the main thread) and
# `subagentStatusLine` — shipkit has no use for either.

for d in ROOT.rglob("knowledge"):
    if d.is_dir() and ".git" not in d.parts:
        err(d, "knowledge/ directory — Claude Code does not load it; ship knowledge bases as "
               "skills with user-invocable: false")
if (ROOT / "settings.json").exists():
    err(ROOT / "settings.json", "plugin-root settings.json — its `agent` key runs an agent as "
                                "the main thread; shipkit must not ship one")

hooks_json = CORE / "hooks" / "hooks.json"
HOOK_CONTEXT_CAP = 10_000  # chars per hook command added to context (verified on 2.1.270)
HOOK_HEADER = 400          # inject-rule.sh's own header lines, with margin
injected_rules = set()
if hooks_json.exists():
    # Parse as JSON and split with shlex: the commands quote the interpolated
    # ${CLAUDE_PLUGIN_ROOT} (a plugin path may contain spaces — unquoted it exits 127),
    # so neither a "([^"]+)" regex nor a bare .split() reads them correctly.
    _hook_cmds = []
    try:
        _hj = json.loads(hooks_json.read_text())
        for _event in _hj.get("hooks", {}).values():
            for _matcher in _event:
                for _h in _matcher.get("hooks", []):
                    if "command" in _h:
                        _hook_cmds.append(_h["command"])
    except (OSError, json.JSONDecodeError) as e:
        err(hooks_json, f"cannot parse: {e}")
    for cmd in _hook_cmds:
        try:
            parts = shlex.split(cmd)
        except ValueError as e:
            err(hooks_json, f"hook command {cmd!r} is not valid shell syntax: {e}")
            continue
        if not parts:
            err(hooks_json, "empty hook command")
            continue
        if "${CLAUDE_PLUGIN_ROOT}/" in cmd and not cmd.startswith('"${CLAUDE_PLUGIN_ROOT}/'):
            err(hooks_json, f"hook command {cmd!r} interpolates ${{CLAUDE_PLUGIN_ROOT}} "
                            "unquoted — it exits 127 when the plugin path contains spaces; "
                            'write "${CLAUDE_PLUGIN_ROOT}/scripts/x.sh" args')
        script = CORE / parts[0].replace("${CLAUDE_PLUGIN_ROOT}/", "")
        if not script.exists():
            err(hooks_json, f"hook command {cmd!r} does not resolve to a file")
        elif not (script.stat().st_mode & 0o111):
            err(script, "hook script is not executable")
        # inject-rule.sh <name>: the rule must exist and fit under the per-command cap.
        if script.name == "inject-rule.sh":
            if len(parts) != 2:
                err(hooks_json, f"hook command {cmd!r} must pass exactly one rule name")
                continue
            rule = CORE / "rules" / f"{parts[1]}.md"
            injected_rules.add(rule.name)
            if not rule.exists():
                err(hooks_json, f"hook command {cmd!r} names a rule that does not exist")
            elif rule.stat().st_size + HOOK_HEADER > HOOK_CONTEXT_CAP:
                err(rule, f"always-on rule is {rule.stat().st_size} bytes; with the hook header "
                          f"it exceeds the {HOOK_CONTEXT_CAP}-char per-hook context cap and would "
                          "be silently dropped — split it or trim it")
    # Every always-on rule (no paths: frontmatter) must be injected by a hook command;
    # otherwise plugin-only users never see it.
    for path in sorted(CORE.glob("rules/*.md")):
        fm_text, _ = split_frontmatter(path)
        fm = parse_frontmatter(path, fm_text) if fm_text else {}
        if "paths" not in fm and path.name not in injected_rules:
            err(path, "always-on rule (no paths: frontmatter) is not injected by any "
                      "inject-rule.sh hook command in hooks/hooks.json")

# --- 8b. Shipped scripts must exist and be executable ------------------------
for name, base in [("session-start.sh", CORE), ("inject-rule.sh", CORE),
                   ("install-rules.sh", CORE), ("install-stack.sh", CORE),
                   ("smoke.sh", ROOT), ("lint.sh", ROOT)]:
    sp = base / "scripts" / name
    if not sp.exists():
        err(sp, "required script is missing")
    elif not (sp.stat().st_mode & 0o111):
        err(sp, "script is not executable")
if not (CORE / "scripts" / "lib-rules-sha.sh").exists():
    err(CORE / "scripts" / "lib-rules-sha.sh", "shared helper is missing (install-rules.sh and "
                                               "session-start.sh both source it)")

# --- 9. Placeholders --------------------------------------------------------
# {{NAME}} placeholders may only appear under stacks/ (filled by /setup), and
# every one used there must be listed in setup's substitution table so it is
# actually replaced.

PLACEHOLDER = re.compile(r"\{\{([A-Z_]+)\}\}")
setup_skill = (CORE / "skills" / "setup" / "SKILL.md").read_text(encoding="utf-8")
setup_table = set(PLACEHOLDER.findall(setup_skill))
for path in shipped_text_files():
    rel = path.relative_to(ROOT)
    for i, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        for name in PLACEHOLDER.findall(line):
            if "stacks" in rel.parts:
                if name not in setup_table:
                    err(path, f"{{{{{name}}}}} is not in /setup's substitution table "
                              f"(skills/setup/SKILL.md) — it would be installed verbatim")
            elif path in (CORE / "skills" / "setup" / "SKILL.md",
                          CORE / "scripts" / "install-stack.sh"):
                pass  # the substitution table itself, and the installer's own usage prose
            else:
                err(path, f"{{{{{name}}}}} placeholder outside stacks/ (line {i}) — nothing "
                          "substitutes it")

# --- 10. Dead shell fallbacks in !`…` injections ------------------------------
# `cmd | head || echo x` tests head's exit status (always 0); `git diff … || echo`
# never fires because git diff exits 0 on empty output. Use
# f=$(cmd); [ -n "$f" ] && echo "$f" || echo "fallback".

DEAD_FALLBACK = re.compile(r"!`(?![^`]*\[ -n)[^`]*(\|\s*(head|tail|grep|sort)[^`]*\|\||git diff[^`]*\|\|)[^`]*echo")
for path in skill_files:
    for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if DEAD_FALLBACK.search(line):
            warn(path, f"!`…` injection has a dead `|| echo` fallback (line {i}) — "
                       "guard on output emptiness instead")

# --- 11. Bare multi-operand `ls` in !`…` injections ---------------------------
# `ls a b c 2>/dev/null` exits NONZERO if ANY operand is missing (exit 2 with one of
# eight present). A skill whose dynamic-context command fails does not render at all:
# Claude returns "Shell command failed for pattern" with zero model turns, so the
# whole skill is lost before the model ever sees it. Probe with the guarded form:
#   f=$(ls a b c 2>/dev/null); [ -n "$f" ] && echo "$f" || echo "none found"

BARE_LS = re.compile(r"!`\s*ls\s+(?![^`]*\[\s-n\s)[^`|]*?\s+\S+[^`]*`")
for path in skill_files:
    for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        for m in BARE_LS.finditer(line):
            frag = m.group(0)
            # A single operand (plus redirections) cannot fail on a missing sibling.
            operands = [w for w in frag[2:-1].split()[1:]
                        if not w.startswith(("2>", ">", "-"))]
            if len(operands) > 1:
                err(path, f"bare multi-operand `ls` in a !`…` injection (line {i}) — "
                          "exits nonzero if ANY operand is missing and the skill then "
                          'fails to render; use f=$(ls …); [ -n "$f" ] && echo "$f" || echo "none"')

# --- 12. Stack overlays: structure and add-on bases ---------------------------
# An overlay rule with no paths: becomes an always-on rule in the project that installs it.
# That is intentional for the language-convention rules (rails.md, python.md, ...), but it
# costs context in every session of that project, so keep them short — warn past a budget.
# Every add-on must name an existing base overlay via `<!-- requires: <base> -->` so
# /shipkit:setup can order the installs (base first, then add-ons).

OVERLAY_ALWAYS_ON_MAX = 2000   # bytes; these load in every session of the installed project

overlay_dirs = sorted(d for d in (CORE / "stacks").glob("*") if d.is_dir())
overlay_names = {d.name for d in overlay_dirs}
for d in overlay_dirs:
    for rule in sorted(d.glob(".claude/rules/*.md")):
        text = rule.read_text(encoding="utf-8")
        fm_text, _ = split_frontmatter(rule)
        fm = parse_frontmatter(rule, fm_text) if fm_text else {}
        if "paths" not in (fm or {}):
            size = rule.stat().st_size
            if size > OVERLAY_ALWAYS_ON_MAX:
                warn(rule, f"overlay rule has no paths: so it loads in every session of the "
                           f"installed project, and is {size} bytes (budget "
                           f"{OVERLAY_ALWAYS_ON_MAX}) — scope it with paths: or trim it")
        m = re.search(r"<!--\s*requires:\s*([a-z0-9_-]+)\s*-->", text)
        if m and m.group(1) not in overlay_names:
            err(rule, f"declares `requires: {m.group(1)}` but stacks/{m.group(1)}/ does not exist")

# --- Report ------------------------------------------------------------------

for w in warnings:
    print(w)
for e in errors:
    print(e)
if yaml is None:
    print("note: PyYAML not installed — frontmatter checked structurally, not parsed "
          "(run: uv run --with pyyaml python3 scripts/lint.py)")
print(f"\nlint: {len(errors)} error(s), {len(warnings)} warning(s) "
      f"across {len(skill_files)} skills, {len(agent_files)} agents, {len(rule_files)} rules")
sys.exit(1 if errors else 0)
