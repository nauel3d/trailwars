# Proposed A style guide — Candy Comet Arcade

Status: unapproved design. Editable SVGs and PNGs are artwork for review, not runtime UI.

## Color and material

| Role | Value | Use |
|---|---|---|
| Paper | `#FFF9E9` | Main surface, readable light text on navy |
| Navy ink | `#20334C` | Text, reliable edges, small hard shadow |
| Sea-glass mint | `#C8E9D9` | Context field, local selection, no success inference alone |
| Coral | `#F66B55` | PLAY/rematch, player 1, illustration accents |
| Cornflower | `#5579D9` | Cooldown/focus, player 2 |
| Marigold | `#F3C653` | Jump readiness, fins, small celebration marks |
| Playfield | `#EDF5DE` | Low-contrast world, colored trails carry priority |

Color alone never communicates ready/charging/out or competitor identity. Navy labels, rank numerals and progress/cooldown text are required. Coral/white is decorative display treatment, not a body-text accessibility guarantee; smaller action labels should use navy if contrast fails at final weight/size. High-contrast variant should retain shapes and use navy labels.

## Shape grammar

Three surfaces only:

1. **Action capsule:** 2–3px navy edge, 5–6px bottom extrusion, one upper highlight. PLAY/Homing/rematch; face compresses 3px without moving the hit target. Primary action remains legible while pressed.
2. **Inspection / information surface:** quiet paper or mint, 1–2px edge only if grouping needs it. No shadow by default. One rounded inspection stage is acceptable; not every metric gets a card.
3. **Navigation / editorial information:** icon plus text, no enclosing card. Active destination gets a short coral trail underline; controller focus is a separate high-contrast outline.

Arena receives a strong dark boundary and shallow base. This is a visual frame outside the 1300:800 collision plane. Never add bevels inside a lethal edge or skew the board. Reuse a few asymmetric curves; do not make arbitrary blobs a universal decoration.

## Type and spacing

Fredoka One for large headings, short control labels and result numerals. Arial/ArialBold for body detail, compact live scores, cooldown decimals and long names. Both are native Roblox font options; Enum.Font.FredokaOne and Arial/ArialBold are documented. Kalam is proposed only for B's display lettering. Existing Fredoka font/OFL is reused; Kalam font/OFL is included under source/fonts.

Desktop display 40–61px, major action 28–36, body 16–20, compact HUD 16–24. Phone heading 28–37, action 22–27, body 14–16, primary HUD 18–23. Decorative provenance labels in exported boards are not game text. At 320px width reduce copy/decoration before body size. Prefer line breaks and AutoSize over unconstrained TextScaled; no number smaller than the final accessibility contract permits. Test long localized labels and preferred text size after approval.

Spacing base 4px, usual groups 8/12/16/24, independent major regions 32–48. Align information, not every illustration. Thumb controls have at least 48px active bounds, steering 56–64. Illustration may break its own stage edge but never overlap a playable control.

## Character and icon system

Original comet silhouette: compact forward shell, two tail fins, dark visor, two readable eyes, single glint and lower color rim. Large characters get a physical shadow; match shells simplify immediately at small size. The tiny authoritative center remains clear. Large inspection art is not a new collider or 3D migration.

Rockets: pale fuselage, coral nose/stripe for Homing; yellow nose and different fin/cross-wing cue for turret. Launch plume is short, pooled and not a substitute for a server hit event. Jump uses a ground anchor/AIR state; its animation never changes trail or wall rules.

Navigation icons should be hand-authored from the same capsule/finned vocabulary: small trail brush, pit-stop bag, pilot portrait, paired sliders. Icon geometry appears on the component board; exact catalog item artwork stays separate from generic control symbols. No emoji font dependency. Direction arrows are explicit vector shapes.

## Assets

`component-designs/` contains independently editable racer, Homing, turret, button face, quiet panel, icon sheet and full component/state boards. These are original assets; they contain no copied reference-game imagery. Text in screen SVGs stays editable; exported PNG text is rasterized with the specified fonts for consistent review.

Suggested future texture budget, not a measured guarantee: one 512×512 racer-expression atlas, one 256×256 icon/rocket atlas, 128×128 9-slice action face, 96×96 quiet panel, independent wordmark. A minimal native construction may replace an image where it achieves equivalent fidelity. Use image sprites for large art only where asset approval/upload is later authorized. No upload occurs in this phase.
