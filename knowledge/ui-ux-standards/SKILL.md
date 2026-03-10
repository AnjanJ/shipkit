---
description: "UI/UX design standards: empathy-driven design, modern patterns, accessibility, performance as UX, emotional design"
user-invocable: false
---

# UI/UX Design Standards

Reference knowledge base for UI files. Accessibility is the foundation — not a phase. Empathize first, design second. Reduce friction ruthlessly.

---

## 1. Accessibility — The Foundation

Design for the widest range of human ability. An inaccessible UI is a broken UI. If it's not accessible, it's not done.

### WCAG 2.2 AA — The Minimum Standard
- **2.4.11 Focus Not Obscured:** Focused elements must never be hidden by sticky headers, footers, or modals.
- **2.5.7 Dragging Movements:** All drag functionality must have a single-pointer alternative (click-based).
- **2.5.8 Target Size:** Pointer targets at least 24x24 CSS px. Apple recommends 44x44 pt. Android: 48x48 dp.
- **3.2.6 Consistent Help:** Help mechanisms in the same relative position across pages.
- **3.3.7 Redundant Entry:** Never ask users to re-enter info already provided in the same flow.
- **3.3.8 Accessible Authentication:** No cognitive tests (CAPTCHAs, puzzles) as the sole login method.

### Structural Accessibility
- **Semantic structure is non-negotiable.** Web: `<button>`, `<nav>`, `<main>`. iOS: `.accessibilityLabel()`, `.accessibilityAddTraits(.isButton)`. Android: `Modifier.semantics {}`, `role = Role.Button`. Flutter: `Semantics(label:, button: true)`. RN: `accessibilityLabel`, `accessibilityRole`.
- **Heading hierarchy:** No skips. One `<h1>` per page. Mobile: iOS `.accessibilityAddTraits(.isHeader)`, Android `heading()`, Flutter `Semantics(header: true)`.
- **Landmarks:** Web: `<nav>`, `<main>`, `<aside>`, `<footer>`. Screen reader users navigate by landmarks.
- **Language:** `<html lang="en">` always set. iOS: `accessibilityLanguage`. Android: `LocaleList`.

### Visual Accessibility
- **Contrast:** 4.5:1 for normal text, 3:1 for large text and UI components. Test both light and dark mode.
- **Color independence:** Never color-only indicators. Pair with icons, text, or border changes.
- **Focus indicators:** Visible on every interactive element. Never `outline: none` without replacement. iOS: `.focusable()`. Android: `Modifier.focusable()`.
- **Text scaling:** Web: `rem`/`em`, never `px`. iOS: Dynamic Type (`.font(.body)`, `@ScaledMetric`). Android: `sp` + M3 `TextTheme`. Flutter: `TextScaler` + `Theme.textTheme`. RN: `allowFontScaling={true}`. Never hardcode font sizes on any platform.
- **Dark mode:** Use platform semantic colors. iOS: `Color(.systemBackground)`. Android: M3 `colorScheme`. Flutter: `ThemeData.dark()`.

### Interaction Accessibility
- **Keyboard / switch control:** Every element reachable. Logical focus order. Escape closes modals. iOS: `.focusable()`, `.accessibilityAction()`. Android: `Modifier.focusable()`, `FocusRequester`. Flutter: `FocusNode`, `FocusTraversalGroup`.
- **No focus traps.** Logical reading order matches visual order.
- **Touch targets:** 44x44 pt (Apple) / 48x48 dp (Android/Flutter) minimum with adequate spacing.
- **Drag alternatives:** Every drag interaction must have a tap-based alternative.

### Motion Accessibility
- **Reduced motion:** Web: `prefers-reduced-motion`. iOS: `@Environment(\.accessibilityReduceMotion)`. Android: `ANIMATOR_DURATION_SCALE`. Flutter: `MediaQuery.disableAnimationsOf(context)`. RN: `useReducedMotion()`.
- **Static alternatives** for any animation that conveys information. No autoplay. No flashing >3 times/sec.

