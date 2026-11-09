# Power interaction audit and future deterministic test matrix

The matrix is a **static branch audit**, not a claim of controlled gameplay experiments. No new authenticated powers match was observed in this phase. C means a concrete client interaction path was inspected; I means a bounded inference from those paths; U means unverified. Every cell still needs authoritative/runtime verification before it becomes a Trail Wars rule. No powers prototype is wired to the current playable mode.

Families: Proj = One/Double/Side/Multi/Scatter/Homing/Boomerang; RayZap = Laser/Zap; Bomb = four thrown explosives; Shield = active power or pickup shield; MoveDash = Brake/Speed Burst/Power Dash/Speedy; Traverse = Jump/Hole/180; Teleport = thrown relocation token; Size = Thin/Thick; Steer = Angle Turns/Reverse/Steer-less; Clock = Clock Block; Hide = Hide Self; Vision = Low-res/Curve-blind/Trippy.

| Family | Proj | RayZap | Bomb | Shield | MoveDash | Traverse | Teleport | Size | Steer | Clock | Hide | Vision |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Proj | C1 | U | U | C2 | U | U | U | U | U | U | I2 | U |
| RayZap | U | U | U | C3 | U | U | U | U | U | U | U | U |
| Bomb | U | U | U | C3 | U | U | U | U | U | U | C13 | U |
| Shield | C2 | C3 | C3 | C4 | U | U | U | U | U | I1 | C13 | U |
| MoveDash | U | U | U | U | C5 | U | U | U | U | I1 | C13 | U |
| Traverse | U | U | U | U | U | C14 | U | U | U | U | C6 | U |
| Teleport | U | U | U | U | U | U | U | U | U | U | U | U |
| Size | U | U | U | U | U | U | U | C7 | U | C8 | U | U |
| Steer | U | U | U | U | U | U | U | U | C9 | U | U | U |
| Clock | U | U | U | I1 | I1 | U | U | C8 | U | C10 | U | U |
| Hide | I2 | U | C13 | C13 | C13 | C6 | U | U | U | U | C11 | U |
| Vision | U | U | U | U | U | U | U | U | U | U | U | C12 |

## Inspected interactions and their limits

