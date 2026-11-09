# November 10 playtest build

Issue #6 supersedes the earlier powers-free launch recommendation. This isolated place combines the preserved SNAP ARCADE Home with server-owned gameplay, Homing, Jump, post-elimination rockets, cumulative multi-round scoring and statistics. Original project targets remain available.

## Build and run

From the repository root in PowerShell:

```powershell
./scripts/bootstrap.ps1
./scripts/check.ps1
./.tools/rojo/rojo.exe build playtest.project.json -o dist/TrailWarsNov10Playtest.rbxlx
```

Open `dist/TrailWarsNov10Playtest.rbxlx` in Roblox Studio. Use **Test → Server & Clients** with two clients, press Play in both Homes, and use the controls document. Two humans queue after two seconds; a solo tester waits eight seconds. Bots fill to four; up to six humans can join. Players must join before a series begins; late arrivals wait for the next series. This is a current-server queue, not cross-server matchmaking.

Default: target 40, at least three rounds, at most five normal rounds, one optional overtime round before a shared tied victory. Everyone starts with ten points. Each opponent strictly outlived awards ten points; tied eliminations do not award points against each other. Powers transfer available cumulative points immediately. Host settings can shorten the series. Disconnecting forfeits the match once. Lethal enemy-owned trails award kills, including trails whose owner has departed; self trails, walls and mutual core collisions award deaths without invented kills.

## Automated real-engine reproduction

Build `playtest-tests.project.json` to `dist/TrailWarsNov10EngineTests.rbxlx`, open that separate place, and run from the Studio **Edit** command context:

```lua
game:GetService("StudioTestService"):ExecuteMultiplayerTestAsync(2, {case="Nov10", players=2})
```

The test place uses controlled geometry and real RemoteEvent inputs in two actual clients. It requires genuine Jump crossing, Homing contact, a lethal trail, turret steering/contact, three rounds, final results and rematch. It compares statistics against the event log. The normal place excludes these fixture scripts. `two-client-pass.json` records the successful run; attempts 1–4 are retained to disclose earlier test-driver/timing failures.

## Statistics and storage

Wins, losses, rounds, kills, deaths, power hits, turret hits, stolen score and elapsed seconds are server-owned. Separate idempotency ledgers prevent duplicate settlement. Session elapsed time uses a monotonic high-water mark; Home, queue and AFK time are included. Profile displays hours/minutes/seconds. Legacy coins, cosmetic ownership, settings and round statistics are preserved by an additive versioned migration; old round wins are not invented match wins.

**This build deliberately uses MockStore: persistence lasts only for this running server.** Restarting the server resets these test profiles. Cross-server lifetime persistence, staging DataStore permissions and live migration have not been validated. No live player data or purchases are accessed. Do not present this limitation as persistent lifetime statistics.

## Evidence and release scope

See `checklist.md`, `controls.md`, `two-client-pass.json` and the actual Studio recording. Native engine automation is not a substitute for physical phone/controller checks or a human multi-device online rehearsal. Nothing has been published or merged. Remote testers cannot access this unpublished place as a normal live Roblox experience until the owner approves and performs the release/hosting step.

`verified-normal-gameplay.mp4` is an uncut110-second Studio window recording of the normal target, including three rounds and the corrected final scoreboard. `verified-final-frame.png` is its actual frame at108seconds. `phone-controls.png` and `profile.png` are native Studio captures. Earlier recordings/screenshots remain preserved locally; the committed recording shows the final verified row-order implementation. `build-manifest.json` identifies the locally built place by SHA256.

Reference evidence was reused rather than restarting REA: saved match/power investigation plus official [match settings](https://wiki.curvefever.pro/match-settings), [survival](https://wiki.curvefever.pro/survival) and [scoring](https://wiki.curvefever.pro/scoring). These establish reference intent; Trail Wars cooldowns, steering, damage and scores are our own explicitly configured implementation, not claimed server-equivalent reference rules.
