---
description: "Empathy-driven UI/UX design and review. TRIGGER when: user asks to build, design, or modify UI components, pages, or layouts. DO NOT TRIGGER when: editing non-UI code like models, services, or configs."
user-invocable: true
argument-hint: "[design <feature>|review|audit|improve <file>]"
context: fork
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

Apply the full review checklist — accessibility checks are BLOCKERS that gate everything else.
See @review-checklist.md for the complete 24-point checklist and report format.

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