| Cell | Client finding | Provenance | Runtime / authoritative gap |
|---|---|---|---|
| C1 | Projectiles use field sets containing trails/ships/abilities, not the projectile field; boomerang can specifically omit trail collisions. Double/Side use a tick-based hit group, while other bullets use their ID. | P07 | Same-tick multiple target hits, server hit grouping and cross-projectile rules remain unknown. |
| C2 | Shield reflects a projectile, sets its owner to the shielding player and scales its base attack by0.8; duplicate shield body IDs and own-owner collisions are excluded. Pickup Shield instead despawns the projectile (bounce=false). | P06/P07/P11 | Repeated reflection between shields, minimum speed and all server credit rules require tests. |
| C3 | Shield PRE_CURVE_HIT handler cancels MINE_EXPLOSION, SHOT_EXPLOSION, SHOT, LASERED and ZAPPED. It does not cancel every arbitrary hit reason or geometric death. Bomb trail-hole creation is separate from hit cancellation. | P06/P08 | Server explosion acceptance is absent from this client. Do not infer a shield prevents trail/wall death or suppresses the blast hole. |
| C4 | Shield stack uses UPDATE_FIRST_ON_STACK, limit1, resetting start tick. No default max-hits value is configured. | P05/P06 | Timer extension and differing new shield parameters are not interchangeable with adding a second shield. Update handler does not copy every new parameter. |
| C5 | Speed stack permits up to4, Slow up to3, Dash1, Speedy1. Stat multipliers apply sequentially in map order with fixed-point truncation. Dash adjusts nominal multiplier against existing speed and cancels its own PRE_CURVE_DEATH window. | P05/P09; CurveStat bytes5221117–5221510 | Exact cross-buff cap, authoritative death order and post-dash collision are unverified; all can create dangerous high-speed routes. |
| C6 | Jump/Hole and Hide transfer forced-draw ownership. Hole sets no drawing and collision=false; Hide sets no drawing and collision=true. Ending one can hand ownership to the other. | P06; Curve.setForcedDrawState bytes5422529+ | Neither callback proves live attack immunity; interaction with teleport/death rollback needs a server event trace. |
| C7 | Thin size stack1, Thin-turn2, Thin pickup2, Thick3; different radius multipliers can coexist and redraw trail boundaries. | P05/P06/P10 | Current size must not retroactively change all old authoritative trail geometry; shipped server rules unknown. |
| C8 | Thin explicitly cancels active thin-related effects when the DISABILTY stack is added or detected. Its cooldown freezes while active, then resumes. | ThinAbility P07 / bytes5335518–5339168 | Test same-tick disable/cancel/activate order; do not generalize this special cancellation to all powers. |
| C9 | Reverse changes the input-direction event sign. Hook listens at HIGH priority and makes90-degree turns on direction edges. Steer-less changes the turn-speed stat. Reverse stack refreshes; steer-less limit3; angle-turn stack1. | P05/P06 | Same-tick Reverse+Hook order is significant and must be tested; U for the precise authoritative combined direction. |
| C10 | Clock Block uses a cooldown-speed multiplier0, refreshes its own single stack start tick, and restores the multiplier on removal. | P05/P06 | It does not directly set canUseAbilities=false. Whether already-ready powers can still fire is a client inference (I1), not a runtime result. |
| C11 | Hide can cancel itself. A different ability normally reveals; ItemAbility release is excepted. Incoming accepted hit and item-collectable pickup reveal. | HideSelfAbility/HideCancellationHandler P09 | Pickups and thrown ITEM collectables are different types; do not claim every benign pickup reveals. |
| C12 | Visual/filter effects share a replace-first stack with limit1. Applying a filter after game mode ended is rejected. | P05/P10 | Which filter wins simultaneous arrival depends on deterministic event order; visual access cannot change server trail geometry. |
| C13 | HideCancellationHandler ends Hide on other successful ability activation, except Hide itself and an ItemAbility release. | P09 | Effects may briefly overlap within a tick; do not promise a hidden shield/shoot combo remains invisible. |
| C14 | Hole uses replace-first stack limit1;180 creates a distinct hole geometry record. | P05/P06/P09 | Jump versus180 versus gap entry, landing and same-tick expiry require separate server tests. |
| I1 | A recharge freeze alone appears not to reject an already-ready ability because trigger conditions check remaining cooldown and canUseAbilities; the freeze only sets the recharge stat. | ActiveAbility P04 + CooldownEffect P06 | Confirm with controlled reference activation before adopting. |
| I2 | Homing search chooses nearby cores and has no Hide check in its inspected selector. Hide retains collision=true. | P06/P07 | This suggests visual hiding is not guaranteed homing immunity; authoritative targeting remains unconfirmed. |

## Cross-system interactions

- **Owner and team:** generic collectables ignore their owner only while age is at most1s, then permit contact. TeamNoFriendlyFire (renderer bytes6503137 onwards; instantiated in Classic Teams and Survival Teams) zeroes same-team attack values and cancels same-team-owned collectable pickup. It does not declare teammate trails harmless: trail-death reasons bypass its score-zeroing expression. Live eligibility still requires server verification.
- **Accepted hit grace:** Curve.createHit (byte5420200) returns false in this client. Curve.hit consumes accepted hit data, ignores another hit while already in hit state, dispatches CURVE_HIT, and applies a mode-configured no-draw/no-collision HoleEffect. Damage acceptance and repeated-hit arbitration therefore cannot be reconstructed from the visual effect alone.
- **Teleport scheduling:** after a thrown token stops, a freeze window starts; COLLECTABLE_PICKUP and PRE_CURVE_HIT events for its owner are cancelled while scheduling. Token despawn unfreezes cooldown. Border wrapping and range300 are client declarations; collision legality at the destination remains unknown.
- **Death:** Curve.kill (byte5419331) removes all current player effects, removes the ship collider, neutralizes input and schedules a trail explosion about1s later. This does not prove all previously thrown mines/projectiles disappear; object-manager persistence is an explicit open question. Ended-mode kill takes a different freeze path.
- **Pickups:**18 effect families /22 target variants are separate from loadout powers. Pickup Shield has no reflection; Cooldown Reset zeroes UP/DOWN/EXTRA cooldowns but does not directly remove a Clock Block effect, so recharge can remain frozen after the reset. Closing Borders affects the arena; Bubbles changes pickup spawn rate. The score report owns any pickup-point bonuses.
- **Turrets:** post-elimination turret bullets are a distinct source with fixed1-point scoring in the client score component, automatic firing schedule, and steering. Their configured no-hole bullets must not be confused with an equipped shot or a new living core.

