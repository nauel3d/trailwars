# Pickups, turrets, modifiers and mode filters

All numeric tables here are **Verified by client declaration only** in the installed renderer. They do not establish current server spawn probabilities or effect acceptance. Artifact/version and P-source byte ledger are in04-complete-power-catalog.md. Public documentation is independently recorded by the documentation investigation; differences are version caveats, not silently reconciled.

## Separate systems

Loadout powers are assigned actions. Pickups are random arena collectables with SELF/OTHER/ALL target variants. Thrown fever obstacles are ItemCollectable objects with an owner and arming time; they are not random pickups. Turrets are an optional post-elimination actor. Global custom modifiers change baseline stats/scoring; they are not extra power inventory.

## Installed pickup denominator and values

The PickupType enum and spawn-list expose **22 target variants across18 effect families**, not22 new loadout powers. Source pickup table begins at byte2969720; handlers P11 / bytes5275168–5282368. Duration and factors are configured defaults, before mode/room/server changes.

| Variant | Target | Duration (ms) | Other declared parameters | Default spawn-list weight |
|---|---|---:|---|---:|
| SPEED_SELF | SELF | 3000.0 | {"speed": 2, "turn": 1.65} | 10 |
| SLOW_SELF | SELF | 7500 | {"speed": 0.5, "turn": 1.1} | 10 |
| HOLE_SELF | SELF | 5000.0 | {} | 8 |
| THIN_SELF | SELF | 10000.0 | {"size": 0.5, "turn": 1.1} | 10 |
| HIDE_SELF | SELF | 5000.0 | {} | 10 |
| CORNER_SELF | SELF | 10000.0 | {} | 10 |
| SMALL_TURNS_SELF | SELF | 10000.0 | {"turn": 1.5} | 10 |
| SHIELD_SELF | SELF | 5000.0 | {"size": 25} | 10 |
| BOMB_SELF | SELF | instant / no timer | {"size": 100} | 10 |
| COOLDOWN_RESET_SELF | SELF | instant / no timer | {} | 10 |
| SLOW_OTHER | OTHER | 5000.0 | {"speed": 0.5, "turn": 0.8} | 8 |
| SPEED_OTHER | OTHER | 2500 | {"speed": 2, "turn": 1.65} | 8 |
| THICK_OTHER | OTHER | 5000.0 | {"size": 2} | 8 |
| CORNER_OTHER | OTHER | 10000.0 | {} | 8 |
| REVERSE_OTHER | OTHER | 5000.0 | {} | 8 |
| STEER_LESS_OTHER | OTHER | 5000.0 | {"turn": 0.7} | 8 |
| TRIPPY_OTHER | OTHER | 5000.0 | {"intensity": 4} | 8 |
| CLOCK_BLOCK_OTHER | OTHER | 5000.0 | {} | 8 |
| CHEESE_OTHER | OTHER | 10000.0 | {"intensity": 0.01} | 8 |
| SPEED_ALL | ALL | 2500 | {"speed": 2, "turn": 1.65} | 5 |
| CLOSING_BORDERS_ALL | ALL | 20000.0 | {"scale": 0.1} | 5 |
| BUBBLES_ALL | ALL | 5000.0 | {"multiplier": 3} | 5 |

Weights are relative declarations, not measured probabilities; room blacklists and eligible spawn entries can change the denominator. OTHER excludes the collector and, in team modes, teammates. ALL first applies to the collector, then other living players; teammates are not excluded by the ALL targeting branch. SELF has0 effect-start delay, OTHER/ALL1000ms; pickup appearance/activation delay is separately1000ms.

The nominal global spawn interval is100–4000ms with initial spawn-count0, spawn padding40, radius20 and spawn-rate multiplier support. A negative -1500ms start-delay declaration and start-index staggering exist; their complete scheduled runtime spawn distribution was not established. Do not present the weight table as the observed live Quickplay spawn rate.

Distinct behaviors:

