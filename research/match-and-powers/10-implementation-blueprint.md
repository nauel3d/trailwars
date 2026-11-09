# Implementation blueprint and isolated proof

## Preserve the working mode

The playable mode at5deed16 remains unchanged: original50Hz kernel, server authority, practice bots, single-round results/rematch, current SNAP ARCADE Home/HUD and closed production integrations. This branch adds a pure opt-in module, tests, research and an original HTML review; no current bootstrap requires MatchSeries. It is source-available in shared storage but inert until a caller explicitly constructs it. No production mode switch, power engine, live rewards or purchases are introduced.

## Original series proof

`src/shared/MatchSeries.luau` is an engine-independent, server-consumer library. States: Ready→RoundActive→Intermission→RoundActive…→Final. Configuration accepts Circuit (three rounds by default) or Sprint (target12, cap5), winner bonus1 and at most one default overtime. Bounds reject unsupported/unbounded configurations. These are original hypotheses from09, not a copied scoring implementation.

`beginRound()` generates a new stable match-scoped round ID and freezes that round's connected participant set. `settleRound(matchId,roundId,sequence,outcomes)` accepts only a complete authoritative outcome batch. It validates identity, monotonic event sequence, unique roster and simultaneous-placement groups before mutation. A duplicate settled round is a successful no-op; a wrong match/round or stale new event cannot add points. The existing Simulation's simultaneous-death placement convention is understood explicitly. No position/input data or client claim can decide a result through this API because there is no exposed remote.

For a round ofN, an eliminated competitor's points areN−placement; surviving ties earnN−survivorCount; a sole survivor adds1. Co-deaths do not count as opponents strictly outlived. A departed competitor receives0 for that round and leaves later rounds. Past score is retained for history but disconnected players cannot win. Fewer than two competitors finalizes Abandoned with no competitive winner. All remaining competitors participate in a permitted overtime; after its bound, equal top totals share victory. Stable ID ordering only arranges equal rows; it never breaks the tie.

The snapshot copies player totals, competition ranks, winners and the last immutable-style ledger of before/delta/total for presentation. Actual mutable internal data is not returned. Reset/rematch constructs a new library instance/identity. Histories are bounded by configured round/overtime caps; no per-frame work, network messages or object spawning occurs in the proof.

Run only the new pure tests:

```powershell
python scripts/headless_tests.py MatchSeriesTests
.tools/luau/luau.exe .tools/foundation-tests.generated.luau
```

The headless adapter always includes the existing40 foundation assertions. MatchSeriesTests currently adds161 assertions. Full `scripts/check.ps1` retains the existing367-assertion foundation/gameplay baseline plus those161, existing layout/motion checks and all five Rojo builds. CLI success is not a new Roblox multiplayer/device verification for the series; no such claim is made.

## Approved future server adapter (not wired here)

1. Existing MatchService remains the owner of Players, queue, simulation and authoritative inputs. A separate opt-in SeriesCoordinator would own MatchSeries and instantiate one RoundSession at a time.
2. On an authoritative round result, build the complete outcome batch once, including simultaneous placements and disconnect causes. Only the server submits it. Do not expose settleRound to a RemoteEvent.
3. Retain the closed arena geometry through an intermission; send a stable round ledger and upcoming server startTick. At the next round start, reset transient geometry/effects and instantiate a fresh simulation with connected series members. Mid-series joiners spectate/queue; they never change settled roster/points.
4. Round settlement, final match settlement and profile rewards use different unique IDs. Persist final competitive rewards through existing ProfileStore/EconomyService only after eligibility/failure/retry policy is approved. Abandoned/practice series grant no competitive rewards. This proof never calls the economy.
5. Emit an additive protocol: SeriesReady, RoundCountdown, RoundStarted, PlayerEliminated, RoundSettled, Intermission, SeriesFinal and Queue/Home. Include matchId,roundId,eventSequence,serverTick,revision,rosterVersion,mode/config digest. Results carry before/delta/total, competition ranks, winnerIds and reason; never ask clients to calculate authoritative points.
6. Keep the existing match contract/clients backward compatible or use a separate opt-in channel. Late/rejoining clients receive one bounded snapshot plus the latest ledger. Reject stale IDs/revisions; full resync can reconstruct intermission without replaying rewards or every animation.

