# Gameplay verification checkpoint — 2026-11-09

## What runs

The original pure-Luau 50Hz kernel drives movement, continuous lethal trails, chronological swept collision, simultaneous head-on ties, elimination and last-alive/time-limit results. It uses a uniform spatial index and conservative chord envelope, described in collision-analysis.md. Native Path2D rendering freezes completed 48-point chunks and only updates current chunks. Core positions update without rebuilding the interface. Existing UI, backend foundations, motion tokens, screen proposals and research remain preserved.

`local-gameplay.project.json`: independent local human-versus-three-bots proof. `gameplay.project.json`: server-owned 2–6-human arena, 12-second solo pairing grace then practice, intent-only remotes, sequenced validation, rate limiting, 400ms steering leases, authoritative elimination/results, 10Hz state/delta delivery, bounded 600-segment catch-up packets and full resync. Client extrapolation is visual and capped at 150ms; it never predicts lethal geometry, placement or rewards. It is not full rollback prediction. HOME, queue, countdown, HUD, spectator, Results and Play Again use real round state. Other UI destinations retain existing demonstrations.

The isolated multiplayer bootstrap imports ProfileStore/EconomyService/MockStore and MatchService without also running the default Main backend. Mock rewards use durable unique match IDs and the existing atomic ledger; participation requires two humans, at least 100 active ticks and a steering change. Transient failures back off and remain pending across rematches while that player is present. Practice grants nothing. Production profiles and purchases stay disabled.

## Passed source checks

`scripts/check.ps1`: clean StyLua/Selene; 82 Luau files compiled; all five Rojo builds; artifact boundaries verified. Official Luau CLI: 40 foundation assertions plus 327 gameplay/round/network assertions, including 20 varied six-bot rounds with peak 4,656 segments. Existing SNAP layout tests (33 viewport/text-scale cases) and decorative motion/ranking tests also pass. Headless tests use minimal service adapters and do not prove engine behavior or Roblox type correctness.

## Actual Roblox Studio evidence

- `local-practice-studio.mp4`: 18 seconds of real local practice, with Studio chrome; diagnostic-hook steering is documented in local-checkpoint.md.
- `two-client-studio-final.json`: final actual StudioTestService two-client run passed. Both clients saw the same match ID, two humans, 546 authoritative and rendered segments, requested resync, and reached the same LastAlive result. Server eliminated Player1 for SelfTrail and chose Player2. There were 12 paths per client at this result. Earlier failed tests exposed and fixed premature solo fallback and an incomplete queue snapshot.
- Native Studio keyboard API: A held for 250ms changed heading from pi to 2.46559; release returned turn to zero. A later D hold changed heading to -2.46559. Real Play Again mouse activation started a fresh server match ID ending in :2. These are programmatic Roblox input tests, not a physical player/controller usability study.
- Phone portrait 400×872: arena384×236, controls76×78, header fits. Phone landscape873×401: arena317×195, controls112×54, status/header fit. Tablet1374×1031: arena1152×709, controls112×78. Arena world aspect is constant; there is no global stretched image/UIScale or scrolling match screen. Landscape safe areas reduce usable height. Labels at arena edges were clamped; final portrait/desktop captures preserve the fix.
- `phone-portrait-final.png`, `desktop-final.png`, `phone-landscape.png`, `tablet.png` are actual engine captures. Earlier phone/tablet captures precede the label-edge readability fix. `server-practice-studio.mp4` is supplementary server practice/results footage; the local recording is the main motion artifact.
- Actual Studio Luau CPU sample: 2,253 six-bot simulation steps over three varied rounds, mean0.770ms, p951.733ms, max3.334ms, peak3,276 segments against a20ms step budget. This excludes rendering, network and device GPU cost.
- Network simulator read-back: all six latency/jitter/loss controls0; settings preserved. Solo measured NetworkPing sample1.114ms. No live shaped-network stress pass is claimed. Pure stream tests cover missing/reordered geometry, stale full snapshots, resync and rematch isolation.
- Studio's existing Assistant plugin failed to deserialize in some test processes; a pre-existing image203785492 also reports asset-type mismatch. No gameplay script error remained after the queue-fixture correction. These unrelated local Studio/asset warnings remain recorded rather than being represented as a clean console.

## Practical limits and remaining release gates

Actual engine multiplayer is verified with two clients, not six. Six-player capacity and six-bot CPU/geometry were tested separately; full six-client rendering, live adverse-network testing, long sessions, physical low-end phones and controller usability remain release gates. Several seconds of wall time were dropped by the bounded fixed-step accumulator during multi-process Studio startup; collision ticks were not jumped, but simulation can run slower than wall time under overload. The CPU sample is not a device FPS claim.

Current mobile gameplay preserves the universal arena aspect with letterboxing; physical-phone legibility and feel still need a playtest. This is a working gameplay prototype, not a claim of finished art, exact Curve Fever parity, production anti-cheat or release readiness. No powers, paid advantages, purchases, live production persistence, publishing, merging or force pushes were enabled. Studio was stopped and returned to its default viewport; network settings were unchanged.