- Speed Self lasts3000ms while Other/All Speed resolves to2500ms; Self Slow7500ms while Other Slow5000ms. These differ from similarly named loadout effects.
- Thin pickup lasts10000ms with radius0.5x and turn1.1x; Thick5000ms with radius2x. Angle/Corners uses90-degree turns, Small Turns1.5x turn rate, Steer-less0.7x. The loadout fever defaults differ (Thick1.65x, Steer-less0.75x).
- Pickup Shield lasts5000ms with radius25 and bounce=false; power Shield lasts1500ms and reflects. Do not combine these two data sources.
- Hole lasts5000ms; Hide5000ms; Reverse5000ms; Trippy5000ms/intensity4; Clock Block5000ms; Cheese10000ms/intensity0.01. Cheese alters gap-like visual/drawing behavior through its own effect; fatal collision implementation remains server-dependent.
- Bomb Self creates a radius100 trail hole; the inspected action passes no point-attack value and killOwner=false. It is not a thrown mine. Cooldown Reset sets all three ability slots to zero but does not remove a recharge-freeze status.
- Closing Borders requests a20000ms shrink toward scale0.1; Bubbles applies a3x pickup spawn-rate multiplier for5000ms. The shrink component rejects a second schedule while one is already active. These are arena systems and need server authority, not just icon effects.

## Custom modifiers

| Modifier | Default | Client UI bounds | Meaning / interaction |
|---|---:|---|---|
| Cooldown speed |1|0.1–3|Recharge rate; higher is faster. Not a direct duration multiplier. Clock Block multiplies recharge by0. |
| Attack |1|0–2|Scales stolen-score attack;0 disables attack stealing, not necessarily the visual effect. |
| Gap frequency |1|0–3|Gap scheduling frequency;0 declares no gaps. Gaps are separate from Jump/holes. |
| Gap points |1|0–3, integer step1|Score multiplier for passing gaps; mode scoring still applies. |
| Ship speed |1|0.2–3|Baseline movement speed; compounds with mobility effects. |
| Rotation |1|0.2–3|Baseline turn speed; interacts with Angle Turns and turn debuffs. |
| Size |1|0.5–2|Baseline ship/trail radius; interacts with Thin/Thick and visual versus collision sizes. |

P12: modifier enum/defaults/bounds renderer bytes3005586–3008236. Other room settings include power DISABLED/DEFAULT/CUSTOM with a power blacklist, power amount/extra slot, pickup enable/blacklist, turrets, team/mode/target/scoring settings. Presence in a room settings model does not prove every public playlist permits arbitrary values.

## Mode eligibility filters

- Classic FFA / Solo / FTUE / Classic Teams /1v1 list no default power blacklist in this inspected client table, while room power disable/custom settings still apply.
- Camp blacklists all9 Shots, all4 Bombs, Shield, Hide and all8 Fevers. The concrete IDs not blacklisted by this table are Brake, Speed Burst, Jump, Angle Turns, Thin, Teleport,180 and Power Dash (8 total). This is a blacklist inventory, not proof that the complete Camp loadout path permits those eight; public documentation describes Camp as power-free. Actual eligibility/defaults require verification.
- Survival Teams blacklists all9 Shots, all4 Bombs and Shield; the remaining17 include mobility/traversal and Fevers. This is the inspected table, not an assertion every team public ruleset activates them.
- TeamNoFriendlyFire zeroes same-team attack and cancels same-team-owned collectable pickup. It does not prove team trail collision immunity. Exact client code and component instantiation are referenced in05.

## Turrets

P13 / bytes5428468–5434168 declares a separate turret actor with no own collider, radius6, automatically scheduled shots, a3000ms nominal interval and1500ms minimum next-spawn wait. Rotation is configured3degrees/tick; a living current bullet can be steered at2degrees/tick. Bullet radius8, added speed5units/tick, acceleration duration750ms, explosion radius10 and hole size0 are declared. The score handler special-cases turret hits to1point with steal enabled; the raw turret attack40 does not make the actual score transfer4percent in that handler.

A turret action succeeds only while controlling a bullet and a turret pickup field exists; what all possible turret pickups represent was not exhaustively recovered. Post-elimination turret spawning is conditional on the game mode/room and another live player. Treat turret points and eliminated-player interaction as part of match scoring, not as resurrection. Projectile lifetime, authoritative targeting/hit arbitration and all ready/cancel transitions remain runtime verification questions.

## Trail Wars recommendation

Keep the current normal mode free of pickups and powers while cumulative scoring is approved. If a later Chaos mode is accepted, add a small readable pickup pool and one explicit global modifier at a time. Do not ship visual impairment, invisible mines, forced control reversal or a full turret economy as launch requirements. Prefer bounded object counts, server-owned spawn seeds/timers, stable event IDs, accessible icons and short status text. These are proposed adaptations, not findings about the commercial game.
