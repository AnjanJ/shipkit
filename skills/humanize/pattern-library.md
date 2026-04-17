# AI Writing Pattern Library

40 patterns across vocabulary, structure, tone, and formatting. Based on community-maintained
reverse-engineering catalogs and empirical observation.

## Three Principles

1. **Clustering is the signal, not single occurrences.** A human can write "delve" once. Three tropes in the same paragraph is AI. Always ask "how many tells, how close together?"
2. **Regression to the mean is the root cause.** LLMs launder specific facts into generic descriptions. The real diagnostic: has concrete information been replaced with generic gravitas?
3. **Watch lists age — track model eras.** GPT-4 era favored *delve, tapestry, testament*. GPT-4o shifted to *align with, fostering, bolstered*. GPT-5+ favors *emphasizing, enhance, highlighting, showcasing*. Structural patterns are more stable than word lists.

---

## Vocabulary & Phrasing (1-10)

### 1. The AI Glossary
LLMs overuse statistically probable but humanly rare words.
- **GPT-4 era:** *delve, tapestry, testament, landscape, intricate, meticulous, beacon, crucial, pivotal, realm*
- **GPT-4o era:** *align with, fostering, bolstered, robust, dynamic, multifaceted, leverage, harness, paradigm, synergy*
- **GPT-5+ era:** *emphasizing, enhance, highlighting, showcasing, streamline, utilize, interplay, valuable, profound, ecosystem, framework, vibrant*

### 2. Exaggerated Significance
Inflating importance of mundane topics.
- Watch: *serves as a testament to, marks a pivotal moment, stands as a beacon, indelible mark, key turning point, setting the stage for*

### 3. Promotional Ad-Speak
Marketing language in non-marketing contexts.
- Watch: *nestled in, breathtaking, vibrant, seamless, unparalleled, boasts a, rich, profound, groundbreaking, renowned, diverse array*

### 4. Transitional Duct Tape
Formal conjunctive adverbs forcing flow between disconnected ideas.
- Watch: *Furthermore, Moreover, Additionally, Consequently, As such, In addition*

### 5. Vague Attribution
Unnamed authorities cited for credibility.
- Watch: *Experts note, observers point out, studies show, critics argue, industry reports suggest*
- Fix: Name the specific source or state the claim directly.

### 6. Copula Avoidance
Avoiding simple "is/are/has" with clunky replacements.
- Watch: *serves as, stands as, marks, features, offers, represents, boasts, ventured into*
- Fix: Use "is," "are," "has."

### 7. Wordy Evasion
Ten words where three would do.
- Before: "Due to the fact that the system has the capacity to handle..."
- After: "Because the system can handle..."

### 8. Magic Adverbs
Understated adverbs manufacturing gravitas without adding meaning.
- Watch: *quietly, deeply, fundamentally, remarkably, arguably, notably, profoundly, inherently*

### 9. Emphasis Hedges
"This next bit is important" phrases with no logical function.
- Watch: *It's worth noting that, Importantly, Interestingly, Notably, Of particular note*

### 10. Stock Cliched Idioms
Figurative stock phrases AI reaches for to sound seasoned.
- Watch: *smoking gun, perfect storm, move the needle, game changer, double-edged sword, low-hanging fruit, paradigm shift*
- Fix: Delete the idiom and state the literal claim.

---

## Sentence Structure & Grammar (11-18)

### 11. The Rule of Three
Compulsive grouping in threes to simulate comprehensiveness.
- Before: "innovation, inspiration, and industry insights"
- After: "industry insights and new ideas"

### 12. Trailing Participles
"-ing" phrases tacked on for fake depth.
- Watch: *highlighting, underscoring, emphasizing, ensuring, reflecting, symbolizing, fostering, showcasing*

### 13. Negative Parallelism
"Not only X, but also Y" and variants.
- Includes staccato reveal: "Not a bug. Not a feature. A fundamental design flaw."

### 14. False Scope
"From A to B" where A and B aren't on a meaningful spectrum.

### 15. Elegant Variation (Synonym Cycling)
Unnaturally cycling through synonyms instead of reusing a noun. Humans repeat words freely.
- Before: The *car* drove fast. The *vehicle* turned left. The *automobile* stopped.
- After: The *car* drove fast, turned left, and stopped.

### 16. Metronomic Rhythm
Sentences of identical length and structure creating a robotic cadence.
- Fix: Vary sentence lengths deliberately.

### 17. Rhetorical Question + Immediate Answer
Self-posed questions with clipped reveals.
- Before: The result? Devastating.
- After: The result was devastating.

