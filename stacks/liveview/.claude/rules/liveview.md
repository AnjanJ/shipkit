---
paths:
  - "lib/*_web/live/**"
  - "lib/*_web/components/**"
  - "**/*.heex"
---
<!-- requires: elixir -->
# Phoenix LiveView

## The lifecycle is the source of most bugs
- **`mount/3` runs twice** — once for the dead HTTP render, once for the connected socket.
  Guard anything expensive or stateful with `if connected?(socket)`: PubSub subscriptions,
  timers, presence tracking, and any process registration.
- Put URL-derived state in `handle_params/3`, not `mount/3` — it is what runs on
  `push_patch`/`live_patch`.
- `push_patch` stays in the same LiveView; `push_navigate` mounts a new one. Choose
  deliberately; a `push_navigate` where a patch belonged throws away socket state.

## Assigns and memory
- Use `stream/4` for collections. A list in an assign is held in memory for the life of the
  process and re-sent on every diff.
- Keep assigns small and flat. Never assign a full Ecto struct with preloaded associations
  when the template reads three fields.
- Use `assign_new/3` for values shared between the dead and connected renders.
- Never assign raw params or anything user-controlled without casting it first.

## Components
- Prefer **function components** (`attr`/`slot`) over nested LiveViews. A nested LiveView is a
  separate process with its own lifecycle — use it only for genuinely independent state.
- Declare `attr` and `slot` with types and `required:` — the compiler checks call sites.
- Keep `.heex` free of business logic: no `Repo` calls, no multi-clause `case` on domain state.
  Compute in the LiveView, render in the template.

## Events and PubSub
- Prefer `phx-*` bindings over custom JS hooks. Use a hook only for browser APIs LiveView
  cannot reach (charts, maps, clipboard, file APIs).
- Every `handle_event/3` validates its payload — the client can send anything.
- Subscribe to PubSub in `mount/3` under `connected?`, and scope the topic (per-user or
  per-resource). A global topic fans out to every connected socket.
- `handle_info/2` must tolerate messages arriving after the relevant state has changed.

## Testing
- `Phoenix.LiveViewTest` for every interaction: `render_click`, `render_submit`,
  `render_change`, and `live_isolated` for components.
- Assert on rendered output the user can see, not on socket assigns.
- Test the disconnected render too (`get(conn, path)`) — it is what crawlers and the first
  paint receive.
