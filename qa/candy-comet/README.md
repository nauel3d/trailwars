# Candy Comet — gameplay art approval slice

Branch: `feature/candy-comet-visual-slice`, based on verified `bbd39c7`. The fallback branch/commit and PR7 are preserved. This is a visual approval checkpoint; no publishing, merging, purchases or persistence changes.

The owner subsequently approved this cartoon foundation and requested full playable-experience finalization. This folder preserves the first-slice evidence; continuation is tracked separately.

## Review the actual Roblox output

- `before-desktop.png` / `after-desktop.png`: the same real-engine replay at tick70, with Homing and a post-death turret rocket present.
- `before-portrait.png` / `after-portrait.png`: tick42, during the real Jump gap. Small artwork intentionally simplifies rather than becoming a shrunken face.
- `before-landscape.png` / `after-landscape.png`: tick42; substantially larger usable arena with side-mounted controls.
- `after-small-phone.png`: small-phone composition.
- `native-source-art.png`: actual Roblox rendering of the reusable native racer/rocket artwork, six numbered identities against paper, mint and crossing trails. This is an explicitly labelled art QA board, not gameplay.
- `candy-comet-studio.mp4`: uncut actual Studio-window recording of the deterministic review replay. It uses the existing RoundSession, Simulation, BotController and PowerService; no substitute movement engine or invented contact events.

The replay fixture starts six racers at documented positions, inserts two owned lethal trails, requests a server-equivalent Jump at tick28 and Homing at tick52, and lets the real collision/power modules produce deaths, turret spawns and hits. UI review controls do not run real matchmaking or award real statistics. Normal `playtest.project.json` remains the actual multiplayer entry point with the new renderer on this isolated branch.

## Reproduce

```powershell
./scripts/check.ps1
./.tools/rojo/rojo.exe build candy-comet.project.json -o dist/TrailWarsCandyCometReview.rbxlx
```

Open that review place in Studio and Play. It starts the labelled engine replay. In Studio's Client command context:

```lua
local p = game.Players.LocalPlayer.PlayerGui.TrailWarsGameplay.CandyReplayProbe
p:Invoke("Seek", 42) -- pauses at a bounded exact simulation tick
p:Invoke("Resume")
p:Invoke("Pause")
p:Invoke("Reduced", true)
p:Invoke("ArtBoard") -- toggle native source-art checks
p:Invoke("Benchmark") -- CPU comparison + event deduplication/cleanup assertions
```

For the preserved baseline, stop Play, set `ReplicatedStorage`'s `CandyBaseline` attribute to true in Edit, then Play. The baseline App source is preserved from `bbd39c7`; both sides use the same replay, viewport, hidden irrelevant avatar-health overlay and input state. The custom review target excludes the real server/store bootstrap. The normal playtest excludes art-board/benchmark scripts.

## Art and implementation decisions

The five visible baseline weaknesses were plain tiny circles, flat thin trails, capsule projectiles, absent impact language, and wasted arena space. The treatment adds a candy-shell/visor character, a shared portrait at a useful size outside the field, numbered identities, toy rocket fins/stripes/cross-wings, truthful Jump air rings/lift, short impact rings/chips and a framed game board. The approved paper/mint/navy/coral/blue/yellow SNAP identity remains the basis. No peach/plum direction was used.

Native `CandyCometArt.luau` is the editable resolution-independent source asset set; it supplies both in-game sprites and the QA artwork. No raster upload, external framework, 3D rig or GUI import is required. There is no asset-permission blocker and no upload was attempted. PNGs in this folder are actual QA captures, not backgrounds used to fake a working UI.

Historical lethal trails retain the original single Path2D pass and exact radius-scaled thickness. Completed48-point chunks remain frozen. Six reused highlight paths carry only the last eight points; highlights stop on death/Jump and never bridge a gap or extend lethal geometry toward an extrapolated core. The alternative full-active48-point accents were measured in the same native benchmark. Their CPU cost was close; eight-point accents were chosen for lower control-point traffic and less persistent visual emphasis. Multiple extra paths per historical chunk were rejected on deterministic instance/point growth, not falsely described as GPU-benchmarked.

Core collision anchors and authoritative positions are unchanged. Detailed art uses a restrained1.25× cosmetic shell around the original visual token, upright identity labels and a small steering lean; tiny tokens drop the face/rim details. Rocket artwork includes visibly decorative fins/exhaust around its point/radius contact model. No trail width, collision geometry, cooldown, score rule or Jump immunity was changed. Walls remain lethal during Jump; no additional protected state is invented.

Lethal effects use an ink ring, four short chips and a brief exclamation; wall rings have squarer corners. Nonlethal score transfers use a smaller ring and the actual stolen amount, without awarding or announcing a kill. Cause-specific local feedback stays separate from the true turret/spectator control state. The only match-service addition is bounded presentation metadata from existing authoritative events, with stable sequence IDs and contact coordinates. Initial history, duplicate snapshots and resync do not replay effects. Twelve impact slots are reused, then expire; Home/reset clears visible effects. Reduced motion retains static AIR/ring state and removes lift/lean/exhaust and fragment movement.

## Evidence and limits

`native-benchmark.json` compares identical real six-bot geometry for26.42 seconds,3156 segments and70 historical paths. Final mean renderer-update CPU was about0.057ms baseline,0.176ms full-active highlight,0.171ms short accent. Native descendant counts106 vs412 include the fixed pooled effects and racer art. Candy adds six active paths; the historical path counter deliberately reports historical chunks only. These are desktop CPU setter/update measurements on invisible benchmark fields, **not** GPU cost, physical-phone FPS or sustained thermal performance. Timing noise and construction spikes are retained in the JSON.

`native-viewports.json` records actual safe-area/control bounds. Requested compositions were checked statically at1672×941,390×844,320×568 and749×381, plus reduced safe heights. Native device-fit readbacks were1672×941,389×844,320×567 and749×381; the one-pixel differences are simulator fit rounding. Compact landscape grew from229×141 to408×251 while preserving1300:800 aspect. All five gameplay controls remain at least44px; powers are54px high, steering56–60px. An additional iPhone17Pro preset was checked at400×776. Physical phones/controllers and GPU profiling remain unverified.

CLI checks retain all570 prior core assertions and add105 visual/replay contract assertions; formatting/lint,106 compiled Luau sources, responsive/motion checks and eight Rojo builds pass. The native effect test returned first1 / duplicate1 / resync0 / fresh1 / expired0. Reduced-motion native verification retained the air indicator with zero lift. Existing Studio Assistant-plugin and asset203785492 warnings remain unrelated known console warnings.

The final two-client regression passed all critical flags and both clients observed three rounds/final/rematch (`two-client-regression-pass.json`). The first retry is retained: its Jump fixture depended on startup delay to clear a trail during the speed ramp. Moving only the fixture crossing inward made an early accepted Jump clear reliably; gameplay duration, speed, collision and power rules were unchanged. The review-only settings packet was also completed after navigation testing exposed missing fixture fields; the real server packet already supplied those fields.

**Approval boundary:** review this first slice before extending Candy Comet across other screens. This branch is a proposal implemented in-engine, not a claim that the entire game's art is finished or that physical-device release gates have passed.
