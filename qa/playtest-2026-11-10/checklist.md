# Verification checklist

Status: critical controlled two-client engine gate PASSED. This is an unpublished Studio/local playtest build, not a claim of online release readiness.

| Check | Result | Evidence / limits |
|---|---|---|
| Preserved SNAP Home, real queue, shared server gameplay | PASS | Normal Studio run; isolated playtest project |
| Two actual Roblox clients, replicated active/intermission/final/rematch | PASS | `two-client-pass.json`; two humans represented by automated clients plus two bots |
| Server Homing cooldown/contact/nonlethal score transfer | PASS | Actual contact, powerHits=1, stolen=3; duplicate activation rejected |
| Jump crosses lethal trail, leaves gap, expires | PASS | Real-engine crossing and visible jump; headless wall-lethality check |
| Eliminated player steers separate rocket and hits living target | PASS | Engine turretSteered/turretHit flags; turretHits=1, stolen=1, kills=0 |
| No post-round rockets, no resurrected survivor | PASS | Engine cleanup gate; server-only round lifecycle |
| Three-round cumulative scoring, winner, rematch | PASS | Player1 final83 / Player2 final51; new series observed by both clients |
| Lethal trail kill vs nonlethal hit and wall/self/core death | PASS | Engine owned-trail kill=1; power/turret hits do not add kills; unit edge checks |
| Wins/losses and duplicate settlement protection | PASS | Engine winner1/loser1; round/match idempotency tests |
| Session seconds and safe legacy migration | PASS, mock scope | Engine17/18 elapsed seconds; high-water/migration tests; legacy ownership retained |
| Disconnect/forfeit, lingering owned-trail kill, reconnect | PASS, unit scope | Pure coordinator/adapter tests; no real reconnect network rehearsal |
| Phone portrait and landscape control bounds | PASS, simulator scope | 400×776 and749×381 viewports; powers48px high, steering64px; native captures |
| Controller X/Y and D-pad injected input | PASS, API scope | Native Studio injection displayed actual Homing3.1s/Jump5.6s cooldowns; no physical controller |
| CLI regressions and all place boundaries | PASS | 570 core assertions,33 layout cases, motion tests;97 Luau sources compiled, clean lint/format, seven Rojo builds |
| Real six-human session / adverse network conditions | NOT VERIFIED | Two-client controlled test only; previous six-bot simulation is not six-human proof |
| Physical phones, tablets and controller usability | NOT VERIFIED | Simulator/API coverage only |
| Cross-server lifetime stats / staging persistence | BLOCKED / NOT ENABLED | Explicit MockStore; resets on server restart; no live-data migration attempted |
| Online Roblox hosting for remote testers | NOT ENABLED | Owner publishing approval required; no publish performed |
| Purchases / monetization | DISABLED | No live purchase path |

Normal Studio visual review found correct rank numbers displayed in unsorted array order. The row component now sorts a copied input by rank/ID before calculating animated positions; final native verification is recorded separately. Intermission animation is cancellable, supports reduced motion and local skip. Simulation does not wait for animation.

Earlier engine attempts1–4 are retained. They exposed driver exit/steering timing issues and a short fixture round that expired before a missed rocket could relaunch. The successful fifth run uses controlled geometry with a longer first fixture round; normal rounds retain their own cap. Fixture geometry is never shipped in the normal place.

Console review: no gameplay script exceptions observed. Studio reports a pre-existing Assistant plugin load failure and an existing asset-type warning for203785492; these are not counted as gameplay passes. Physical-device comfort, balance and audio polish still require human rehearsal.
