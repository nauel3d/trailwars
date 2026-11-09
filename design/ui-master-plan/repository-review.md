# Repository review and preservation checkpoint

Reviewed 2026-11-09 before design planning. Owner directive and issue #2's [superseding comment](https://github.com/nauel3d/trailwars/issues/2#issuecomment-6737385516) require planning and complete-system approval before further implementation.

## Exact stopping point

- Local and remote main: d7b7480bee721a23c170b0a957e8d86d30ce7b07.
- Local and remote feature/approved-customize-fidelity before preservation: 6c16f5a1d746c883287386be76511145619a8bff.
- Uncommitted UI experiment: App, Theme and Widgets changes; new PeachCustomize, PeachResponsive and PeachAssets modules; an isolated proof bootstrap/project; 27 generated/matted image assets with genuine returned Roblox IDs; editable SVG/JSON; asset-generation and engine-check scripts.
- Locked approved PNG: design/reference/approved_customize_1672x941.png, SHA256 5134d45e7a62d57fc64160f65af5399d1827f7236c391ee09dab067af2cf63c7.
- Earlier public design research, raw private reference evidence, screenshots, 14 UI Labs stories, pinned CLI tools, navigation, data and commerce foundations are preserved. The raw Steam research remains locally ignored. No repeat Steam/REA inspection is necessary.

## What passed and what did not

The last CLI run before this directive passed StyLua, Selene (zero warnings/errors), Luau compilation of 33 source/story/test files, 40 foundation assertions, production and preview Rojo builds and artifact-boundary checks. This establishes source/build integrity, not visual approval.

The latest 96-case engine diagnostic returned 63 text-fit flags. Some are false positives from hidden Home descendants, but visible balance/badge/large-text issues remain. Earlier 10-case Customize success predates subsequent layout changes. No current all-green responsive claim is valid. The final observed Home fit a 1366×826 simulated viewport with page scrolling disabled; it remains an unapproved experiment. Native screenshot evidence is preserved separately.

A preview-fixture keyboard flow selected the dashed trail, opened details, confirmed its 100-coin unlock (480 → 380), equipped it, restored selection/focus and navigated Home/back. This is client fixture evidence. Earlier server-backed mock evidence remains separate. No live purchase, durable production profile, real match, reward or physical-device test was performed.

Server/shared modules, production bootstrap and foundation tests have no diff from main. Gameplay remains mock. EnableLivePurchases and EnableProductionProfiles remain false. No force-push, merge or game publication occurred.

## Why we are pivoting

The experiment mixed two component implementations and added increasingly complex device patches. Blanket scaling reduced text/hit areas; long portrait documents made Home feel like a website; skin slicing introduced seams; an extracted ring included a stray selection-border fragment. Passing TextFits alone missed those design failures. These are reasons to preserve the experiment as WIP and specify compositions and component contracts first, not continue patching it.

The approved visual identity remains the anchor. Old positions, blanket UIScale fitting and existing asset construction are not architectural mandates. The new plan permits content scrolling inside inventories/settings, but Home itself must remain a complete game menu with Play and navigation visible.

## Reusable work

Keep source-authoritative routing/contracts, idempotent economy tests, pending/reconciliation barriers, mock transport, scoped cleanup, authentic locked logo/reference, tested Rojo/CLI setup and measured historical evidence. Review shells, alpha masks, texture duplication and type metrics before reusing art. The new plan documents all proposals without silently adding backend features.
