# Acceptance matrix, unresolved questions and experiments

This investigation is complete for the accessible installed-client/config, public-document and saved-capture scope. It is **not** a claim that every authoritative rule is known. R/C/P/I/U/T are defined in00. A completed client inspection cannot turn U into a verified server fact. No new protected multiplayer or reference-game desktop session was entered.

| Question / acceptance item | Current answer and evidence | Status | Smallest useful remaining experiment |
|---|---|---|---|
| Lobby roster, ready/lock and spectator queue | S43–S45 show bot lobby, loadout, readiness and START; public matches describes queue and loadout reveal. | R/P; authoritative lock rules U | Record one ready/unready/late-join bot-room sequence with room settings visible. |
| Maps, teams, powers allowed and room modifiers | Distinct fields and installed eligibility tables; report03/06. | C/P | Compare a normal/custom preset, keeping all switches in the capture. |
| Match initial score and goal | Installed FFA percentage start10/normal50×(N−1); flat/flattened start60/goal+50. | C,02 | Capture selected formula plus starting score/goal at2/4/6 players. |
| First round seed, spawn positions/facings and safety | Round data includes spawn conditions; relevant generation helpers are stubbed. | U,01 | Repeated authenticated bot starts with event timestamps/positions; no server algorithm inferred. |
| Match countdown versus per-round freeze | Saved lobby label5; client3s base freeze plus7s first FFA prematch. | R/C,01 | Continuous first/second round capture with controls/motion timestamps. |
| Grace and trail/effect cleanup | Client no-draw/grace/reset paths; cooldown resets to initial/default and freezes through prematch. | C,01/04 | Start a new round with an armed object and active status; inspect exact expiry/contact boundaries. |
| Within-round survival scoring | Configured10 per opponent death survived; same-tick FFA rule and1v1 split5/5. | C,01/02 | Two synchronized co-deaths in an allowed bot scenario; compare authoritative score events. |
| Point stealing, caps and rounding | Three distinct client formulas, cap by victim score, average/defense branches. | C/P,02 | Known attack/defense target near integer boundaries, low average and low victim score. |
| Zero/negative scores | Hit transfers capped by victim; generic addScore not globally clamped. | C,02; global policy U | Observe zero score, an over-large hit and a non-hit negative adjustment without assuming a global clamp. |
| Mode-dependent stealing/stats | Mode overrides and team components recovered; report03/04/06. | C/P | Same loadout/action in FFA, duel and Survival Teams. |
| Individual elimination versus continued play | Client has death events, optional turrets and replayed accepted-hit grace. | C/R | Death with/without turret, then attempt one post-death input. |
| Actual lethal collision and accepted-hit arbitration | Fatal geometry, createHit, Zap range and explosion damage branches contain stubs/incomplete server hooks. | U,04/05 | Authorized controlled single hit/contact with known state; no protected-session instrumentation. |
| Round termination | Client FFA resolves at≤1 alive; team variants inspect living teams. | C,01/02 | Last survivor, final simultaneous deaths, disconnect of final opponents. |
| Mid-round target crossing and match end | Client end-check visible; authoritative scheduling path incomplete. | U authoritative, C model | Reach target while multiple remain, then allow round to finish. |
| Inter-round interval and readiness | Client slows survivors, schedules large scoreboard and reads next server startTime. | C,01/02; fixed interval U | Uncut round end to next active movement; interrupt board if UI permits. |
| Animated scoreboard chronology | Previous totals→deltas/ship progress→row reorder→rank preview; declared parameters in02. S72 corroborates endpoint only. | C/P/R endpoint | Capture one full positive/negative-delta reorder at known frame rate; reduced-animation setting if available. |
| Live standings versus between-round presentation | Separate components, alpha/lerp/death and round-start behavior. | C,02 | Same player scoring/death in HUD and later score race. |
| Same displayed final scores | S72 has290/290 in separate rows; client supports shared reward places/average FFA ranks. | R/C; authoritative threshold tie U | Capture exact totals and reward details for a controlled tie; display order alone is insufficient. |
| Scoreboard185 versus details186 | Both saved states retained; interpolation/rounding/state explanations unconfirmed. | R discrepancy | Freeze/read same result state in both surfaces; avoid inferring a new rounding formula. |
| Stalemate/time cap | Client safety tick limit declared; resets complicate whole-match interpretation. | U authoritative, C constant | Long authorized bot round with explicit cap setting; do not wait30min merely to confirm a weak declaration. |
| Rewards/idempotency | Bot custom result showed0 XP/battle points; client UI finalization guard exists. | R/C; server reward settlement U | Not needed for this phase; production reward verification requires an approved separate scope. |
| Abandon/reconnect/rematch | Client abandon clearing/team redistribution and replay data; S74 rematch returns to lobby. | C/R | Interrupt across a round boundary, reconnect within visible grace; rematch once. |
| Complete power inventory |31 concrete enum/factory IDs, Random101 selector, orphan Saber config;39-field CSV. | C; all live/account availability U | Resolve only availability disputed for a selected future proof, not unlock all powers. |
| Every power parameter/effect | Defaults/mode overrides and inspected handlers in04; absent values marked unknown. | C/I/U per row | Choose exact powers first, then controlled activate/contact/expire captures. |
| Pairwise interactions |12×12 family audit and high-risk scenario contracts in05. | C/I/U; not runtime-tested | Shield×shot, Jump×trail/expiry, Clock×ready ability, Hide×throw, death×owned object. |
| Pickups/turrets/modifiers |18 families/22 target variants,7 installed modifiers, separate turret scoring. | C/P,06 | Record targeting, owner/teammate rules and active-object cleanup separately from loadouts. |
| Camp power eligibility | Public no-powers guidance; installed blacklist alone leaves8 concrete IDs unblacklisted. | U reconciliation,03/06 | Inspect complete permitted Camp loadout/default path if this mode is chosen for Trail Wars. |
| Version/build parity | Installed hashes stable; wiki not pinned; no usable4.3.0 changelog recovered. | C/P/U parity,07 | A version-pinned official change log would resolve stale copy; no need to repeat failed shell pages. |
| Continuous complete match | Saved endpoints cover Round2/4/7 and5m28s result, but no continuous complete-match video. | U full sequence | One permitted full bot-match recording with initial settings, only if needed to settle above gaps. |

## Engineering acceptance and approval boundary

The optional original MatchSeries library has executable tests for2–6 competitors, cumulative totals, fixed-round/target finish, co-death and time-cap ties, bounded overtime/shared victory, disconnects/abandonment, duplicate settlements, stale/cross-match events, malformed outcome groups, snapshot isolation and fresh rematch state. It has no client remote or live-mode integration. The baseline367 assertions remain in the full source check.

Invalid power IDs, loadout entitlement, double activation, cooldown expiry, and effect cleanup after elimination are specified in05/10 as **future power-engine tests, not tests passed in this phase**. Issue4 requires owner choice before a representative2–3-effect prototype. None has been selected/implemented. Default rules, live rewards, purchases, rank and publishing remain untouched. Approval is the next dependency for game-changing work, not a reason to weaken the evidence boundary.
