# Source-first development checks

Run these commands from the repository root in PowerShell:

```powershell
./scripts/bootstrap.ps1
./scripts/check.ps1 -Format
./scripts/check.ps1
```

`bootstrap.ps1` downloads only pinned official Windows x64 release archives into ignored `.tools/` and verifies their SHA-256 hashes before extraction. No global tool, PATH, Roblox setting or Studio plugin is installed. Versions are Luau 0.746, StyLua 2.6.0, Selene 0.32.0 and Rojo 7.7.0. URLs and hashes are reviewed in `scripts/tools.lock.json`; the GitHub API asset route is used because the ordinary release-download edge returned HTTP 504 during this run. The exact official release pages are [Luau](https://github.com/luau-lang/luau/releases/tag/0.746), [StyLua](https://github.com/JohnnyMorganz/StyLua/releases/tag/v2.6.0), [Selene](https://github.com/Kampfkarren/selene/releases/tag/0.32.0) and [Rojo](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.0).

`check.ps1 -Format` formats `src`, `dev` and `tests`. Without `-Format`, formatting differences fail the check. Both modes run Selene with zero warnings permitted by its default exit behavior, compile every source/story/test with `luau-compile --null`, execute foundation tests with the official Luau CLI, build production and preview places with Rojo, and inspect the resulting XML to enforce that development stories, tests and temporary Studio fixtures do not ship in production. No compiler warning is hidden with broad suppression; only mixed typed dictionary/table patterns are allowed in Selene config.

`check.ps1` prefers bootstrapped `.tools/rojo/rojo.exe`, then falls back to PATH. An explicit override is also supported:

```powershell
./scripts/check.ps1 -RojoPath 'C:/Users/User/AppData/Local/Programs/EscapeFarmTools/Rojo-7.7.0/rojo.exe'
```

Python 3 and PowerShell are also required. Output places are `dist/TrailWars.rbxlx` and `dist/TrailWarsPreview.rbxlx` and remain ignored. `.gitattributes` keeps source line endings stable for StyLua.

## What headless testing proves

`scripts/headless_tests.py` bundles the actual checked-in modules and `tests/FoundationTests.luau`; it does not duplicate their implementation in another language. A minimal `game`/`script`/`require` adapter supplies only module hierarchy lookup and an injected mock HttpService owner identity. The test suite exercises schema rejection, ownership checks, earned balances, duplicate purchases, receipts, rewards, outage recovery, foreign lease exclusion, stale-write refusal and pending-transaction reconciliation barriers.

The CLI suite is **not Roblox execution**. It does not validate engine objects, UI input, API permission, network remotes, DataStore availability, platform checkout, GPU rendering, device layouts or physical controllers. The compiler checks Luau syntax/bytecode generation, not full Roblox-aware type correctness. Studio checks must be reserved for a coherent tested source checkpoint. UI Labs stories are development fixtures and must be visually exercised in a later bundled check; their successful compilation alone is not a visual pass.

## Preserved earlier runtime results

`qa/runtime_evidence.json` is a local-only record of the earlier isolated Studio run. That run passed the prior 29-assertion suite and exercised mock UI purchase/cancel/equip, store failure, timeout feedback and the mock round flow. Later recovery/input/focus fixes and the source UI refactor were not retested in that Studio run. Keep those evidence scopes separate. The currently open throwaway Studio place may still contain its temporary test fixture; resync clean repository source before any later Studio use. CLI-built artifacts contain no such fixture.
