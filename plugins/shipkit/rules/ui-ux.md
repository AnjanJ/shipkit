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

Accessibility baseline (WCAG 2.2 AA), applied without being asked. Every screen handles its
empty, loading and error states, and the error never blames the user.

- **Keyboard reach** — everything interactive is focusable and operable by keyboard, in a
  sensible order, with a visible focus indicator. Never remove the outline without replacing it.
- **Contrast** — 4.5:1 for body text, 3:1 for large text and meaningful UI boundaries.
- **Target size** — at least 24x24 CSS px, or spaced to compensate.
- **Motion and orientation** — honour `prefers-reduced-motion`; never lock orientation; no
  autoplaying motion the user cannot stop.
- **Errors name the field and the fix**, in text, never by colour alone.
- **No layout shift** on load — reserve space for images and async content.
