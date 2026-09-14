# UI/UX Standards — Advanced Reference

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
