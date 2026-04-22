# pitch — Hook-Core-CTA Prompt Rules

## Structure

The final output must be **3 to 5 lines total**:

### Hook (exactly 1 line)
- A question or reversal that hits the audience's current situation.
- 30 characters or fewer.
- Declarative sentences forbidden — use interrogative or exclamatory form.

### Core (1–2 lines)
- A single claim plus one piece of evidence. One line each, 50 characters max.
- List format forbidden (one core only).

### CTA (exactly 1 line)
- A request for action or judgment. Imperative or interrogative form. 30 characters or fewer.

### Optional emphasis line (up to 1 extra)
- A bold or contrast line if the core needs sharpening. Counts toward the 5-line cap.

## Tone
- Accessible to a domain novice: technical terms must be accompanied by a parenthetical explanation.
- No filler, hedging, or vague language.

## Reference
- Distill output is from `skills/distill/references/essence-schema.json` — use `units[0].claim` as the core claim source.
- Do not duplicate content from `skills/distill/references/socratic_probe.md` or `decomposition.md` inline — reference by file path only.
