# Field notes 5.2 — the owner's project again, after the machine plan's two sprints

> Sprint 28 (machine plan G10, G11). Written 2026-11-06 while running, from the commands and their
> output. §0 is S28-T1, an install question answered before the run; the run itself (S28-T2)
> follows in the shape of `field-notes-5.1.md`, section for section. **Nothing was fixed in this
> sprint**; every finding is an item under the ROADMAP's "Still open after Sprint 28", pointing
> back here. Spec: `.shipkit/specs/fifth-run/` (REQ-1 to REQ-11).

---

## 0. `--scope project`: which update moves it (S28-T1, G11)

`fifth-run/REQ-1` to `REQ-3`. PR #30's question: an install made with `--scope project`, updated
with `claude plugin update … --scope project` from outside its project and from inside it — which
works? Claude Code 2.1.318, 2026-11-06. No model call.

**How.** Every command ran with `CLAUDE_CONFIG_DIR` set to a scratch folder
(`$TMPDIR/s28c/config`), standard input from `/dev/null`, from one of four scratch folders: three
git repositories (`proj`, `proj2`, `proj3`) and `outside`, which is none of them. The marketplace
was this repository on GitHub, pinned by its tags: `claude plugin marketplace add
'AnjanJ/shipkit#v5.0.0'`, where both plugins read 5.0.0. Moving it to 5.1.0 meant changing
`"ref": "v5.0.0"` to `"v5.1.0"` in the scratch config's `settings.json` and
`plugins/known_marketplaces.json`, then `claude plugin marketplace update shipkit`. Editing those
files by hand is not documented; that it took is shown by the clone's `HEAD` (`73ce5d5`, `v5.1.0`)
and its three `"version": "5.1.0"` lines. Each command's output, exit status and the owner's two
checksums after it were logged to `$TMPDIR/s28c/log/`.

**Two methods that could not answer it,** each tried first under its own scratch config and set
aside (`fifth-run/design.md`, first record, amended):

- A marketplace added by local path (`$TMPDIR/s28`). Install exits 0, and `claude plugin list`
  reads `Read from: …/market/plugins/shipkit`: the plugin loads in place, so a version bump in the
  copy changes the install with no update. The plugin loading reference says so: relative-path
  plugins in a marketplace "you added from a local path" load in place, "whatever its version
  string says" (`code.claude.com/docs/en/plugins/loading.md`, "In-place and copied plugins",
  "Versions and updates").
- A local git repository by `file://` URL (`$TMPDIR/s28b`). `claude plugin marketplace add
  file://…/market` exits 1: "Invalid marketplace source format. Try: owner/repo, https://..., or
  ./path". The install page lists `owner/repo`, an `https://` clone URL and `git@host:path` as the
  git forms (`code.claude.com/docs/en/plugins/install.md`, "Add a marketplace").

**What each command did.** Versions are the ones `installed_plugins.json` in the scratch config
records after the command; it records one entry per plugin per project, with its `projectPath`.

| # | Where | Command | Exit | Output (the line that matters) | After it |
|---:|---|---|---:|---|---|
| 1 | `proj` | `claude plugin install shipkit@shipkit --scope project -y`, and `shipkit-workflows@shipkit` | 0, 0 | `Successfully installed plugin: shipkit@shipkit (scope: project)` | `proj` 5.0.0, copied to `cache/shipkit/<plugin>/5.0.0/`; `proj/.claude/settings.json` enables both |
| 2 | `outside` | `claude plugin list` | 0 | both rows `Version: 5.0.0`, `Scope: project`, `Status: ✘ disabled` | — |
| 3 | `outside` | pin to `v5.1.0`; `claude plugin marketplace update shipkit` | 0 | `Successfully updated marketplace: shipkit` | the catalogue offers 5.1.0; `proj` still 5.0.0 |
| 4 | `outside` | `claude plugin update shipkit@shipkit --scope project -y`, and `shipkit-workflows@shipkit` | 0, 0 | `Plugin "shipkit" updated from 5.0.0 to 5.1.0 for scope project (/private/var/…/s28c/proj)` | `proj` 5.1.0 |
| 5 | `proj2`, `proj3` | pin back to `v5.0.0`, marketplace update; install both in each, `--scope project -y`; pin to `v5.1.0`, marketplace update | 0 each | `Successfully installed plugin: … (scope: project)` | `proj` 5.1.0, `proj2` 5.0.0, `proj3` 5.0.0; catalogue 5.1.0 |
| 6 | `proj2` | `claude plugin update <plugin>@shipkit --scope project -y`, both | 0, 0 | `updated from 5.0.0 to 5.1.0 for scope project (/private/var/…/s28c/proj2)` | `proj2` 5.1.0; **`proj3` still 5.0.0** |
| 7 | `outside` | the same two updates | 0, 0 | **`shipkit is already at the latest version (5.1.0).`** | **`proj3` still 5.0.0** |
| 8 | `proj3` | `claude plugin list` | 0 | six rows, two per project, none naming its project: four `5.1.0`, two `5.0.0`, all `✔ enabled` | — |
| 9 | `proj3` | the same two updates | 0, 0 | `updated from 5.0.0 to 5.1.0 for scope project (/private/var/…/s28c/proj3)` | all three 5.1.0 |

**The owner's files.** `shasum -a 256` of `~/.claude/plugins/installed_plugins.json`
(`b1b8f590…bb604`) and `known_marketplaces.json` (`31b7f56f…342a4`), taken before the first
command and after every one of the three folders' commands: unchanged throughout (`REQ-3`).
`~/.claude/settings.json` was last written 2026-11-05 18:00, before T1 began.

**The answer.**

1. **From inside the project, `--scope project` moves that project's install and only that one**
   (rows 6, 9). This always worked.
2. **From outside, it moves an install only when it happens to pick the right one.** With one
   project-scope install it moved it and named the project (row 4). With three, it read the first
   recorded one (`proj`, current), said "already at the latest version" and exited 0, while
   `proj3` stayed on 5.0.0 (row 7). A user reading that line would think the update had worked.
3. **`claude plugin list` cannot tell a reader which project is behind** (row 8): it lists every
   project's install, with no path, and from `outside` marks each row `disabled` (row 2).

So the README's and the guide's rule for `Scope: local`, "the same two lines with that scope, from
inside that project", is the one that works for `Scope: project` too, and both now say so, with
what goes wrong from outside. Not tried here: whether `--scope local` from outside has the same
first-install shape; the 5.1.0 release saw local installs move only from inside
(`CHANGELOG.md`, `[Unreleased]`, Docs).

**Left in place, for the owner's yes:** `$TMPDIR/s28`, `$TMPDIR/s28b`, `$TMPDIR/s28c` (configs,
marketplace copies, scratch projects, logs).
