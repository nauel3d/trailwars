# Trail Wars — replacement visual direction

This proposal replaces the peach/plum visual direction following the owner's request for an entirely new design. Existing source, tests, assets and research remain preserved on the feature branch. This folder contains design proposals, not actual Roblox screenshots or a completed runtime implementation.

Open `index.html` for the complete review gallery. The three concept paintings establish the art direction; the 46 editable SVG layouts define the screen family, states and responsive compositions. The layout drawings are deliberately simpler than the concept paintings. Neither is a background image intended to masquerade as an interactive game UI.

## Visual direction

Warm white (#FFFCF3), mint (#DFF4E8), navy ink (#192A46), coral actions (#FF6957), cornflower (#5877E8), and restrained marigold (#F4CE54). Rounded Fredoka One headings pair with readable sans-serif body copy. The included font retains its OFL license.

Controls use moderate corners, consistent outlines and short hard shadows. Circular cores stay circular. Trails are independent paths with stable stroke widths. Large panel artwork is replaced by native geometry; no glossy skin is stretched across unrelated shapes. The new original wordmark is an independent raster layer. Icons in the layout drawings are provisional geometry and require the same finishing standard as the concept art during implementation.

## Responsive behavior

- Spacious desktop: open trail illustration on the right, Play on the left, four destinations in a bottom row. Content width is capped on ultrawide screens.
- Compact landscape: shallow header, destination rail, wide illustration and a fixed Play action. This is its own composition.
- Portrait: compact header, shorter illustration, Play, then a two-column destination grid. The 320×568 layout reduces decoration before controls.
- Home has no page scrolling. Inventory and settings may scroll inside a bounded content region while navigation and the primary action remain fixed.
- Recalculate from Roblox's safe usable rectangle. Keep core tokens square with aspect constraints, measure localized text, respect preferred text size, and reflow rather than applying a single global scale. Touch targets should remain at least 48 logical pixels after safe-area layout.

The authored layouts show 320×568, 390×844, 844×390, 768×1024, 1672×941 and 2560×1080 examples. PNG dimension, action-boundary and Home action-overlap checks are static design checks. They do not establish Roblox behavior, touch ergonomics, text fit at every font setting, animation performance or device compatibility.

## Screen family and systems

The gallery covers Home, controls, queue/countdown, Customize, Shop, item details, confirmation/pending/reconciliation/insufficient funds, profile/empty profile, settings/large text, HUD, elimination/spectator, victory/defeat/rewards pending, loading, recovery and leaving a round. Mockups of unavailable gameplay states are planning only; they authorize no new server or gameplay systems.

Reuse the audited [screen inventory](../ui-master-plan/screen-inventory.md), [navigation and state machine](../ui-master-plan/navigation-and-state-machine.md), [adaptive layout contract](../ui-master-plan/responsive-layout-contract.md), [interaction and motion](../ui-master-plan/interaction-and-motion.md), [research](../ui-master-plan/research-summary.md), and [implementation plan](../ui-master-plan/implementation-plan.md). Their old peach/plum visual tokens and old mockups are superseded by this folder. Their scope boundaries, state semantics, focus/back behavior and safety rules remain applicable.

Keep owned, equipped, selected for preview and pending purchase separate. The four actual catalog items remain the source of truth. Sample balances and results are fixtures. Matchmaking, ranks, reward payouts and live commerce must not be invented to make a proposed screen appear functional.

## Implementation decision

Retain native Luau and Rojo, the existing component and navigation foundations, and UI Labs stories. This avoids a framework migration while the design changes. Build the new controls with native Frames/TextButtons/UIStroke/UICorner, aspect and size constraints, and a small asset set for the wordmark and any finished illustrations. Preview each composition and each semantic state in UI Labs. Keep responsive calculations in a shared pure layout module. Use short cancellable TweenService transitions; reduced motion uses immediate state changes.

After design approval: implement Home and Customize first, check their production and preview builds and source checks, then perform one bundled Studio verification at desktop, portrait and compact landscape sizes. Compare each capture with its matching composition. Continue the other interfaces only after those building blocks hold up. No publish, merge, live purchases or changes to the server economy.

## Review checkpoint

The owner's master directive says: “I will approve the complete UI design before you implement it.” The latest request changes the visual direction. This package makes that replacement concrete for approval; the new runtime UI has not been implemented yet. Prior prototype test results must not be reported as verification of this new design.

## Reproduce the review exports

Run `source/build_fresh_system.py`, then `source/rasterize_text.py`, then `source/render_mockups.mjs` with the bundled Node runtime, followed by `source/build_review.py`. The builder reuses the preserved screen content inventory but replaces the visual primitives and Home layouts. SVG text remains editable; raster review exports use the included heading font and local Arial. Generated image prompts are recorded in `source/image-prompts.json`.
