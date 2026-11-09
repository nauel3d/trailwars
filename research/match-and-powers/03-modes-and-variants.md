# Modes, lobby settings and rule boundaries

Investigated 2026-11-09. **Public documentation** below describes the currently retrievable wiki, not a version-pinned authoritative server. Installed-build branches and constants are separately recorded in [02-match-lifecycle-and-score.md](02-match-lifecycle-and-score.md). Match settings must travel with any result; do not turn a mode-specific value into a global rule.

| Public mode | Scoring / finish | Powers and scope |
|---|---|---|
| Classic FFA | Personal survival plus steals; cumulative target; documented normal target `50*(N-1)` | Two unlocked powers; Quickplay or custom; up to ten players |
| Classic Teams | Add member scores into team totals; documented target `50*(N-2)*teamSize` | Two powers; custom rooms; two to four teams |
| Survival Teams | Gain one when an opposing team is fully eliminated; target `6*(teamCount-1)` | Blue/green only; fever stealing disabled; passive cooldown variants |
| 1v1 | FFA-style duel with separate rankings | One opponent; do not infer its installed target from the FFA paragraph |
| Camp | Maximize solo survival time | No powers/gaps; documented square sizes 230/360/430/500 pixels |

Source for the table: [official game-mode documentation](https://wiki.curvefever.pro/gamemodes). Pixel sizes are public labels, not recovered fixed-point world geometry.

[Matches documentation](https://wiki.curvefever.pro/matches) describes six-player Quickplay with target 250, loadout selection before readying, opponents' loadouts revealed after readying, and spectator queue entry during an ongoing match. It allows custom rooms of ten and describes ranked customs as four through eight. Abandoning prompts confirmation and may lose trophies. These are documented flows, not a new public-match runtime test.

[Match settings](https://wiki.curvefever.pro/match-settings) separates powers (normal/none/custom, two/three slots), pickups, post-death rocket turrets, map/target/scoring, access/spectators, and team/rank options. Its six documented modifiers affect cooldown rate, attack, gap frequency, speed, rotation, and size. The installed modifier table also has Gap Points; see06 for the build-specific seven-field inventory. Presets save these combinations. A power-free room can still differ through pickups/modifiers/turrets; tests must record each switch independently.

## Documentation conflicts requiring careful scope

- The [scoring page](https://wiki.curvefever.pro/scoring) has a generic team paragraph awarding one per won round. The mode-specific Classic Teams description instead sums survival/steal points. Treat the one-point paragraph as Survival Teams guidance, not proof for both team modes.
- [Rank documentation](https://wiki.curvefever.pro/rank) says **more than four** players, whereas the matches/modes pages include four. It also excludes bots, uneven/single-member teams, quick target, XS/MAX maps, custom powers, third power, modifiers and Camp. Only the installed validator or a permissible ranked test can settle the boundary. No new ranked match was entered.
- Six-player target 250 in generic Quickplay prose does not identify a scoring method. The saved bot room displays 300. The installed flat/flattened target adjustment in report 02 provides a client-declaration explanation; screenshot alone cannot identify the room's scoring selection.
- The overview advertises 30 powers, while the installed registry has its own discovered denominator in report 04. Public copy is not an installed inventory or release note.

## Verification matrix for Trail Wars design review

| Boundary | Current evidence | Missing controlled scenario |
|---|---|---|
| FFA vs team scoring | Documentation plus installed client branch analysis | Same roster/deaths in both team modes; compare server score events |
| Normal/quick/slow target | Installed branches, report02 | Start each mode with 2/4/6 participants and record advertised goal |
| Powers none vs pickups on | Distinct documented settings | Disable loadout powers, collect a pickup, inspect score/cooldown effects |
| Turrets after elimination | Documentation; saved rocket-aim prompt | Aim/fire once in an authorized bot room; distinguish turret points from equipped powers |
| Late arrival and rematch | Documentation; saved rematch-to-lobby endpoint | Continuous join queue to slot admission; no inferred immediate round entry |
| Ranked eligibility | Conflicting documentation | Read current eligibility reason without playing a protected competitive match |

**Proposed Trail Wars adaptation:** launch with one clearly named survival ruleset and explicit cosmetic-only progression. Keep Chaos, teams, pickups and custom modifiers separate opt-ins after approval. No existing Trail Wars mode has been changed by this investigation.
