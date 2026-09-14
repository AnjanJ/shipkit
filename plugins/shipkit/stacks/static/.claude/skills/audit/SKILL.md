---
description: "Audit static site for SEO, accessibility, performance, and broken links"
user-invocable: true
argument-hint: "[seo|a11y|perf|links|all]"
---

# /audit — Static Site Audit

Audit HTML/CSS/JS pages for quality issues.

Audit scope: $ARGUMENTS (default: `all`)

## Categories

### SEO Audit
- [ ] Every page has a unique `<title>` (50-60 characters)
- [ ] Every page has a `<meta name="description">` (150-160 characters)
- [ ] Open Graph tags present (`og:title`, `og:description`, `og:image`, `og:url`)
- [ ] Twitter Card tags present (`twitter:card`, `twitter:title`, `twitter:description`)
- [ ] JSON-LD structured data (Organization, WebSite, or appropriate type)
- [ ] `sitemap.xml` exists and lists all pages
- [ ] `robots.txt` exists
- [ ] Canonical URLs set (`<link rel="canonical">`)
- [ ] Heading hierarchy (`h1` → `h2` → `h3`, no skips, one `h1` per page)
- [ ] Descriptive link text (no "click here" or "read more")

### Accessibility (a11y) Audit
- [ ] All `<img>` tags have `alt` attributes (decorative images use `alt=""`)
- [ ] All form inputs have associated `<label>` elements
- [ ] Color contrast ratio meets WCAG AA (4.5:1 for text, 3:1 for large text)
- [ ] Page is keyboard navigable (tab order, focus indicators)
- [ ] ARIA attributes used correctly (not overused)
- [ ] Skip navigation link present
- [ ] Language attribute set (`<html lang="en">`)
- [ ] No auto-playing media

### Performance Audit
- [ ] Images optimized (WebP, appropriate dimensions, lazy-loaded)
- [ ] CSS and JS minified (in production)
- [ ] No render-blocking resources (async/defer on scripts)
- [ ] Total page weight under 1MB (ideally under 500KB)
- [ ] No unused CSS (check with coverage tools)
- [ ] Fonts: `font-display: swap`, subset if possible
- [ ] Caching headers configured (for deployed sites)

### Link Audit
- [ ] No broken internal links (href points to existing file)
- [ ] External links use `target="_blank" rel="noopener noreferrer"`
- [ ] No links to HTTP (should be HTTPS)
- [ ] Relative paths used for internal links

## Report

| # | Category | Severity | File:Line | Issue | Fix |
|---|----------|----------|-----------|-------|-----|
| 1 | SEO | MAJOR | index.html:1 | Missing meta description | Add `<meta name="description" content="...">` |
| ... | ... | ... | ... | ... | ... |

**Score:** X/Y checks passed

**Verdict:** EXCELLENT (90%+) / GOOD (75-89%) / NEEDS WORK (50-74%) / POOR (<50%)

## After Fixes

If issues were fixed:
1. Validate HTML: `npx html-validate <file>` (if installed)
2. Re-check internal links by reading the modified files
3. Run Lighthouse if available: `npx lighthouse <url> --output json --quiet`
