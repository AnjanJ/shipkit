# React Conventions
- Functional components only — no class components
- Never use array index as key in lists
- Minimize useEffect — prefer derived state and event handlers
- Co-locate component, test, and styles in the same directory
- Extract custom hooks for reusable stateful logic
- Use TypeScript interfaces for component props
- Prefer controlled components over uncontrolled
- Avoid prop drilling — use context or composition

## Inside a Rails app (Inertia / Vite / jsbundling)
- Components live under `app/frontend/` (Vite) or `app/javascript/` (jsbundling) — match what
  the project already uses; do not introduce a second root.
- **Inertia props are the API contract.** The controller decides what the page receives; do not
  fetch the same data again from the component. Shape props in the controller or a serializer,
  not in `useEffect`.
- **Routing stays in Rails.** No client-side router duplicating `config/routes.rb`. Use Inertia
  links/visits so the server remains the source of truth for URLs.
- Authentication, authorization and flash messages come from the server. A React component must
  never be the only thing preventing access.
- The asset build (`vite build` / `yarn build`) runs in CI and before the test suite — a green
  test run with a stale bundle proves nothing.
- Prefer server-driven state. Reach for client state only for genuinely ephemeral UI.