## Scoreboard motion contract

Reuse existing native Components/Motion/Leaderboard and the approved art; avoid a replacement layout aesthetic. A dedicated inter-round adapter owns the ledger animation: previous totals→show delta→fill progress→one row reorder→brief settle→next countdown. Existing tokens include reorder0.30s, settle0.16s, celebrate0.46s. The HTML gallery demonstrates this sequence with explicit sample values, not imported commercial artwork or an asserted native Roblox result.

Keep gameplay HUD rank changes quiet. Large score-race animation occurs only between rounds/final results. Server state progresses independently of client animation and skip/reduced-motion settings. A new ledger cancels the old animation scope. Hidden screens suspend decorative updates; returning shows the latest state, not a backlog. Reduced motion displays final numbers/ranks immediately. Safe areas and per-component composition remain; phone rows/buttons stay readable without one global stretched UIScale. Controller focus is restored after transitions; touch controls stay disabled while intermission overlays are up.

`11-review-gallery.html` is a local document with Replay, Final Results and Reduced Motion. `scripts/gameplay/verify_match_review.mjs` uses installed headless Edge through Playwright and existing SNAP art. It checks cumulative values, reordering, final result, reduced-motion timers and320/1080-width horizontal bounds. PNG exports and JSON label this a proposal, not Roblox. The gallery scrolls as a research document; this does not make any game Home/HUD scrollable. No extra browser package was downloaded; the missing bundled Chromium was bypassed by selecting already-installed Edge.

## Future power framework — approval required

No representative power was chosen by the owner, so there is **no powers prototype or activation remote** here. A future approved data-only definition may contain ID,family,slot compatibility,initial cooldown,cooldown,activation type,duration,target mask,collision policy,stack family,resource cap and accessible icon/text. Do not treat catalog client numbers as approved balance.

An intent should name a valid equipped slot plus match/round/sequence and, only when necessary, bounded aim/stop input. The server resolves the actual power ID from its loadout. Validate entitlement, active phase, living/allowed actor, slot, cooldown, charges, finite direction and rate budget. Reject unknown IDs, duplicate/stale sequences and old-round actions. Do not accept client damage, hit, score, immunity or duration values.

Use tick timers and explicit stat-modifier ownership. Each effect/projectile has effectId,ownerId,targetId,start/endTick,stack family and authoritative parameters. Expire effects, process scheduled changes, integrate bounded motion and swept contacts, resolve defense/hits once, batch eliminations, then evaluate round end. This ordering is a proposed original contract; reference insertion/rollback order is unknown. Limit projectile count/lifetime, bounce count, concurrent effects, emitted hit events and trail eraser work. A future eraser needs immutable lethal-geometry versioning/deltas, not a visual-only hole.

Cleanup must specify death, owner leave, round reset and match finalization for every family. Reflection transfers credit through a bounded hit ledger. Forced draw/collision state needs an owner stack so one cancelled effect cannot remove another's immunity or leave it permanent. Server snapshots remain decisive; client prediction/cosmetics can be cancelled/reconciled but cannot settle score or entitlement. Add low-end-phone profiling before expanding effects.

Required future tests are listed in05: invalid power/loadout, double activation/cooldown boundary, reflection, shield expiry, traversal landing, stacked speed/thickness, reverse+angle turns, ready power under recharge freeze, teleport cancellation, owned-object persistence after death, active effects after elimination/reset, simultaneous hits and stale/resync traffic. They remain unexecuted until a power proof is approved. Network latency/loss, actual six-client stress and physical controller/mobile usability are separate engine/device gates.
