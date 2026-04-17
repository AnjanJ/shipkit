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
- See `ui-ux-standards` knowledge base for full criteria and platform patterns.
