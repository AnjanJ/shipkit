---
description: "Set up MemPalace episodic memory end-to-end so grandfather/eve can recall past decisions — installs it if missing, registers it at user scope, and backfills this project's decision history from your Claude transcripts. TRIGGER when: the user asks to set up / enable / connect episodic memory, decision recall, or MemPalace. DO NOT TRIGGER when: MemPalace is already connected and backfilled, or the user only wants the structural project map (use /shipkit:map)."
user-invocable: true
argument-hint: "[--wing <name>] [--reinstall]"
---

<!-- Runs INLINE (no context: fork) on purpose: it confirms before heavy/irreversible steps
     (a ~300MB install, writing an index) and needs AskUserQuestion + real shell execution.
     Forked skills can neither ask the user nor should own a multi-step install. -->

# /shipkit:connect-memory — Set Up Episodic Memory (MemPalace)

Make `grandfather`/`eve` able to answer *"why did we decide X?"* and *"what did we settle last
session?"* — by installing and wiring up **[MemPalace](https://github.com/mempalace/mempalace)**,
an optional, local-first (MIT, no API calls) memory store that indexes your Claude Code
conversation history and retrieves it with semantic search.

**This is opt-in and automates what the GUIDE documents by hand.** MemPalace is a separate Python
package plus a ~300 MB embedding model — the base plugin stays dependency-free; this skill is how
a user who *wants* recall gets it working without hand-running four commands or hand-deriving their
transcript path.

Run this **once per machine** for install+register, and **once per project** for the backfill.

## What it does

1. **Detects state** — is `mempalace-mcp` on PATH? Is it registered with Claude Code? Is this
   project already backfilled? Skip whatever is already done; never redo it.
2. **Installs** MemPalace if missing (`uv` or `pipx`).
3. **Registers** it at user scope so *only* the elder agents can reach it.
4. **Backfills** this project's decision history from your Claude transcripts — dry-run first,
   then for real.
5. **Reminds** you to restart Claude Code so the server loads.

## Procedure

### 1. Detect what's already done

Run these and branch on the results — do not repeat a step that's already complete:

```bash
command -v mempalace-mcp        # installed?
claude mcp list | grep mempalace   # registered? ("✔ Connected" = done)
mempalace status                # palace populated? which wings exist?
```

- If `mempalace-mcp` is on PATH **and** `claude mcp list` shows it connected **and** `mempalace
  status` shows this project's wing already populated → tell the user it's already set up and
  stop (unless `--reinstall`).

### 2. Install (if `mempalace-mcp` is not on PATH)

Prefer `uv`, fall back to `pipx`. This downloads a ~300 MB model on first use — tell the user
that's expected.

```bash
uv tool install mempalace        # or, if no uv:  pipx install mempalace
```

Verify it landed: `command -v mempalace-mcp` should now resolve. If neither `uv` nor `pipx` is
available, show the user the install command and ask them to install one, then re-run.

### 3. Register at user scope (if `claude mcp list` doesn't show it)

```bash
claude mcp add --scope user mempalace mempalace-mcp
```

User scope is required: plugin subagents can't declare their own MCP server, so the elders'
`tools:` allowlist grants `mcp__mempalace__*` to *only* `grandfather`/`eve`. Confirm with
`claude mcp list` (look for `✔ Connected`). **The server only loads after a Claude Code restart**
— note this now; the user will restart at the end.

### 4. Backfill this project's history

**Derive the transcript directory** — do not ask the user for it (this is the fiddly step the
manual docs leave to them). Claude keys transcripts by the *directory* you ran Claude in, under
`~/.claude/projects/`, with `/` replaced by `-`:

```bash
# transcript dir = ~/.claude/projects/<cwd with every "/" turned into "-">
TDIR=~/.claude/projects/$(pwd | sed 's|/|-|g')
ls "$TDIR" >/dev/null 2>&1 || echo "no transcripts for this dir — nothing to backfill yet"
```

If the derived dir doesn't exist, this project has no Claude history here yet — say so, finish
the install/register, and tell the user to re-run `/shipkit:connect-memory` later once there are
conversations to mine.

Pick the **wing** name: `--wing` from `$ARGUMENTS`, else the repo/directory basename.

**Split first** (transcripts can be concatenated mega-files; `mine` wants per-session files):

```bash
mempalace split "$TDIR"
```

**Dry-run, then real** — always show the dry-run result before writing the index:

```bash
mempalace mine "$TDIR" --mode convos --wing <wing> --dry-run   # show the user what WOULD be filed
mempalace mine "$TDIR" --mode convos --wing <wing>             # then file it for real
```

Report what got filed (`mempalace status` shows the wing's drawer count).

### 5. Finish

Tell the user:
- ✅ what happened (installed / registered / backfilled `<wing>` with N drawers).
- 🔁 **Restart Claude Code** so the MemPalace server loads (only needed the first time it's registered).
- Then `grandfather`/`eve` will use it automatically for decision-history questions — try
  `/shipkit:ask why did we decide <X>?`. Nothing else changes: it's the *only* two subagents that
  can reach it, and its ~30 tools stay out of your main context until an elder calls one.

## Arguments

- `--wing <name>` — override the wing name (default: this project's directory basename).
- `--reinstall` — re-run install/register even if detection says they're done (for a broken setup).

## Notes

- **Safe to re-run.** Detection skips completed steps; `mine` is idempotent per the MemPalace docs.
- **Per-project backfill.** Install+register are once-per-machine; run the backfill (step 4) once
  in each project whose history you want recalled.
- **If it's not installed, nothing breaks** — the elders just fall back to git history for
  decision questions. This skill only *adds* capability. See [GUIDE.md](../../GUIDE.md) →
  *Episodic Memory* for wings/rooms, the recall-is-a-claim caveat, and repair.
