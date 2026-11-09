# Trail Wars

Current UI review: the isolated **living SNAP ARCADE proof**, continued from 785b54f, is documented in [qa/motion-proof](qa/motion-proof/README.md). Build `snap-proof.project.json` to preview animated Home and the Customize/Shop/Results demonstrations. The production app below is preserved while this motion direction awaits approval.

Original Roblox arcade UI and server foundations. Steer left or right; your trail becomes a wall. No avatar lobby or final gameplay simulation is implemented in this phase.

Workflow authority: [issue #1](https://github.com/nauel3d/trailwars/issues/1). Source files and deterministic tests are the development surface. Use existing research; reserve Studio for bundled checkpoints.

## Preserved checkpoint

- Componentized Luau client with Home, Play tutorial, Customize, Shop, Settings, Profile, and clearly labeled mock queue/HUD/spectator/results/rematch.
- Server-owned profiles, inventory, equipment, settings, earned purchases, session leases and idempotent receipt foundations.
- 29 foundation assertions passed in isolated Studio with an injected mock store. Further runtime fixes are recorded as they are completed.
- Rojo build passed. Production data and live purchases are disabled; no real product IDs exist.
- Design explorations, responsive specifications, monetization requirements and research findings are retained.

The current source implements the original Course markings visual system: charcoal, warm white, sharp yellow actions and geometric trail previews. The preserved neutral-wireframe baseline remains in commit d4aff77. See design/07_source_first_stack.md for the stack decision.

## Local build

From this folder, with Rojo 7.7.0 on PATH:

```powershell
rojo build default.project.json -o TrailWars.rbxlx
```

Open the generated local place in Roblox Studio for the bundled verification pass. No publishing is required. The optional `rojo serve default.project.json` workflow requires the Rojo Studio plugin. Test and formatting commands will be pinned with the automation checkpoint.

## Evidence policy

Raw screenshots, accessibility captures, REA exports, and original machine reports remain intact locally under `research/`; a full pre-Git snapshot is also retained outside this repository. These files are ignored in this public repository because they can include account details or proprietary reference content. `research/public/` contains sanitized findings and a hash-only evidence manifest. No reference assets or commercial source code are used by the Roblox project.

## Limits

Mock UI stages are demonstrations, not multiplayer. Live persistence, regional purchase prices, actual receipt fulfillment, physical-device behavior and full reference coverage are not claimed. See `design/` and `qa/` for the implementation boundary and pending validation.

## Source and preview layout

- `src/client/App.luau`: mountable application, navigation, request reconciliation and screen composition.
- `src/client/Widgets.luau` and `Theme.luau`: reusable native components, scoped disposal, accessible text sizing and reduced-motion feedback.
- `src/bootstrap/Main.client.luau`: player entry point; server integration is unchanged.
- `src/shared` and `src/server`: catalog/contracts and authoritative profile/economy services.
- `dev/Stories`: fourteen UI Labs function stories with isolated mock transport; excluded from production.
- `preview.project.json`: optional edit-mode UI Labs project. UI Labs needs its Studio plugin once; no runtime framework/package is required.

```powershell
rojo build preview.project.json -o dist/TrailWarsPreview.rbxlx
rojo serve preview.project.json
```

Create `dist` first when building manually. Stories return cleanup and never invoke live remotes. Source is authored without Studio; one bundled visual pass remains essential for geometry/input checks.

## Reproducible automated checks

Python3 and PowerShell7 are required. Tool binaries are local and ignored; official release URLs, versions and archive SHA256 values are committed in `scripts/tools.lock.json`.

```powershell
./scripts/bootstrap.ps1
./scripts/check.ps1
# To intentionally apply formatting:
./scripts/check.ps1 -Format
```

Checks run StyLua, Selene, the official Luau compiler, deterministic existing foundation tests through a minimal service/module adapter, both Rojo builds, and a production-artifact boundary check. Headless mocks do not emulate the Roblox engine or prove live DataStore/Marketplace behavior. The compiler verifies parsing/bytecode generation, not full Roblox typechecking. GitHub Actions runs the same source checks on pushes and pull requests.

The completed bundled Studio checkpoint, corrected small-phone case, functional results and limitations are recorded in [qa/studio_verification.md](qa/studio_verification.md). Remaining release gates are in [qa/remaining_risks.md](qa/remaining_risks.md).
