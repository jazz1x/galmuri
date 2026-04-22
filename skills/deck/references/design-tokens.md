# Deck Design Tokens

> Jobs-inspired design tokens for galmuri deck output.
> Aesthetic reference only — separate from structural naming (presets use their own names).

## Typography
- **Font family**: SF Pro Display (title) / SF Pro Text (body)
- **Title size**: 60–72pt (full-bleed dark slides), 48pt (light slides)
- **Subtitle size**: 22–32pt
- **Body size**: 24–28pt
- **Caption size**: 11–14pt
- **Weight**: Medium for titles, Regular for body
- **Line height**: 1.2× for titles, 1.5× for body

## Emoji Policy
- Chips and section headers only. Zero emoji in slide body text.

## Aspect Ratio
- **16:9** (standard widescreen). No 4:3 or custom ratios.

## Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `dark-bg` | `#1c1c1e` | Dark slide background |
| `light-bg` | `#f5f5f7` | Light slide background |
| `dark-text` | `#f5f5f7` | Text on dark bg |
| `light-text` | `#1c1c1e` | Text on light bg |
| `accent` | `#0071e3` | Key term highlight, CTA |
| `muted` | `#86868b` | Secondary text, evidence |

## Layout Pattern: dark-light-dark

Open and Close slides use `dark-bg`. Core slides use `light-bg`.
This is the **default sandwich pattern** for all presets unless the preset frontmatter overrides.

## Parallel Rule
- The Close slide title must mirror the Open slide title in length and part of speech.
- Example: Open = "코드 리뷰가 왜 느릴까?" → Close = "4시간 SLA 로 해결한다."

## Visual Directives (per slide)
Each slide in the output `.md` should include:
```
**Visual**: {layout instruction — e.g. "title only, center, large", "title left / evidence right"}
**Background**: {dark | light}
**Accent**: {term to highlight in accent color, or "none"}
```
