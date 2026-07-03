#!/usr/bin/env python3
"""Shipkit plugin lint.

Validates the markdown/JSON surfaces this plugin ships. Every check here exists
because its bug class either happened (1.2.1: a template under agents/ registered
as a bogus agent; 1.2.x: interactive checkpoints inside forked skills that can
never reach the user) or is one typo away. Run before every release:

    ./scripts/lint.sh

Exits non-zero on any error. stdlib only; uses PyYAML for full frontmatter
parsing when available, degrading to structural checks when not.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

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
            keys[m.group(1)] = m.group(2).strip().strip('"')
    return keys


def strip_html_comments(text):
    return re.sub(r"<!--.*?-->", "", text, flags=re.DOTALL)


# --- Collect files -----------------------------------------------------------

skill_files = sorted(
    list(ROOT.glob("skills/*/SKILL.md"))
    + list(ROOT.glob("knowledge/*/SKILL.md"))
    + list(ROOT.glob("stacks/*/.claude/skills/*/SKILL.md"))
    + list(ROOT.glob("stacks/*/.claude/knowledge/*/SKILL.md"))
)
agent_files = sorted(p for p in ROOT.glob("agents/*.md"))
rule_files = sorted(
    list(ROOT.glob("rules/*.md")) + list(ROOT.glob("stacks/*/.claude/rules/*.md"))
)

# --- 1. Skill frontmatter ----------------------------------------------------

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
    # user. Negated mentions ("cannot ask the user") are allowed.
    if fm.get("context") == "fork":
        clean = strip_html_comments(body)
        for pattern, label in [
            (r"AskUserQuestion", "uses AskUserQuestion"),
            (r"CHECKPOINT", "has a CHECKPOINT"),
            (r"[Ww]ait for (the )?user", "waits for the user"),
            (r"(?<!cannot )(?<!can't )(?<!never )[Aa]sk the user", "asks the user"),
        ]:
            for i, line in enumerate(clean.splitlines(), 1):
                if re.search(pattern, line):
                    err(path, f"forked skill {label} (line ~{i}: {line.strip()[:80]!r}) "
                              "— forked skills are non-interactive")

# --- 4. agents/ purity -------------------------------------------------------
# Every .md directly under agents/ registers as an agent. Templates and other
# support files must live in subdirectories (agents/templates/), not here.

for path in agent_files:
    fm_text, _ = split_frontmatter(path)
    if fm_text is None:
        err(path, "file directly under agents/ has no frontmatter — it will "
                  "register as a broken agent; move non-agents to a subdirectory")
        continue
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

# --- 6. Version consistency --------------------------------------------------

plugin_json = ROOT / ".claude-plugin" / "plugin.json"
marketplace_json = ROOT / ".claude-plugin" / "marketplace.json"
version = None
try:
    version = json.loads(plugin_json.read_text())["version"]
except (OSError, json.JSONDecodeError, KeyError) as e:
    err(plugin_json, f"cannot read version: {e}")

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

# --- 7. No machine-specific absolute paths -----------------------------------
# Shipped content must work on any machine. /Users/<name>, /home/<name>, and
# C:\Users\ paths are always someone's laptop leaking into the plugin.

ABS_PATH = re.compile(r"(/Users/[A-Za-z]|/home/[A-Za-z]|C:\\\\Users\\\\)")
for path in sorted(ROOT.rglob("*")):
    rel = path.relative_to(ROOT)
    parts = rel.parts
    if parts[0] in (".git", ".claude", "scripts") or not path.is_file():
        continue
    if path.suffix not in (".md", ".json", ".yml", ".yaml", ".append"):
        continue
    for i, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        if ABS_PATH.search(line):
            err(path, f"machine-specific absolute path (line {i}: {line.strip()[:80]!r})")

# --- Report ------------------------------------------------------------------

for w in warnings:
    print(w)
for e in errors:
    print(e)
if yaml is None:
    print("note: PyYAML not installed — frontmatter checked structurally, not parsed")
print(f"\nlint: {len(errors)} error(s), {len(warnings)} warning(s) "
      f"across {len(skill_files)} skills, {len(agent_files)} agents, {len(rule_files)} rules")
sys.exit(1 if errors else 0)
