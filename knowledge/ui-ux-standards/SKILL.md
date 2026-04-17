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

For interaction design, visual design, platform patterns, mobile-first, performance, emotional design, and anti-patterns (sections 3-9), read `reference.md` in this knowledge base directory.
