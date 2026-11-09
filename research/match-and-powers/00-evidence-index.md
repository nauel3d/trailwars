# Evidence and version index — Issue #4

Investigation date: 2026-11-09 (Africa/Lagos). Baseline preserved: `5deed16a19afaed00e24460d83fb00eb0f089a2c`, branch `feature/gameplay-reconstruction`. Work is isolated on `research/match-powers-issue-4`. This package explains accessible evidence; it does not claim recovery of the commercial authoritative server.

## Evidence vocabulary

- **R — Saved runtime observation:** a visible result in an existing screenshot/accessibility record. It proves the pictured state, not an unseen transition or causal rule.
- **C — Client declaration/handler:** a value or branch in the installed client. It does not prove the deployed server uses it or that every branch is reachable.
- **P — Public documentation:** official wiki/Steam copy, retrieved 2026-11-09. Publication/build parity may be unknown.
- **I — Inference/estimate:** a stated derivation or interpretation with its assumptions.
- **U — Unconfirmed:** required behavior absent from accessible evidence, including stubbed server-side functions.
- **T — Proposed Trail Wars adaptation:** an original decision for review, not a Curve Fever rule.

Every claimed formula, parameter and interaction must retain one of these scopes. Reading minified code is static inspection, not a runtime experiment. Search completeness is confined to the named files, config maps and dispatchers.

## Source ledger

| ID | Source and identity | Coverage and use |
|---|---|---|
| BUILD | Steam App1133700, installed build26292297; prior observed UI4.3.0 | Current renderer/constants hashes rechecked unchanged. Wrapper/package versions are separate. |
| JS-R | `resources/build/assets/PlatformService-zkTPtK_x.js`, 7,742,370 bytes; SHA256 `fcaee093cbf48ccaa625c6a2016ed2f05669276402ebb01eb9eb4d90658ec5d6` | Focused inert byte/function/data inspections. Specific symbols and zero-based UTF-8 offsets appear in the topic reports. Not a full authoritative server implementation. |
| JS-C | `resources/build/assets/app-pNpNNO1T.js`, 66,435 bytes; SHA256 `67e91c459da916e8224f4ad266378bedee7974a524fc6fbef2c4daa0b7356bf6` | Shared constants and selected-file REA static graph from the prior pass reused rather than regenerated. |
| REA-C | Parent `ev_e37e5570f638d11588023315eb0f5496fa80c7ecc50dbd2ef88c2ff4facbac5b`; prior summary `ev_55553a2325c0ddc717c0d25ad6ab21b2db0a407ba49473c894f360688a1a919a` | Selected JS-C only:17,705 AST nodes,81 findings,0 parse failures;14 unselected files, partial graph and4,668 semantic unknowns. Imported canonical bundle, not repeated analysis. Module page reused under `ev_2d70b03f673bde1b0b6f038e3845d5c997b32f6e9d435aaa2bf2d3d73812ec40`. Source byte conclusions remain distinct from REA graph conclusions. |
| REA-INSTALL | Parent `ev_dfdb56a9e7c7e46e39dfc12b167d1718fb29103dbe37b6d5b64dc851538a6a22` | Prior installation scan:2,945 entries,17 headers probed,4,708 bytes; Electron candidate. Not replayed. Snapshot hashes cover examined ranges/metadata, not every installed byte. |
| OBS70 | Saved `S70_match_details` screenshot/text | Classic FFA—CUSTOMS;5m28s; six-player match endpoint; points/survival/stealing fields. Screenshot SHA256 `8fdddc93122bcf6affd695467499ef635ffed51bdece0f60c51d31dfafbf4237`; text `a7a18f578c3b4b2ea1c90fe6edecdc32e91e0052e32028786adcc6e567da2775`. |
| OBS72 | Saved `S72_scoreboard` screenshot/text | Round7, Goal300; finished winner321; local sixth90. Screenshot SHA256 `6473f8f9361e98a4194fc78928058b7e5e8a34c7cfda873a2e9153dacb02ec24`; text `190b343554e9ec63d5802bb27a9391d7f4b9be61ec3c100e3ac891d7327a2071`. Endpoint does not measure animated reorder timing. |
| OBS74 | Saved `S74_rematch.txt`, SHA256 `6c560c1d197c8829492fcddb35275700f3f34013dcf08216d93db231edd7626c` | Rematch returned to power-selection lobby with PLAY. Not automatic match start. |
| OBS-CONTROLS | Existing `research/04_gameplay_and_controls.md`, S15/S43–S46 | Observed profile key bindings, throw mode, bot lobby readiness and match-start countdown5. Three power action bindings are not proof of three default equipped powers. |
| VIDEO | Existing official Steam trailer, 56.389667s/1690frames/29.970fps | SHA256 `d33527625e3cbc9b3cfb0e73bb6fd8c23fa8b9a567a160f4b63cd6a8b2596146`. Edited montage; unknown build; no complete continuous multi-round match. Reuse existing decoded frames. |
| PUB | Official wiki [scoring](https://wiki.curvefever.pro/scoring), [matches](https://wiki.curvefever.pro/matches), [modes](https://wiki.curvefever.pro/gamemodes), [powers](https://wiki.curvefever.pro/powers), [pickups](https://wiki.curvefever.pro/pickups), [settings](https://wiki.curvefever.pro/match-settings) | Public-reader access. Factual transcription cache SHA256 `5d22642f90d23e8fba9a7f243a1fa2651a1604debfa125cdc6e31dc5d5ba1f36`; this hashes analyst transcription, not publisher HTML. Direct HTML requests returned403; stopped without bypass. Retrieval/source-specific details in07. |
| STEAM-NEWS | Official Steam news response | Private JSON SHA256 `2a09d099b5e7288f6a8df22953e21f7f6cd9fbbe4e127c4c4fd7dde88c5cbba3`; returned one2026-09-12 launch announcement, no verified4.3.0 mechanics changelog. |

## Important reconciliations

The client normal FFA target and flat-score adjustment can explain why a six-player custom match displays300 while general six-player Quickplay documentation says250; the actual captured scoring selection remains unobserved. Thirty powers in overview copy must not override31 concrete installed IDs and their factory dispatch. Random101 is a selector, and an orphan Saber config is not another verified accessible power. Blue-category equipment includes active/toggled abilities and passive defense statistics; calling every blue power passive is misleading.

S70 displays Duckle186 while S72 displays185. Two other players both display290 but occupy different rows. Preserve both observations: neither determines authoritative fractional-score rounding, tie ordering or exact scoring configuration.

## Access and preservation

REA is already installed. Sessions were checked/reused; no native provider was configured (Ghidra/IDA unavailable; Hopper unsupported on Windows). No installation or configuration changes. No new reference-game computer automation, login attempts, protected multiplayer attachment, payment or asset extraction. Raw private byte excerpts, original reference screenshots/video, REA bundles and source transcriptions stay ignored under `private/` or their existing research locations. Only independently described rules/metadata are committed. No native target was opened, so no native close operation is required.

The question/status ledger is08; the approval choices are09; implementation boundaries and runnable-proof instructions are10. The HTML gallery11 is an original review artifact using existing SNAP art and motion identity, not a Roblox replacement or a screenshot of the reference.
