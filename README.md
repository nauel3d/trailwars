# Trail Wars

Original Roblox arcade UI and server foundations. Steer left or right; your trail becomes a wall. No avatar lobby or final gameplay simulation is implemented in this phase.

Workflow authority: [issue #1](https://github.com/nauel3d/trailwars/issues/1). Source files and deterministic tests are the development surface. Use existing research; reserve Studio for bundled checkpoints.

## Preserved checkpoint

- Componentized Luau client with Home, Play tutorial, Customize, Shop, Settings, Profile, and clearly labeled mock queue/HUD/spectator/results/rematch.
- Server-owned profiles, inventory, equipment, settings, earned purchases, session leases and idempotent receipt foundations.
- 29 foundation assertions passed in isolated Studio with an injected mock store. Further runtime fixes are recorded as they are completed.
- Rojo build passed. Production data and live purchases are disabled; no real product IDs exist.
- Design explorations, responsive specifications, monetization requirements and research findings are retained.

The visual design at this checkpoint is a neutral wireframe. Source-first visual development follows this preservation commit.

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
