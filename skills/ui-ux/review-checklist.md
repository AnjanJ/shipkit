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
