# Multi-round match, scoring, ties and animated scoreboard

Installed-client declarations, saved runtime UI observations and public documentation are separate evidence classes. Original Trail Wars choices appear in09/10; playable single-round mode5deed16 is unchanged. Source IDs R01–R24, hashes and byte-offset convention are defined in01. Private syntax/range hashes remain in ignored evidence, not these original descriptions.

## Match structure and target

A match contains indexed rounds. Round data carries totalScores and teamScores; each round retains cumulative totals while clearing thisRoundScores/deaths (R02/R04). InitialScore assigns starting points once on round0, excluding them from the round delta (bytes6497410–6497944). Survival, power transfers and optional gap credits affect totals during play. The scoreboard's round delta is the net change, not a separate currency.

Installed Classic FFA declares start10, survival10, and target base50(normal)/25(quick)/75(slow), multiplied by N−1 participants. Flat/flattened add50 to starting score and final target. Thus six-player normal percentage is start10/goal250; flat or flattened is start60/goal300. Classic1v1 base targets100/50/150 likewise use N−1 and the50 bonus. R01 2996770–3002760; R10 6500448–6504060. FTUE/Solo/Camp/team variants differ.

These are **client formulas**, not proof of current Quickplay server settings. Official [matches documentation](https://wiki.curvefever.pro/matches) describes six-player Quickplay goal250. Saved S48/S72 show six-entry Classic FFA CUSTOMS goal300. Flat/flattened would explain300, but the selected scoring setting was not captured. The public [scoring page](https://wiki.curvefever.pro/scoring) examples50 at two players through450 at ten are consistent with50×(N−1); the unresolved version/mode issue is the generic Quickplay250 description versus installed flat/flattened300, not an arithmetic contradiction within those examples.

## Exact client scoring calculations

R08 PointsForHit, bytes6492582–6496480. Let V be victim current score; N active non-abandoned room participants (including dead participants, **not just living ships**); D equipped-defense residual; M attack room modifier; A configured/calculated percentage attack; F flat attack or minimum-flat attack. Global config explicitly supplies exponent0.7, threshold0.75 and maximum extra defense0.5; catalog provenance covers those values. A zero attack skips scoring. Flat attack0 or victim score≤0 returns0.

| Mode | Client arithmetic | Qualifications |
|---|---|---|
| Percentage | ceil(V × min(A×D, mode cap)) | Attack already passes room modifier/fixed-point conversion. Cap fallback1; SurvivalTeams config contains0.5, but that mode need not instantiate this component. |
| Flattened | max(1, round(F×M×(V/average)^0.7×D×N/8)) | Ratio multiplier defaults1 if average≤0. |
| Flat | max(1, round(F×M×D×B×N/8)) | B1 for N≤2 or victim≥0.75×average. Otherwise B=1−0.5×(1−max(0,V/(0.75×average))). |

All three are finally limited to min(calculated,V). Percentage uses ceiling; flat/flattened nearest-integer rounding with minimum1 when prerequisites are nonzero. Ordinary transfers therefore cannot push a nonnegative victim below0. This is not a global negative-score guarantee: generic addScore accepts signed changes without clamping, and mode/debug/admin paths are different.

A steal subtracts that amount from victim and adds it to attacker, recording source/module/prior scores. A server-owned attacker receives no player award. Turrets use a separate fixed-points/STEAL_POINTS branch rather than the ordinary percentage formula. Shield/other cancellation occurs earlier; zero attack prevents transfer.

Module defense is passive equipped-loadout mitigation: with two slots D=(1−defenseUp)×(1−defenseDown), after fixed-point conversion. It is distinct from activated Shield protection. The extra-power branch selects two residual factors rather than multiplying three; see catalog. R06-adjacent5407500–5408574.

Survival is separate from direct-hit stealing. R09 gives configured10 per opponent death survived, with same-tick and disconnected-start rules in01. Gap component rounds GAP_POINTS and ignores zero/missing owner IDs (6499778–6500448); this handler alone does not establish first-gap-only eligibility, which requires collision-owner deduplication evidence in06.

Derived examples, not observed hits: V100/A20%/D0.5/cap1 transfers ceil(10)=10. FlatF20/N6/D0.9/M1/B1 yields round(13.5)=14, capped by victim score. Internal score arithmetic and display interpolation must not be conflated.

## Round end versus match end

Client FFA checks on death when zero/one curve remains. Highest total≥target schedules match end; otherwise round end (R10). A round survivor therefore need not be cumulative leader, and one round win does not automatically win the match. Mid-round scores can exceed target; exact server early-end policy remains **unknown**, because scheduleMatchEnd and authoritative scheduling hooks are incomplete/stubbed in this client.

Match-end event supplies forced flag, winner array and standings. Client finalization guards repetition, marks round/match ended, dispatches winners-before-rewards then winners, and dispatches per-player-finished events for supplied standings. This UI guard does not prove server settlement idempotency or XP/trophy/coin amounts. Forced custom end suppresses normal reward dispatch except the declared solo/custom exception. R11/R12 bytes5284672–5285505 and5294491–5296600.

## Ties and final placement

FFA descending score standings give equal-score players the best occupied reward place, and average occupied rank for ranking calculations. Scores100,100,80 produce reward places1,1,3 and rank positions1.5,1.5,3. Client match-end scheduling constructs winners from all rewardPosition1 entries. This is a tie-capable client representation, **not verified authoritative threshold-tie/overtime policy**. No username, prior-round or ID tiebreaker appears in the inspected comparator; UI order among equals is not a gameplay tiebreaker. R10/R12.

Team ties share competition reward/rank positions directly (not FFA average ranks), R13 5301484–5302960. SurvivalTeams dynamic target is max(base×max(1,teamCount−1), secondHighest+2), expressing a client two-point separation target in that variant (R14). Do not apply it to FFA. ClassicTeams target scales with largest team/participant count, has2v2 overrides and adds flat bonus50×largest team size (R15); detailed variants belong in03.

## Animated ranking: two different components

### Compact live standings

Live list updates total/net delta, dims dead entries to alpha0.3 and reorders on score/death. Y moves toward target with factor0.1 per render update, snapping within0.5px. New-round positioning snaps rather than replaying the big score race. Local row background is subtle. These are rendering declarations, not measured frame-independent tween durations. R16/R17 6369210–6373170 and6378200–6379260.

### Large between-round score race

This explains score changes using previous totals, net deltas, ship/trail progress toward a checkered target, then a separate vertical reorder. It is not merely a decorative leaderboard.

1. Capture new totals/deltas and queue final ranks. Animated display initially subtracts round delta from current total, reconstructing previous score.
2. Wait declared1s after round end, then fade overlay by alpha0.2 per update. This is frame-dependent, not a measured200ms tween.
3. Rows fade/scale3×→1× over100ms with outward-sine easing; starts stagger index×50ms. Local row text is larger.
4. After400ms plus participant fade allowance, emphasize net deltas for400ms and animate total/ship progress. Default ship duration450ms; extra time is proportional to max absolute delta/target, capped1000ms. Intermediate score text uses nearest integer. Underlying score is not replaced by that visual sample.
5. Horizontal progress uses score/target, visually capped1.4× target span. Trail follows; positive progress may puff exhaust. Negative net changes move backward.
6. After the step and300ms swap anticipation plus extra score time, rows move to final score order. Y settles using (6×current+target)/7, snapping within1px. This is a lerp/settle, not a recovered physics spring.
7. Rank-point preview fades over250ms after position settles. At match end, Finished/winner labels replace headers, next-round labels hide, and a500ms callback opens postgame overlay after score animation scheduling.

R18, bytes6387840–6408630 (RoundScoreboardEntry/RoundScoreboard). Duration varies with participant count, score deltas and render updates. Next-round countdown reads ceil((server startTime−serverTime)/1000), minimum1. No guaranteed user skip/interruption policy was recovered. Next on a saved final scoreboard is not proof of skipping an active inter-round race.

## Saved runtime corroboration

S48 Round2, S56 Round4 and S72 Round7/Finished establish visible multi-round state. S70 reports Classic FFA CUSTOMS,5m28s. These are saved points in one completed bot match, not continuous seven-round footage proving all transitions.

Root re-viewed S72: Shagratho321(+80), Apizzi296(+11), Noctivile290(+10), Calibannik290(+25), Duckle185(+31), Nauel90(+0). Equal displayed290 entries occupy third/fourth UI slots; unequal authoritative tie rewards do not follow. S70 details gives Duckle186 versus S72's185. This one-point discrepancy remains unresolved: interpolation/presentation rounding/different state are possible, none verified.

S69 bot/custom rewards show6th place+0, XP0/60 total+0 and battle points0/1000 total+0. No general reward formula or persistence proof follows. S74 Rematch returns to bot power-selection lobby with PLAY; second match was not started. Observed rematch means lobby re-entry, not instant automatic gameplay. Public Quickplay requeue and reconnect timing remain unknown.

## Required validation scenarios

Target crossing with multiple alive; two target crossers same tick; all-last-death draw; equal-score final reward/rank details; no survivors below target; disconnected-start survival credit; abandon/reconnect across rounds; active cooldown/effect reset; uncut negative-delta score race; skip/close during animation; reconnect during scoreboard; empty roster and stalemate. Each needs timestamped authorized practice or authoritative documentation. Client declarations alone cannot close these questions.
