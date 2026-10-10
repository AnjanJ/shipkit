# React served by a host app (Rails or Phoenix: Inertia / Vite / jsbundling)
These apply when the server renders the shell and owns the data; in a standalone SPA, skip them.
- Components live under `app/frontend/` (Vite) or `app/javascript/` (jsbundling) — match what
  the project already uses; do not introduce a second root.
- Authentication, authorization and flash messages come from the server. A React component must
  never be the only thing preventing access.
- The asset build (`vite build` / `yarn build`) runs in CI and before the test suite — a green
  test run with a stale bundle proves nothing.
- Prefer server-driven state. Reach for client state only for genuinely ephemeral UI.