### 18. Anaphora & Fragment Stacking
Same sentence opening repeated for drama, or one-word fragments stacked.
- Fix: Combine fragments into a single sentence with ordinary prose rhythm.

---

## Narrative & Tone (19-29)

### 19. The "Despite Challenges" Formula
Challenge paragraph that immediately dismisses the challenge.
- Fix: State the challenge honestly. Mixed outcomes are real.

### 20. Generic Optimistic Conclusions
Wrapping up with vague positive summaries.
- Watch: *As we look to the horizon, the journey continues to unfold, promising exciting advancements*
- Fix: Delete entirely or end on a concrete factual note.

### 21. Sycophantic Tone
Overly eager, people-pleasing language. Includes the compliment sandwich.
- Watch: *That is a fantastic point! Great suggestion!*
- Fix: State the substance directly.

### 22. Over-Qualification (Hedging)
Hedging so much the sentence loses all meaning.
- Before: "It could potentially be argued that this might possibly have an effect."
- After: "This will likely have an effect."

### 23. The "In Conclusion" Crutch
Starting final paragraphs with "In conclusion," "Ultimately," "To summarize."

### 24. Voice Inversion
Two failure modes: sterile passive ("It was decided that...") and pedagogical "Let's" ("Let's break this down, Let's unpack this").
- Fix: Use "I" or "we" honestly when it fits.

### 25. Explaining the Joke/Metaphor
Over-explaining figures of speech.
- Before: "It was a Trojan Horse, meaning it looked like a gift but contained a hidden threat."
- After: "It was a Trojan Horse."

### 26. Invented Concept Labels
Compound neologisms: *the X paradox, the X trap, X creep, the X divide.*
- Fix: Drop the label, describe the phenomenon directly.

### 27. Dead Metaphor Overuse
One metaphor hammered 5-10+ times across a single piece.
- Fix: Use the metaphor once or not at all.

### 28. False Exclusivity
Manufactured insider framing.
- Watch: *What most people miss, What nobody talks about, Here's the kicker, Here's the thing*

### 29. One-Point Dilution
Same argument restated ten different ways across thousands of words.
- Fix: Identify the one claim. Keep the best sentence. Delete the rest.

---

## Formatting & Provenance (30-40)

### 30. Em-Dash Overuse
Several per paragraph to simulate punchy tone. Humans use them sparingly.

### 31. Over-Bolding
Mechanically bolding every key term in a paragraph.

### 32. Inline Header Lists
Every bullet starts with a bolded word followed by a colon.

### 33. Emoji Bullet Points
Using emojis as bullet points in professional text.

### 34. Knowledge Cutoff Disclaimers
- Watch: *As of my last knowledge update, As a large language model, [insert X here]*
- Fix: Delete the disclaimer and state the fact directly.

### 35. Title Case Headings
Capitalizing every word in section headings instead of sentence case.

### 36. Smart-Quote & Markdown Artifacts
Paste-from-chatbot tells: curly quotes, arrows, literal `**bold**` in non-markdown contexts.

### 37. Credential Dumping
Listing media outlets, awards, coverage venues instead of synthesizing content.

### 38. Sudden Style Shift
Mid-document tonal change revealing a human/AI boundary. Also: content duplication.

### 39. Listicle-in-Prose / Phase Labels
Numbered enumeration disguised as narrative when ordering is meaningless.

### 40. Canned Opening Hooks
- Watch: *Imagine a world where..., Think of it as..., Picture this:, In today's fast-paced world*
- Fix: Start with the actual subject.

---

## Full Before & After Example

### Before (AI)
> The shift to remote work marks a pivotal moment in the modern corporate landscape.
> Furthermore, it serves as a testament to human adaptability. Not only does it offer
> unparalleled flexibility, but it also fosters a vibrant tapestry of global collaboration.
>
> In conclusion, as we look to the horizon, the future of remote work remains incredibly
> bright. By leveraging dynamic tools and prioritizing employee well-being, businesses can
> unlock new realms of productivity.

### After (Human)
> The shift to remote work has permanently changed corporate culture. While it offers
> employees flexibility, it has also forced companies to rethink how teams collaborate.
>
> Remote work isn't going anywhere, but the tools and policies around it will likely
> look very different five years from now.

### Changes Made
- Removed exaggerated significance ("pivotal moment", "testament to human adaptability")
- Removed AI vocabulary ("landscape", "tapestry", "unparalleled", "vibrant", "dynamic", "realms")
- Removed transitional fluff ("Furthermore", "In conclusion")
- Fixed negative parallelism ("Not only... but also")
- Replaced generic optimistic conclusion with concrete, realistic prediction
- Varied sentence lengths to break metronomic rhythm
