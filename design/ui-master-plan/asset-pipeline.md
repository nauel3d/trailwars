# Asset workflow and technical decision

Decision proposal: retain componentized native Luau + Rojo. Author reusable art in editable SVG/vector layers, use a small reviewed PNG skin set where the approved material requires it, and keep text/data/input native. Review the complete design before touching production client code again.

| Approach | Benefit | Cost / evidence | Decision |
|---|---|---|---|
| Native UICorner/UIGradient/UIStroke only | Editable, simple, low asset count | Preserved prototype looked flat and cannot express the approved logo/sculpted rim faithfully | Use masks, focus edges and fallbacks, not all final material |
| Layered SVG + PNG skins | Editable geometry, repeatable exports, exact logo reuse, small assets | Existing scene source is incomplete and some masks contain artifacts | Recommended authoring source, with manifest and alpha QA |
| Figma / Penpot | Strong collaborative layer editing and constraints | No verified project/import pipeline; editor constraints still need runtime mapping | SVG assets/import are compatible; adopt only if it reduces iteration cost |
| Nine-slice | Reuses one shell across many controls | First frame attempt stretched baked tabs/light gradients; seams observed | Keep for tested button/card shells, split special rim/tabs instead of forcing a bad slice |
| Separate corners/edges + center fill | Preserves complex rim highlights and movable tabs | A few more small GUI elements | Small post-approval proof alternative for preview rim |
| Whole screenshot background | Fast superficial likeness | Noninteractive, unresponsive, bad text and ownership states | Rejected |
| figrbx / design importer | Could import editable basic GUI | No benchmark on this art, potential hierarchy/asset complexity | Do not install in critical path without a sample proof and license/ownership review |
| Fusion / React-Lua migration | Reactive composition available | Current code already runs; a framework change does not repair design/layout ownership | No migration justified now |
| UI Labs native function stories | Same components in isolated state fixtures | Studio plugin runtime remains unverified locally | Keep development-only stories; verify plugin once after approval |

## Preserved asset evidence

assets/peach contains 27 PNGs, source manifest with dimensions/SHA256, and roblox-assets.json with genuine returned IDs. The approved logo is isolated from the user-approved image. Generated shell source and the deterministic build script are retained. They are prototypes, not final approved exports. The ring mask contains a stray border fragment; the cream rim/skin stretching and some alpha edges need review. Do not upload another full kit to hide an unresolved construction error.

## Proposed asset set

1 locked logo; 2 primary/inactive button skins plus selected/focus/disabled treatments; 1 item-card skin; cream rim as either a tested 9-slice or corner/edge pieces; separate top/bottom tabs; coin/icon atlas; core/trail cosmetic sprites; subtle 128px tile; original short UI sounds later. Display text, prices, counts, ownership and disclaimers are native.

Button skins use fixed corner caps and a plain stretchable center. Slice metadata records source dimensions, SliceCenter, SliceScale, content insets, intended size range, alpha padding, source file, hash and returned Roblox ID. Exclude baked text/icons from stretch regions. Radius, glint and shadow may need different source resolution tiers; review at native device pixel density. A preview rim keeps proportional art or uses separate pieces when its lighting cannot stretch cleanly.

## Reproducible workflow

Approved design file → export only changed named layers → validate alpha, slice rectangles and dimensions → hash/deduplicate → upload changed UI assets once through the authenticated Studio workflow → record returned IDs → generate asset mapping → build Rojo → isolated story proof. Uploading approved UI images is distinct from publishing a game. No fabricated IDs, new commerce IDs, full-screen UI screenshots or proprietary reference-game art.

The plan's standalone SVG mockups keep named groups, editable text and individual referenced skin layers. PNGs are review exports, not game backgrounds. The small HTML review document is a presentation tool, not a proposal to turn Home into a scrolling website.

## Pivot record

Observed failures: duplicated W/Peach component responsibilities; fixed desktop canvas shrink causing tiny controls; long Home scroll composition; baked notch stretch and masked ring contamination. Alternatives: (A) measured native flex/grid shells with bounded art, (B) small mode-specific compositions using one component library, (C) importer-generated hierarchy. Recommend A+B. Prove Home + ItemTile + Dialog in spacious, compact and portrait modes after approval, not a whole rewrite. Compare actual geometry/visuals, texture memory, instance count and maintenance. If two meaningful proofs fail, reassess border construction or component boundaries before continuing. Identity changes still require approval.
