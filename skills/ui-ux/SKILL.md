---
description: "Design and review UI/UX — empathy-driven, modern, accessible, zero-generic output. Auto-invocable for UI work."
user-invocable: true
argument-hint: "[design <feature>|review|audit|improve <file>]"
---

# /ui-ux — Empathy-Driven UI/UX Design

Mode: $ARGUMENTS (default: contextual — auto-detect what's needed)

**Accessibility is the foundation.** If any output of this skill is not accessible, the skill has failed. See `ui-ux-standards` knowledge base Section 1.

**Detect the platform** from the file: `.swift` = iOS/SwiftUI, `.kt` = Android/Compose, `.dart` = Flutter, `.native.tsx` = React Native, `.html`/`.vue`/`.svelte`/`.erb`/`.tsx`/`.jsx` = Web. Use platform-native APIs. See `ui-ux-standards` Section 5 for platform navigation patterns.

## Before Anything: Understand the User

1. **Who is the user?** Check CLAUDE.md, existing UI code, and ask if unknown. Include users with disabilities — they are not edge cases.
2. **What is their goal?** Not "click this button" — the real goal behind the action.
3. **What's the context?** Mobile? Desktop? Both? Assistive technology? Rushed? Relaxed? First-time? Power user?
4. **What's the emotional state?** Onboarding (curious), error (frustrated), checkout (anxious), success (happy).

If you don't know the user, design for the most constrained case: stressed, one-handed, slow connection, using assistive technology, unfamiliar with the product.

## Mode: Design a New Feature

When designing new UI (or asked to build a feature with a UI component):

### Step 1: User Flow First (before any code)
- Map the flow: What triggers this? What steps? What's the happy path? What can go wrong?
- Count the clicks. Can any step be eliminated? Can two steps merge?
- For each step: what does the user NEED to see? What can be hidden until needed?
- **A11y:** Can a keyboard-only user complete this flow? Can a screen reader user understand each step?

### Step 2: Structure with Accessible Semantics
Before visuals, establish accessible structure using platform-native APIs (see `ui-ux-standards` Section 1). Plan focus order, modal/sheet management, escape/back to dismiss. Structure comes before visual design because structure IS accessibility.

### Step 3: States — Design ALL of Them
Every UI element has at minimum 5 states:
1. **Empty** — guidance + CTA, never blank. Announce to screen reader.
2. **Loading** — skeleton screen (never spinner). Announce to assistive tech.
3. **Partial** — show what you have, indicate more loading.
4. **Ideal** — full data. This is 20% of the job.
5. **Error** — never blame user. Explain, offer fix, reassure data safe. Associate with inputs. Focus the error.

Also: **Success** (celebrate), **Offline** (cache aggressively on mobile), **Permission denied** (explain why, offer path to grant).

### Step 4: Visual Design
- Visual hierarchy: what should the eye land on first? Generous whitespace.
- No generic templates — design must fit the brand. See `ui-ux-standards` Section 4.
- Platform type systems, semantic color tokens, 4.5:1 contrast. Check both themes.
- Focus indicators on every interactive element. Reduced-motion alternatives for animations.
- Respect platform conventions: iOS feels like iOS, Android feels like Android.

### Step 5: Mobile + Touch
- Thumb zone (bottom 1/3), platform touch targets, safe areas, platform navigation conventions.
- Works on smallest target device? Inputs optimized? Drag alternatives? One-thumb completable?

### Step 6: Performance
- Skeleton screens, optimistic UI, lazy loading, no layout shift. See `ui-ux-standards` Section 7.
- Mobile: 60fps, no main thread blocking, platform image caching.

## Mode: Review Existing UI

When reviewing UI code (triggered by `/ui-ux review` or auto-detected):

### Checklist (accessibility checks are BLOCKERS — they gate everything else)

**Accessibility (if ANY fail, verdict is BLOCKED — fix before evaluating anything else):**
| # | Check | Severity |
|---|-------|----------|
| 1 | Semantic structure? (Web: `<button>`/`<nav>`, iOS: a11y traits, Android: semantics roles, Flutter: Semantics widget, RN: a11y roles) | BLOCKER |
| 2 | Keyboard/switch control navigable? Every action reachable? | BLOCKER |
| 3 | Focus indicators visible on every interactive element? | BLOCKER |
| 4 | Contrast ratios met? (4.5:1 text, 3:1 UI components — both themes) | BLOCKER |
| 5 | All images/icons have meaningful labels (or marked decorative)? | BLOCKER |
| 6 | All form inputs have visible labels? | BLOCKER |
| 7 | Touch targets >= 44x44 pt (iOS) / 48x48 dp (Android) with adequate spacing? | BLOCKER |
| 8 | Reduced motion respected on all animations? (platform-appropriate check) | BLOCKER |
| 9 | No focus traps? (can navigate away from every component) | BLOCKER |
| 10 | Heading/section hierarchy correct? | MAJOR |
| 11 | Color never the ONLY indicator? (icons/text paired) | MAJOR |
| 12 | Works with max text scaling? (Web: 200% zoom, iOS: max Dynamic Type, Android: max font size) | MAJOR |
| 13 | Dynamic content announced to assistive technology? (Web: aria-live, mobile: platform announcements) | MAJOR |
| 14 | Drag actions have tap-based alternatives? | MAJOR |

**Empathy, Design, and UX (evaluated only after a11y passes):**
| # | Category | Check | Severity |
|---|----------|-------|----------|
| 15 | Empathy | All 5 states handled? (empty, loading, error, success, ideal) | BLOCKER |
| 16 | Empathy | Error messages helpful, not blaming? Errors associated with inputs? | MAJOR |
| 17 | Empathy | Empty states provide guidance + call to action? | MAJOR |
| 18 | Friction | Primary task completable in minimum steps? | MAJOR |
| 19 | Visual | Clear visual hierarchy? Sufficient whitespace? | MAJOR |
| 20 | Visual | Looks unique to the product, not a generic template? | MINOR |
| 21 | Mobile | Primary actions in thumb zone? Works on smallest target device? Safe areas respected? | MAJOR |
| 22 | Perf | Skeleton screens for loading? (not spinners) | MAJOR |
| 23 | Perf | Images optimized? No layout shift? | MAJOR |
| 24 | Trust | No dark patterns? Cancellation as easy as signup? | BLOCKER |

### Report Format
```
UI/UX Review — [component/feature name]

Accessibility Gate: PASS / BLOCKED (X of 14 a11y checks passed)
[If BLOCKED: list failures — these must be fixed before any other evaluation]

Full Findings:
| # | Severity | Category | Location | Issue | Suggested Fix |
|---|----------|----------|----------|-------|---------------|

Score: X/24 checks passed
Verdict: BLOCKED (any a11y BLOCKER fails) / EXCELLENT (22+) / GOOD (18-21) / NEEDS WORK (14-17) / POOR (<14)
```

## Mode: Improve Existing UI

When asked to improve a specific file or component:
1. Read the current implementation
2. Run the review checklist silently
3. Identify the top 3 highest-impact improvements
4. Implement them — don't just suggest
5. Show before/after for each change
6. Run tests after changes

## Creative Principles

- **Familiar but fresh.** Use conventions for interaction (buttons, forms, navigation) but find originality in aesthetics, transitions, and personality.
- **Emotion over decoration.** Every visual choice should make the user FEEL something. Confident? Calm? Delighted? If it's just "pretty," it's decoration.
- **The details ARE the design.** The hover state, the error message copy, the loading animation, the empty state illustration — these are where users form their opinion.
- **Test the sad path.** Everyone designs for happy-path first-time-user with perfect data on a fast connection. Test the returning user with messy data on a slow phone. That's reality.
