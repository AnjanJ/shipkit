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

# UI/UX Standards — Auto-Applied

**Detect the platform** from the file: `.swift` = iOS/SwiftUI, `.kt` = Android/Compose, `.dart` = Flutter, `.native.tsx`/`.ios.tsx`/`.android.tsx` = React Native, `.html`/`.vue`/`.svelte`/`.erb` = Web. Use platform-native APIs — don't suggest web patterns for mobile or vice versa.

**Accessibility is the foundation.** An inaccessible UI is a broken UI. Use semantic structure, visible focus indicators, sufficient contrast (4.5:1 text, 3:1 UI), platform text scaling, and reduced motion support. See the `ui-ux-standards` knowledge base for platform-specific APIs.

**Design for the stressed user.** Handle ALL states: empty, loading (skeleton screens), error (never blame the user), success. Minimize clicks. Progressive disclosure. Smart defaults.

**Never:**
- Dark patterns (confirmshaming, hidden costs, preselected opt-ins)
- Autoplay audio/video, popups on load, mystery meat navigation
- Form fields that clear on validation error, generic spinners
- `outline: none` without a visible focus replacement
- Ignoring safe areas, conflicting with system gestures, requesting all permissions upfront
- Generic template look (unstyled Bootstrap/Material/Cupertino)

See the `ui-ux-standards` knowledge base for detailed criteria, platform patterns, and review checklist.
