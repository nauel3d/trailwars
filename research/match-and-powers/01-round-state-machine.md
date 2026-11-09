# Individual round: installed-client model and evidence limits

Inspected 2026-11-09. Target: Steam App1133700, build26292297; previously observed UI4.3.0. This report describes the installed **client** and saved observations. No authoritative commercial server implementation was recovered. Trail Wars at5deed16 is preserved.

## Source provenance

R01–R24 identify focused inert byte reads in ignored `private/round-static-evidence.json`. They are ordinary source inspection, not invented REA semantic findings. Renderer `resources/build/assets/PlatformService-zkTPtK_x.js` SHA256 `fcaee093cbf48ccaa625c6a2016ed2f05669276402ebb01eb9eb4d90658ec5d6`; constants `app-pNpNNO1T.js` SHA256 `67e91c459da916e8224f4ad266378bedee7974a524fc6fbef2c4daa0b7356bf6`. All offsets below are zero-based UTF-8 bytes, end exclusive. Private records preserve range hashes and raw observations; commercial syntax is not redistributed.

The prior constants graph was reused through REA bundle import. Trace `ev_15212aa18031989b316cee0aec3ce69fa8d5594c50bc24b3def8a79b5f7f90f3` finds ROUND_COUNTDOWN_DURATION but marks receiver/value provenance ambiguous: one node, no traversed relations, partial coverage. Its numeric value therefore comes from R23 byte inspection, not exact semantic tracing or runtime measurement. No whole-renderer semantic scan or native attachment was performed.

## Round sequence

| Stage | Finding | Classification / source | Remaining verification |
|---|---|---|---|
| Lobby and loadout | Saved bot-room S43–S44 show six entries, selected powers, PLAY, ready state and START. | Verified saved UI observation. | Exact server ready/lock/late-join rules; Quickplay comparison. |
| Match countdown | S45 shows countdown label5 and CANCEL. This is separate from per-round freeze. | Verified one label, not full timed interval. | Full countdown and cancellation outcome. |
| Schedule | Round data contains index, server start time, curve spawn conditions, total scores and optional team scores. Scheduler waits for converted server time to reach start. | Client declaration R04 bytes5732838–5734620; R21 6549030–6552120. | Authoritative timing and packet scheduling. Spawn-position/facing/clearance helpers are empty/stubbed in this shipped client. |
| Reset | Gamemode retains cumulative scores, clears round deltas/death positions/end flags. Curves reset effects, stat modifiers, ramp, active/passive abilities. Physics objects are destroyed. | Client declaration R02 5290715–5291730; R05 6484178–6485530; R06 5408574–5410100; physics reset6487593+. | Runtime cleanup of every mine/projectile/status/trail type. |
| Freeze | Base3000ms; round index0 adds configured prematch. Classic FFA/1v1/teams add7000ms, giving10000ms first freeze and3000ms subsequent freezes. Solo/Camp prematch0. | R03 5293120–5293360; R23 constants10570–10700; R01 config2996770–3002760. | Actual first/subsequent input acceptance and motion timestamps. Do not confuse this with lobby countdown5. |
| Spawn grace | Spawn starts drawing off, collision false. Freeze effect lasts freeze ticks; no-draw effect lasts freeze plus durationNoDraw (Classic FFA/1v1/teams1000ms; FTUE/Solo500ms; Camp2000ms). Cooldown-speed0 applies through freeze. | Client effect declarations R05. | Whether every lethal collision family respects the same grace boundary. |
| Active | Survival and hit events change cumulative score. Steering/trails/collider declarations are in prior gameplay research. | R08–R10; prior G01–G07. | Fatal curve/ship/border methods in this renderer are empty: exact lethal server behavior is unavailable. |
| Individual elimination | Curve death and player death are separate events. Optional turrets mean ship death need not end every interaction. | Client event/component declarations. | Post-death input and delayed-owned-object scoring with turrets on/off. |
| Resolution | FFA client checks alive curves on player death. More than one continues; zero/one resolves. Highest cumulative score at target schedules match end; otherwise round end. Teams check living teams. | R10 6500448–6504060; R14/R15. | Server-specific match-end scheduling is incomplete/stubbed here. Exact authoritative trigger/order and multiple threshold crossers remain unknown. |
| Inter-round | Surviving curves slow; filter effects are removed. Large scoreboard waits declared1s, explains deltas/progress, reorders rows and shows next server startTime countdown. | R11/R12/R18. | Full uncut interval; negative delta and skip/close behavior. Default150ms slow-effect transition is not the whole inter-round wait. |
| Next round | Server nextRound data resets round state; scoreboard hides on POST_ROUND_START. | R02/R18/R21. | Fixed server interval not recovered. ROUND_START_DELAY5000 is a declaration without established server use, not proof every gap is exactly5s. |

## Cooldowns and effect reset

Active-ability reset clears freeze state, restores configured initial-cooldown if present, otherwise full normal cooldown, then resets effect-specific state. Each step subtracts cooldown speed in fixed-point units. Thus reset does not make every power immediately ready. Curve reset invokes these resets per round; cooldown-speed0 freezes countdown during the round freeze. R06/R07 bytes5228210–5229060. Per-power charges/reactivation exceptions belong in the catalog; no universal carry-over charge policy is inferred.

## Simultaneous deaths and missing spawns

The survival component considers an opponent to have survived a death if its ship has not died or the death tick being processed is no later than that ship's own death tick. This includes FFA same-tick co-deaths; it is not strict sequential last-alive order. In1v1 equal death ticks take a special branch awarding half the configured survival amount to both once (default5 each), using repeated-death count. R09 bytes6497944–6499778. All combinations still need authoritative event-order corroboration.

At tick0 the same component credits spawned players with survivalPoints times roster members missing from spawnedCurveCount. Therefore configured roster count, connected/spawned players and alive ships are distinct. Runtime tests should include reconnect and deliberately absent start participants.

## Timeout, abandon and rejoin

Constants declare MAX_GAME_DURATION_TICKS=floor(1800×50); ticker requests forced match end at that tick (R22 6471900–6472570; R24 11520–11750). Ticker resets on round reset. This is a client safety-path declaration, **not a verified30-minute whole-match cap or measured stalemate policy**. No smaller authoritative timeout was recovered.

Leave/disconnect and abandon are distinct. Disconnection sets connected false. Abandon also marks abandoned, exposes the icon and invokes score handling: personal total/delta are cleared; in teams, positive score is redistributed across non-abandoned teammates using floor division and remainder allocation. Rejoin data may include next round and game events for reconstruction. R19 6517317–6518330; R20 6595600–6596550. Server rejoin grace, participation eligibility, penalties and reward rules remain unknown.

## Answer boundary

The client round structure is substantially inspectable. Exact spawn safety, lethal collision authority, timeouts and match-end scheduling are not recoverable from these stubs. Saved Round2/4/7 captures and a completed bot-match endpoint corroborate a multi-round product, but are not continuous footage proving every transition. Required next experiments are target crossing while multiple remain; all-last-death ties; interrupted score race; cooldown/grace boundary; delayed-object cleanup; abandon/rejoin across a round boundary. These require authorized authenticated practice or authoritative documentation, not speculation.