## Proposed original engine ordering — not recovered Curve Fever rules

Use server-owned immutable input/event sequences and original, documented deterministic ordering: validate intent/loadout/cooldown; expire prior effects; apply scheduled status changes; commit steering/motion; sweep traversal/projectile/collectable contacts; resolve target/defense eligibility; settle each hit/steal once; resolve simultaneous elimination batches; then evaluate round completion. If this order is chosen, test edge cases explicitly rather than silently inheriting JavaScript insertion order.

Each effect needs matchId, roundId, effectId, ownerId, targetId, creationTick, startTick, endTick, stackFamily, parameters and state. Separate simulation state from visual handles. Cancellation must restore only its owned modifiers; death/round reset/leave clear transient effects without reviving expired ones. Server state owns all cooldowns and hits; clients submit bounded slot/action intents with a monotonic sequence. Client rollback/prediction may rewind cosmetic state but must never grant score, entitlement or permanent trail deletion.

## Required deterministic pairwise test scenarios before a power sandbox

| Scenario | Expected test contract to choose/verify |
|---|---|
| Shield × Shot / reflected Shot × second Shield | One hit credit per unique impact; valid reflected owner; bounded bounce count; exact expiry tick. |
| Shield × Bomb / Laser / Zap | Distinguish blocked points from surviving blast-hole geometry; same-tick shield expiry resolved by chosen order. |
| Jump × trail / wall / projectile / Laser | Specify traversal immunity per collision type; landing cannot tunnel through geometry. |
| Teleport × Jump / Hide / freeze / border / elimination | One winning forced-state owner; cancelled schedule releases cooldown/freeze; destination validation server-only. |
| Dash × Speed Burst / Slow / collision / final tick | Effective speed bounded; continuous sweep; no residual immunity or permanent zero steering. |
| Thin × Thick / Thin pickup / Clock Block | Stable multiplier order; old trail widths immutable; cancelling linked effects restores exact base values. |
| Reverse × Angle Turns / Steer-less / simultaneous left+right | No stuck input; define order and neutral behavior; reduced mobility never changes touch-target layout. |
| Clock Block × ready ability / cooldown reset / second Clock Block | Choose ready-power policy; zeroed cooldown remains ready; disable refresh is not additive infinite lockout. |
| Hide × Shot / Bomb release / item hit / visual filter | Visibility feedback matches server state; local transparency never authorizes invulnerability. |
| Boomerang × owner death / reflected ownership / repeated enemy contact | Explicit return target and hit ledger; no immortal orphan projectile or repeated score farm. |
| Fever × own owner / teammate / dead target / still-moving object | Validate eligibility, owner grace, arming, pickup consumption and score event exactly once. |
| Pickups × powers / same-family stacks / shrinking arena | Respect declared family bounds, safe cancellation and geometry-resource budgets. |
| Any × duplicate/stale activation / invalid ID / double slot / round reset | Reject unknown IDs, old round IDs, unavailable slots and cooldown violations; deduplicate settlement; remove active effects after elimination/reset. |

These are proposed tests for a future approved engine, not passing tests in this phase. The isolated MatchSeries proof deliberately contains no power effects.
