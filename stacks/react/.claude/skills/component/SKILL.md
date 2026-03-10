---
description: "Scaffold a React component with TypeScript types, tests, and optional Storybook story"
user-invocable: true
disable-model-invocation: true
argument-hint: "[ComponentName]"
---

# /component — Scaffold React Component

Component name: $ARGUMENTS

## Project Context
!`cat package.json 2>/dev/null | grep -E '"(react|vue|svelte|next|vite|storybook|tailwind)"' | head -10 || echo "no package.json found"`

## Detection

1. **Check for TypeScript:** `tsconfig.json` exists → use `.tsx`, else `.jsx`
2. **Check for Storybook:** `.storybook/` directory exists → create story file
3. **Check for CSS approach:**
   - `tailwind.config` → use Tailwind classes (no CSS file)
   - `*.module.css` in components → create CSS module
   - `styled-components` in package.json → use styled-components
4. **Check test framework:** Jest (`jest.config`) or Vitest (`vitest.config`)
5. **Check component directory pattern:** read an existing component to match structure

## Files Created

### Component File
```
src/components/<ComponentName>/<ComponentName>.tsx
```
- Functional component with explicit Props interface
- Named export (not default — easier to refactor)
- Read an existing component first — match the project's style exactly

### Test File
```
src/components/<ComponentName>/<ComponentName>.test.tsx
```
- Uses `@testing-library/react` (render, screen, userEvent)
- Tests: renders without crashing, displays expected content, handles user interaction
- Read an existing test first — match the project's patterns

### Storybook Story (if Storybook detected)
```
src/components/<ComponentName>/<ComponentName>.stories.tsx
```
- Default story with typical props
- Variant stories for different states (loading, error, empty)

### CSS Module (if using CSS modules)
```
src/components/<ComponentName>/<ComponentName>.module.css
```

### Index File (if project uses barrel exports)
```
src/components/<ComponentName>/index.ts
```
- `export { ComponentName } from './ComponentName'`

## Dependency Verification (mandatory)

If this component requires a new npm package:
1. Read the package's documentation first (WebFetch its README or docs site)
2. Check the latest stable version: `npm view <package> version`
3. Use caret constraint (default): `"^X.Y.Z"` — never `*` or `latest`
4. Run `npm install && {{TEST_COMMAND}}` — full suite, not just the new test
5. Run `npm audit` for security advisories
6. Run `npx tsc --noEmit` to verify no type errors introduced

## After Scaffolding

1. Run the component test: `{{TEST_COMMAND}} <test_path>`
2. Run type check: `npx tsc --noEmit`
3. Report what was created