### Content Accessibility
- **Images:** Meaningful alt text. Decorative: Web `alt=""`, iOS `.accessibilityHidden(true)`, Android `clearAndSetSemantics {}`, Flutter `ExcludeSemantics`.
- **Forms:** Visible labels (never placeholder-only). Errors associated with inputs: Web `aria-describedby`, iOS `.accessibilityHint()`, Android `semantics { error }`, Flutter `Semantics(hint:)`.
- **Links/Actions:** Descriptive text ("View order history"), never "click here."
- **Dynamic content:** Web: `aria-live`. iOS: `UIAccessibility.post(.announcement)`. Android: `LiveRegion.Polite`. Flutter: `Semantics(liveRegion: true)`. RN: `accessibilityLiveRegion="polite"`.

### ARIA (Web only)
Don't use ARIA if semantic HTML can do the job. Don't change native semantics unless you must. All ARIA controls must be keyboard operable.

### Testing Protocol
1. **Keyboard/switch control** — tab through entire flow without mouse
2. **Screen reader** — VoiceOver (iOS/Mac), TalkBack (Android), NVDA (Windows)
3. **Text scaling** — max Dynamic Type / font size / 200% zoom
4. **Contrast** — check both themes with a contrast checker
5. **Reduced motion** — enable OS setting, verify animations stop
6. **Color blindness** — simulator check, all info still perceivable

---

## 2. Empathy-First Design

Before writing any UI code, answer these:
- **Who** is the user? (age, tech comfort, context, emotional state)
- **What** are they trying to accomplish? (the real goal, not what they clicked)
- **Where** are they? (mobile on a bus? Desktop at work? Assistive technology?)
- **How** are they feeling? (frustrated? Excited? Rushed? Confused?)

Design for the stressed, distracted, one-handed user on a slow connection. If it works for them, it works for everyone.

## 3. Interaction Design — Minimum Friction

- Primary actions reachable in 1-2 taps. Bottom nav over hamburger menus. Auto-save over manual save.
- **Progressive disclosure:** Show only what's needed now. Reveal complexity on demand.
- **Direct manipulation:** Inline editing > "click edit, change, save." Swipe gestures > finding buttons. Always provide visible alternatives for gesture-based actions.
- **Smart defaults:** Pre-select most common option (never purchases/opt-ins). Remember preferences. Auto-detect context.

## 4. Visual Design — Beautiful But Not Generic

### Layout
- **Content-first:** Set breakpoints where content breaks, not at device widths.
- **Web:** Container queries for modular components. CSS Grid for 2D layouts, Flexbox for 1D.
- **iOS/SwiftUI:** `LazyVGrid`/`LazyHGrid`, `ViewThatFits`, `GeometryReader` for adaptive layouts. Use `@Environment(\.horizontalSizeClass)` for compact/regular adaptation.
- **Android/Compose:** `LazyVerticalGrid`, `BoxWithConstraints`, adaptive layouts with `WindowSizeClass`. Use `NavigationSuiteScaffold` for responsive navigation.
- **Flutter:** `LayoutBuilder`, `MediaQuery`, `Wrap`, `GridView.builder` for responsive layouts.
- **Fluid design:** Web: `clamp()`, `min()`, `max()`. Mobile: use system spacing tokens and adaptive layout APIs.
- **Whitespace is a feature.** Generous spacing reduces cognitive load. Cramped layouts feel cheap.
- **Visual hierarchy:** Size, weight, color, and spacing guide the eye. Users scan in F/Z patterns.

### Typography
- Body: minimum 16px/16pt. Line height: 1.5. Line length: 50-75 chars.
- Use platform type systems (see text scaling in Section 1). Never hardcode font sizes.
- Variable fonts for performance (one file, all weights).

### Color
- **Semantic tokens:** Name by purpose (`color.action-primary`), not value (`blue-500`).
- **Dark mode:** 3+ surface levels, no pure #000. Use platform semantic colors (see Section 1).
- Never color-only indicators. Pair with icons/text for colorblind users.

### Avoiding Generic Design
- Study the brand's personality BEFORE choosing a design direction.
- Mix unexpected but harmonious elements: a serious financial app with warm, human illustrations.
- Custom micro-interactions over off-the-shelf component libraries used as-is.
- Consistent design language > trendy individual elements.
- If it looks like a default Bootstrap/Material/Cupertino template with no customization — rethink the design direction.
- Unique doesn't mean unusable. Innovation in aesthetics, convention in interaction.

## 5. Platform-Specific Navigation & Patterns

