# Design system status and neutral implementation tokens

**No final visual direction has been selected.** The required reference audit is incomplete. This filename is retained to match the requested handoff structure; the content is a provisional wireframe system, not a claim that the selection gate passed.

Tokens below are proposals for consistent implementation and review. Reconcile their names with `src/client` before final visual production. A token's presence here does not prove implementation or device testing.

| Token / rule | Neutral value / behavior | Purpose |
| --- | --- | --- |
| canvas | grayscale #121212 | Stable background without a branded color commitment. |
| surface / raised surface | #202020 / #2B2B2B | Separate page, panel and modal without blur. |
| primary text / secondary text | #F5F5F5 / #CBCBCB | Readable hierarchy; contrast must be rechecked after any theme changes. |
| outline / focus | #808080 / #FFFFFF | Focus uses a 2-pixel outline and a label; selected state is also marked with text. |
| action / destructive | light neutral fill / outlined warning with explicit verb | Color never carries action meaning alone. |
| spacing | 4, 8, 12, 16, 24, 32 logical pixels | Small reusable scale; avoid arbitrary per-screen spacing. |
| text | 16 body, 20 section, 28 title, 36 hero; larger-text option | Ordinary body copy remains readable; no all-caps paragraphs. |
| controls | minimum 48×48 logical pixels; 8-pixel separation | Proposed touch target, to verify under Studio and physical devices. |
| corners | 8 panels, 6 controls | Restrained neutral geometry, replaceable after brand selection. |
| page width | max 1100 with 24 desktop / 16 narrow padding | Limits text length; keeps controls away from edges. |
| modal width | max 560; 16-pixel outer margin; vertical scrolling | Confirmation remains reachable on narrow/short screens. |
| motion | 100–160 ms fades proposed, instant with reduced motion | Local feedback only; no unmeasured claims about actual speed. |
| effects | none required for menus | No animated backgrounds, blur, continuous glows or expensive viewports. |

Layout adapts at measured available space rather than device names. At narrow widths, use one column and an always-visible Back/Close row. Menus occupy safe-area bounds. During play, two steering buttons sit above the bottom safe inset; the timer and survivor count sit in a separate top band. Do not scale the entire desktop interface down to fit.

Focus contract: one primary focus target on route entry; remember the opener on modal open; restrict navigation to modal controls while open; restore opener on close, or the nearest surviving control. Back first closes a modal, then returns to previous page; it never silently purchases, discards a pending grant or disconnects. Text descriptions remain available without hover. Keyboard repeat and held gamepad directions must not trigger repeat transactions. Focus-only changes must not equip an item.

Cosmetic contract: core geometry, speed, collision radius and trail width remain identical for all owners. Menu preview labels separate appearance from gameplay. Patterns can distinguish players without relying only on hue. Elimination effects must be short, local and obscuration-limited; results effects never overlay active opponents. Baseline abstract mark is always available.

Component contract: button, toggle, slider with numeric label, item card, modal, toast and status panel share disabled/loading semantics. Pending requests show text and disable duplicate submissions; Close stays available unless the Roblox platform owns the prompt. Every component disposes event connections on removal. Reuse panels and update labels instead of rebuilding every frame.

Before final selection: verify contrast, focus order, clipped text, safe areas and large text in Studio. Confirm the chosen final theme against the three directions and complete audit, then replace neutral tokens as one coherent change. No final mascot or bundle should be inferred from this temporary palette.
