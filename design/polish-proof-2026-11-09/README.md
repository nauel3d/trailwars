# Selected SNAP ARCADE direction — component and Home proof

The owner clarified the visual reference with `codex-clipboard-5d0fae38-90b5-4e7e-bddd-db58fbd90eaf.png`: mint and cream, navy outlines, coral Play, blue/coral/yellow trails, short shadows, and the SNAP ARCADE badge. This specific clarification overrides the peach instruction in the attached low-credit directive. The 46 earlier screen proposals, source layouts, navigation/state plan and static design checks remain unchanged and preserved at f9e3f2a.

Scope is batches B/C only: an isolated native component library and responsive Home proof. Remaining screens await visual approval. Production App, client bootstrap, gameplay, shared contracts, server economy and live purchase settings are untouched. `customize-study.png` is a preserved unapproved peach exploration generated before the clarification, not the selected direction.

## Tool decision

Reuse native Luau, Rojo, the existing fixture/story convention and original vector design sources. Penpot integration or a framework migration would add setup without resolving this proof's layout issues. Use native Frames/TextButtons/TextLabels/UIStroke/UICorner, one independently uploaded original wordmark, and six native Path2D objects for the three outlined curves. This selected outlined style does not require glossy nine-slice panel graphics. Existing peach skins remain preserved for historical reference.

Initial segmented frame curves looked beaded in Studio. Replaced them with native Path2D, then increased control-point sampling to eliminate visible low-resolution bends. The proof has no continuous render loop, screenshot background, whole-page UIScale or Home ScrollingFrame. Individual controls have scoped connections/tweens and disposal. Native [Path2D](https://create.roblox.com/docs/reference/engine/classes/Path2D) supports editable control points and pixel thickness; this is a better match for the selected outlined illustration than stretching a route bitmap.

## Sources and preview

- `dev/PolishProof/Components.luau`: outlined primary/secondary/navigation controls, currency, panel primitives, pressed/focus/selected/disabled/loading states, reduced-motion handling and scoped cleanup.
- `dev/PolishProof/ComponentBoard.luau`: component workbench, including cosmetic preview card, tabs and settings toggle. The workbench can scroll; Home cannot.
- `dev/PolishProof/Layout.luau`: one pure safe-parent layout function for spacious, compact landscape and portrait compositions, with an ultrawide width cap.
- `dev/PolishProof/Home.luau`: responsive proof, dynamic sample balance and five real controls. Destinations open a clearly labeled proof dialog rather than pretending the remaining screens are implemented. Navigation can be injected into the component later.
- `dev/PolishProof/Shell.luau`: full-bleed paper background and separate interactive safe rectangle. Uses [GuiService:GetInsetArea](https://create.roblox.com/docs/reference/engine/classes/GuiService#GetInsetArea) to express the core-safe rectangle relative to the full screen. This fixed currency clipping seen in the initial device playtest.
- `dev/Stories/SnapHome.story.luau` and `SnapComponents.story.luau`: isolated UI Labs function stories. Actual Studio rendering was verified directly; the UI Labs plugin itself was not exercised during this checkpoint.
- `snap-proof.project.json`: isolated local place with no server scripts and scriptable character controls. Production builds exclude all these development modules and stories.

Build: `.tools/rojo/rojo.exe build snap-proof.project.json -o dist/TrailWarsSnapProof.rbxlx`.

## Verification and limits

`scripts/check.ps1` runs formatting, lint, Luau compilation, the 40 existing foundation assertions, 33 tests against the actual pure Home layout, both normal Rojo builds and production-artifact boundary checks. The layout tests cover 11 viewport sizes × 100/125/150% text, five visible destinations, action bounds, 48px hit targets and no action overlap.

`dev/PolishProof/EngineChecks.luau` ran in Roblox: 33 frame-size/text cases, no remaining visible text-fit or hit-bound failures, 165 destination callbacks and four disabled/loading/default/selected state checks. Cleanup releases scoped connections. These diagnostics are not physical device or input certification.

The native runtime bootstrap was also exercised in Studio. iPhone 13 emulation showed usable safe rectangles of 389×704 portrait and 749×331 landscape. Desktop used the current local Studio viewport. Currency and all five actions were visible; no Home page scroll. Enter opened the Play proof dialog and simulated ButtonB closed it. Studio was stopped and reset to its default viewport. Physical touch/controller hardware, mouse targeting in device emulation, long localized strings, performance profiling and a complete screenshot-fidelity pass remain pending.

Actual unaltered Studio captures are in `qa/polish-proof/{desktop,portrait,landscape}.jpg`. They are proof captures, not final art approval. Differences from the concept remain: simplified trail illustration/background shapes and unfinished navigation iconography. The engine log also contained built-in Assistant plugin loading warnings and an unrelated pre-existing asset-type warning; no clean-console claim is made.

Stop here for the owner's visual approval. Do not merge, publish, enable purchases, or build the remaining screens from this checkpoint automatically.