### iOS / SwiftUI
- **Navigation:** `NavigationStack` (push/pop) for hierarchical flows. `TabView` for top-level sections (max 5 tabs). Avoid hamburger menus — use tab bar.
- **System patterns:** Pull-to-refresh, swipe-to-delete, long-press context menus, share sheets.
- **Safe areas:** Always respect `safeAreaInsets` — never place content behind the Dynamic Island, home indicator, or status bar.
- **Haptics:** Use `UIFeedbackGenerator` for tactile feedback on important actions (`.impact`, `.notification`, `.selection`).

### Android / Jetpack Compose
- **Navigation:** `NavigationSuiteScaffold` for adaptive navigation (bottom bar on phones, rail on tablets, drawer on desktop). Material 3 `NavigationBar` for top-level destinations.
- **System patterns:** Material 3 bottom sheets, snackbars for undo, FABs for primary actions, swipe-to-dismiss.
- **Edge-to-edge:** Enable edge-to-edge display, handle insets with `WindowInsets`. Never place interactive content behind system bars.
- **Predictive back:** Support the predictive back gesture — use `BackHandler` and `predictiveBackProgress`.

### Flutter
- **Navigation:** `GoRouter` or `Navigator 2.0` for declarative routing. `BottomNavigationBar` / `NavigationBar` (M3) for top-level sections.
- **Adaptive design:** Use `platform` checks for iOS vs Android feel, or use `adaptive` constructors: `Switch.adaptive()`, `Slider.adaptive()`.
- **Platform conventions:** Respect platform scrolling physics (`BouncingScrollPhysics` on iOS, `ClampingScrollPhysics` on Android).
- **Safe areas:** Use `SafeArea` widget. `MediaQuery.paddingOf(context)` for manual inset handling.

### React Native
- **Navigation:** React Navigation with `@react-navigation/bottom-tabs` for tab bars, `@react-navigation/native-stack` for native push/pop.
- **Platform adaptation:** `Platform.select()` for platform-specific values. Use platform-specific file extensions (`.ios.tsx`, `.android.tsx`) for major divergences.
- **Native feel:** Use `react-native-gesture-handler` + `react-native-reanimated` for 60fps gestures. Platform-appropriate haptics via `react-native-haptic-feedback`.
- **Safe areas:** `react-native-safe-area-context` — wrap root in `SafeAreaProvider`, use `SafeAreaView` or `useSafeAreaInsets()`.

## 6. Mobile-First Design

- **Thumb zone:** Primary actions in bottom 1/3. Critical buttons anchored to bottom. Bottom tab bar > hamburger.
- **Touch:** Targets per Section 1. Swipe for common actions, long-press for secondary. Test one-handed.
- **Content:** Front-load key info in first viewport. Minimize typing (selectors, toggles, voice). Correct keyboard type (`inputmode`).

## 7. Performance as UX

- **Skeleton screens** over spinners. iOS: `redacted(reason: .placeholder)`. Flutter: `Shimmer`. Match layout to content structure.
- **Optimistic UI** for common actions. Instant feedback for every action. Progress indicators for >1s operations.
- **Budgets:** Web: LCP < 2.5s, CLS < 0.1, INP < 200ms. Mobile: 60fps, cold launch < 2s. All: render < 100ms after data.
- **Techniques:** Lazy load below-fold. Platform lazy lists (`LazyVStack`, `LazyColumn`, `ListView.builder`). Platform image caching (`AsyncImage`, `coil`, `cached_network_image`). Code split. Prefetch next actions. Minimize main thread work on mobile.

## 8. Emotional Design

- **Key moments:** Onboarding (warm, max 3-4 screens, skip visible). Empty states (guidance + CTA, never blank). Success (celebrate). Error (never blame, offer fix, reassure data safe). Loading (skeleton, not spinner).
- **Microcopy:** Helpful friend, not robot. "We" for errors, "you" for successes. Be specific ("needs a number" > "invalid").
- **Trust:** Undo > "Are you sure?" Transparent data practices. Consistent behavior.

## 9. Anti-Patterns

- **Dark patterns:** No confirmshaming, hidden costs, preselected opt-ins, roach motels. Cancellation as easy as signup.
- **Cognitive overload:** Max 5-7 options. No walls of text. No modal stacking. Group settings by task.
- **UX sins:** No autoplay, no popups on load, no requiring account before value, no disabling back, no generic spinners, no mystery meat nav, no form fields clearing on error.
- **Mobile:** No main thread blocking. No ignoring safe areas. No conflicting with system gestures. No upfront permission requests. No ignoring platform conventions.
