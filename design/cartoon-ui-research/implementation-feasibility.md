# Future implementation feasibility — no implementation authorized

Retain native Luau/Rojo, existing layout helpers, motion cancellation, Path2D proof, authoritative snapshots, UI Labs and source tests. No React/Fusion migration, server changes, gameplay rewrite or 3D vehicle migration is required to evaluate this art direction.

## Composition contract

| Usable viewport | Proposed composition |
|---|---|
| Desktop ≥1000w /≥600h | Home asymmetric title/PLAY + character trail demonstration. HUD board left, standings/actions right. Max content bound around 1400–1880; no ultrawide stretching. |
| Phone portrait <600w | Compact brand, illustrated Home hero, fixed PLAY, two quiet destination rows. HUD header → proportional board → identity/short standings → fixed powers/steering. Remove ambient decoration first. |
| Compact landscape <500h | Shallow top HUD; board and right action rail; steering remains separate from powers. Home gets its own short left action/right demo composition. |
| Tablet | Large board, readable grouped standings below; touch controls at reachable edges. Do not use the desktop side rail if it starves the board. |

Use the actual safe rectangle (ScreenInsets/GuiService), not raw desktop dimensions. Reserve Roblox top-bar space, cutouts and home indicator. Mockups are usable-content designs; a real device may have less room after insets. 390×844 and 749×381 PNGs do not certify a physical phone. At 320×568 use the provided small-layout check: shorten copy, fewer live rows plus explicit local rank, keep controls at least 48px. No page scrolling on Home; bounded inventory/settings content may scroll.

Arena remains exactly **1300:800**, computed as `min(availableWidth, availableHeight*1.625)`. All decorative rim/shadow is outside it. The live-racer mockup shell is about 16–17 world units vs current 13-unit visual diameter; it is a proposed cosmetic limit, not collision permission. Collision center/rules remain unchanged. Phone-sized racers are deliberately small. Large character illustrations only occur outside active play. Prototype and compare this small shell after approval; reject it if its relationship to the true collision center is misleading.

Screen/state switching derives from current real snapshots; demonstrated names/scores in this package are sample fixtures. Final/rematch must not reuse stale winner state. The known pending client-Final regression at `7419afd` is a separate release blocker to diagnose after this design phase; passing source tests does not waive it.

## Native techniques and asset boundaries

Frame/TextButton/UIStroke/UICorner for rectangular material structure. ImageLabel/ImageButton with `ScaleType.Slice` and authored `SliceCenter` for a truly distinctive reusable face. The proposed action skin is 128×128 with center `(32,32)-(96,96)`; quiet panel 96×96, center `(24,24)-(72,72)`. Preserve corners; do not 9-slice character art. Keep highlights fixed to corners/edge so they do not look stretched. Prototype a few size ratios in UI Labs before choosing images over native geometry.

Separate transparent racer/rocket sprites from text, focus rings, hit targets, cooldown progress and state. Maintain the tiny native sprite fallback when external image assets are unavailable. No full-screen screenshot as an interface. SVG is editable source/export format; Roblox runtime does not directly consume these SVG files as a magic new UI engine.

Path2D trails use the preserved bounded/chunked geometry contract. The design's smooth illustrative paths are not proof that a spline can diverge from authoritative collision geometry. Frozen chunks stay untouched; only active tips update. Small pooled impacts, at most the existing pool limits, no broad full-interface per-frame rebuild.

TweenService uses shared tokens, generation cancellation and keyed replacement. One event → one primary effect; event sequence/round IDs prevent replays. Disconnect completion connections and cancel on exit, hidden screen, reset/rematch or destroy. Reduced motion immediately removes travel/bounce/shake and ambient demo, retaining state text/delta/rank. Text changes are not delayed for a flourish.

## Input, typography and readability

At least 48px touch targets, 56–64px steering, visible gap from powers; pressed face moves but active target does not. Preserve keyboard A/D + W/S and current controller mappings; prompts switch to active input. Controller navigation requires explicit selection links, one persistent focus outline, B/back returning to origin. No reliance on hover. Mobile custom controls must remain in reachable thumb zones and must not overlap Roblox controls; current game disables default movement appropriately.

Native font choices verified in official Font enum. Use body Arial/ArialBold for dense detail; Fredoka One for short display. `PreferredTextSize` must reflow labels, not silently shrink them. `TextScaled` bypasses preferred-size behavior; use sparingly with constraints. Large text and long names need a separate UI Labs case. Paired shape/number identification avoids color-only state. Resolve small white-on-coral contrast using navy text or deeper coral, verified at actual size.

## Performance risks and future acceptance gates

No new performance measurements are claimed for these static designs. Aesthetics scores are not benchmarks. Largest risks: oversize transparent atlases, excessive layered bevels, live ViewportFrames for every inventory item, per-frame trails/highlights, unbounded score tweens and ambiguous oversized shell art. A uses one selected preview; B needs extra cut-edge skins; C has the highest transparency/layer cost. Do not add automatic quality switching without evidence.

After explicit approval: implement one Home/HUD/component vertical slice on an isolated branch; native builds/lint/tests, actual visible client and real two-client Final/rematch regression; comparable before/after CPU and rendered client intervals; repeated-round object/pool cleanup; desktop, 320 portrait, normal portrait, compact landscape, tablet, controller and reduced-motion visual checks. Keep `bbd39c7` fallback. Existing managed-client stalls stay unresolved until independent evidence identifies them. No physical-device FPS claim from Studio.

## Official technical sources, checked 10 November 2026

- [Cross-platform development](https://create.roblox.com/docs/projects/cross-platform): adapt input/orientation, readable content and accessible controls.
- [Position and size](https://create.roblox.com/docs/ui/position-and-size): reserved mobile zones and reachable thumb regions.
- [Adaptive design](https://create.roblox.com/docs/production/publishing/adaptive-design): input fluidity and content sizing.
- [Accessibility](https://create.roblox.com/docs/production/publishing/accessibility): preferred text/transparency/reduced motion; TextScaled caveat.
- [Font enum](https://create.roblox.com/docs/reference/engine/enums/Font): FredokaOne, Arial/ArialBold, Kalam and Nunito availability.
- [9-slice design](https://create.roblox.com/docs/ui/9-slice): fixed corners and independently stretched edges/center.
- [Path2D](https://create.roblox.com/docs/reference/engine/classes/Path2D) and [2D paths](https://create.roblox.com/docs/ui/2D-paths): native bounded spline rendering tools, not a collision guarantee.
- [Console guidelines](https://create.roblox.com/docs/production/publishing/console-guidelines): TV-safe placement and readable controls.

No sound upload, statistics/persistence change, publishing or merging belongs to this phase.
