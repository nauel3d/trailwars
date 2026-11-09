# Approved Customize reconstruction

Scope: GitHub issue #2. Only the appearance of Customize changes. Server/shared modules, economy, gameplay, and all other route appearances remain intact. Work stays on feature/approved-customize-fidelity pending screenshot approval.

## Locked reference

`../reference/approved_customize_1672x941.png`, SHA256 5134d45e7a62d57fc64160f65af5399d1827f7236c391ee09dab067af2cf63c7. This is the retained original full-resolution MAKE IT YOURS image named by issue #2 and reproduced in the user's supplied sheets. The other sheets provide context, not authorization to add their systems.

## Tool decision

Use a layered SVG scene + JSON geometry manifest as the editable design source, reproducible local PNG asset generation/matting, reusable Roblox nine-slice ImageLabels, native text and real buttons, existing native Luau/Rojo and UI Labs function stories. This avoids an extra editor/account or unproven conversion step while retaining editable layout, separate graphics and versioned exports. The SVG can be opened in a layered vector editor. Logo and original icons are isolated from the approved artwork, not reimagined.

Roblox [nine-slice documentation](https://create.roblox.com/docs/ui/9-slice) supports preserving corner/border geometry while stretching shells. Native gradients alone cannot reproduce the approved material depth, so skins carry bevel/highlight/shadow, while counts, labels and prices stay native. No full-screen screenshot is mounted in the game.

Evaluated [figrbx](https://github.com/thynomex/figrbx): MIT source, editable basic GUI conversion, but no demonstrated fidelity for this approved bitmap's bevels, extracted logo or shadows. No installation or critical-path dependency is justified for one screen. Keep [Rojo](https://rojo.space/docs/v7/) as source of truth and [UI Labs function stories](https://ui-labs.luau.page/docs/stories/function) for isolated previews. UI Labs is a Studio plugin, not an external renderer.

Assets upload once through the authenticated Studio image-upload tool, with returned real asset IDs recorded. This uploads UI images only; it does not publish a game. No fake IDs or production commerce configuration.

## Fidelity priorities

Exact locked logo silhouette and proportions; peach/plum/turquoise/orange material balance; five-button left rail with orange Shop as shown in the approved reference; header/card/preview/CTA positions; large native Fredoka One lettering with subtle cream edge and plum shadow; separate reusable coin, ring, route, icon and shell assets. The live profile controls prices, ownership and balance. 480 coins belongs only to preview fixtures.

Desktop geometry targets 1672×941. Phone/tablet composition rearranges and scrolls rather than shrinking the entire desktop. Art may scale, but buttons retain usable hit areas. Text scale and pending/unavailable states remain explicit. The reference's decorative UI does not authorize new items, modes, abilities, currencies or reward systems.
