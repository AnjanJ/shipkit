---
paths:
  - "app/javascript/controllers/**"
  - "app/views/**/*.erb"
  - "app/views/**/*.turbo_stream.erb"
  - "app/components/**"
  - "app/frontend/controllers/**"
---
<!-- requires: rails -->
# Hotwire (Turbo + Stimulus)

## Pick the lightest tool that works
- **Turbo Drive** handles full-page navigation already — do not reimplement it with JS.
- **Turbo Frames** for a scoped region that navigates on its own. One frame, one concern.
- **Turbo Streams** only when a single response must update *several* disjoint regions, or when
  the update is pushed from the server (broadcast). A Stream that touches one region should
  have been a Frame.
- Reach for a Stimulus controller only when no server round-trip is involved (toggles, focus,
  clipboard, keyboard shortcuts). Anything that changes data goes through the server.

## Stimulus
- Small controllers, one responsibility, named after the behavior (`clipboard`, not `utils`).
- Use `static values`, `static targets`, `static outlets` — never `document.querySelector` or
  `getElementById` from inside a controller.
- Use `data-action` in the markup; never inline `onclick`/`onchange`.
- Clean up in `disconnect()` — timers, listeners, observers. Turbo caches and restores pages,
  so a leaked listener fires twice on the next visit.
- No global state in JS. If two controllers need to share, use an outlet or a server round-trip.

## Markup and caching
- Turbo caches a preview of every page. Mark transient UI (flash messages, open menus) with
  `data-turbo-cache="false"` or reset it on `turbo:before-cache`.
- With morphing enabled (`turbo_refreshes_with method: :morph`), give every dynamic element a
  stable `id` — morph matches on it. Avoid random ids in server-rendered markup.
- `turbo_stream_from` only for genuinely shared state; a per-user stream on every page is a
  connection leak.

## Testing
- Every Turbo flow gets a **system test** with a real driver — request specs do not exercise
  Turbo. Assert the resulting DOM, not the Stream payload.
- Assert on visible user-facing text/roles, not on frame ids or CSS classes.
- A Stimulus controller with logic worth testing is logic that probably belongs on the server.
