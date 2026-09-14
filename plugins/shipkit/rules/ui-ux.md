---
paths:
  # Web
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.vue"
  - "**/*.svelte"
  - "**/*.html"
  - "**/*.erb"
  - "**/*.haml"
  - "**/*.slim"
  - "**/*.heex"
  - "**/*.css"
  - "**/*.scss"
  - "**/*.sass"
  - "**/*.less"
  # iOS / SwiftUI
  - "**/*View.swift"
  - "**/*Screen.swift"
  - "**/ContentView.swift"
  - "**/*.storyboard"
  - "**/*.xib"
  # Android / Jetpack Compose
  - "**/*Screen.kt"
  - "**/*Composable.kt"
  - "**/ui/**/*.kt"
  - "**/theme/*.kt"
  # Flutter
  - "**/lib/screens/**/*.dart"
  - "**/lib/widgets/**/*.dart"
  - "**/lib/pages/**/*.dart"
  - "**/lib/theme/**/*.dart"
  # React Native
  - "**/*.native.tsx"
  - "**/*.ios.tsx"
  - "**/*.android.tsx"
  # Shared patterns
  - "**/components/**"
  - "**/views/**"
  - "**/templates/**"
  - "**/pages/**"
  - "**/layouts/**"
  - "**/styles/**"
  - "**/screens/**"
  - "**/widgets/**"
  - "**/navigation/**"
---

# UI/UX Standards

- Detect platform from file extension. Use platform-native APIs.
- Accessibility is non-negotiable: semantic structure, 4.5:1 contrast, focus indicators, text scaling, reduced motion.
- Handle all states: empty, loading (skeleton), error (never blame user), success.
- Never: dark patterns, autoplay, `outline: none` without replacement, generic unstyled templates.

## Accessibility baseline (WCAG 2.2 AA)

Apply these without being asked; they are the floor, not the ceiling.

- **Semantic structure first** — real headings in order, landmarks, lists for lists. A `div`
  with a click handler is not a button.
- **Every control has an accessible name** — visible label, `aria-label`, or `aria-labelledby`.
  Icon-only buttons always need one.
- **Keyboard reach** — everything interactive is focusable and operable by keyboard, in a
  sensible order, with a visible focus indicator. Never remove the outline without replacing it.
- **Contrast** — 4.5:1 for body text, 3:1 for large text and meaningful UI boundaries.
- **Target size** — at least 24x24 CSS px, or spaced to compensate.
- **Motion and orientation** — honour `prefers-reduced-motion`; never lock orientation; no
  autoplaying motion the user cannot stop.
- **Errors name the field and the fix**, in text, never by colour alone.
- **No layout shift** on load — reserve space for images and async content.

For design direction beyond the baseline (visual systems, typography, aesthetic choices),
the official `frontend-design` plugin covers it.
