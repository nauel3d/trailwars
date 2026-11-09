# Visual evidence, documentation reconciliation and REA boundary

Investigated 2026-11-09 using preserved files. No new desktop automation, authentication attempt, paid action, process instrumentation or competitive-session capture occurred. REA source-specific findings are documented in reports 01/02/04/05/06 and the source ledger; original prose here does not imply a recovered authoritative server.

## Saved visual identities and what was actually inspected

| ID | Preserved evidence | SHA-256 / coverage |
|---|---|---|
| V1 | Official Steam trailer, `research/gameplay-reconstruction/private/video-steam-trailer.mp4` | `d33527625e3cbc9b3cfb0e73bb6fd8c23fa8b9a567a160f4b63cd6a8b2596146`; 56.389667s, 1690 frames,1920x1080,29.970fps |
| S48 | `research/screenshots/S48_bot_observed_2026-11-08T23-23-26-936Z.jpg` | `3854465d02c9953b75a3e52882a207f158a68cb93805d629967864d485a48ad8` |
| S70 | `research/screenshots/S70_match_details_2026-11-08T23-29-09-205Z.jpg` | `8fdddc93122bcf6affd695467499ef635ffed51bdece0f60c51d31dfafbf4237` |
| S72 | `research/screenshots/S72_scoreboard_2026-11-08T23-30-00-376Z.jpg` | `6473f8f9361e98a4194fc78928058b7e5e8a34c7cfda873a2e9153dacb02ec24` |

V1's decoded three-second overview and the actual S48/S72 images were reviewed again for this phase. Existing full-size frame/timing analysis is preserved in [the prior video report](../gameplay-reconstruction/video-evidence.md). Source is the [official Steam listing](https://store.steampowered.com/app/1133700/Curve_Fever_Pro/); the trailer is an edited promotion, not a continuous match. Captures' filenames encode UTC on November 8; these events occurred November 9 in Africa/Lagos. Do not interpret filename timestamps as simulated round time.

| Evidence window | Observed | Cannot establish |
|---|---|---|
| V1 0–6s | Logo/promotional opening, sparse gameplay at 6s | Initial cooldown, spawn sequence, countdown length |
| V1 9–15s | Attacks, effects and changing score labels; promotional attack/steal captions | Which exact power/score formula is active; authoritative hit ordering |
| V1 18–33s | Gap-like trail sections, turning, projectiles/area visuals, separate 1v1 caption | Guaranteed pickup/power identity, durations, hitboxes, same-tick cases |
| V1 36–40s | Promotional win caption over moving ships | Final-round completion, winner tie-break, settlement or rematch |
| V1 42–56s | Promotional end cards | Any round boundary or inter-round animation |
| S48 | Round 2, goal 300, six score rows; local 70; five visible +10/skull markers; gaps and power symbols | Precise elimination cause, who received which server event, scoring mode |
| S70 | Saved details report Classic FFA/CUSTOMS, 5m 28s; local 90; 70 first-round points; 3 opponents outlived; 0 round wins | Complete chronology of seven rounds or repeatable duration |
| S72 | Round 7, goal 300, Finished winner surface; winner 321 with +80; local sixth 90 with delta 0; six ship/bar rows and finish line | Animation path, easing/duration, tie-break at identical displayed totals |

S72 displays two adjacent players at 290 with different ranks. That establishes that equal **displayed** totals can occupy separate places; it does not reveal whether underlying fractional totals differ or what tie rule was applied. Duckle is 185 in S72 but 186 in S70's details. Preserve the discrepancy: rounding, interpolation or another explanation is unconfirmed. Earlier occluded S47/S67/S68 images remain excluded as visual proof. Their accessibility trees cannot repair occlusion or supply missing motion.

The saved traversal reached the end of one bot match and later a Rematch-to-lobby endpoint (S74); it did not record a continuous full match. The prior bot-results observation is meaningful but is not a controlled experiment validating every round, tie and scoring transition. No new complete-match observation is claimed.

## Animated round scoreboard: evidence hierarchy

The [scoring documentation](https://wiki.curvefever.pro/scoring) describes this order: previous totals, round deltas, ships advancing toward a finish line, then descending-score row sorting. Live rows show deltas and fade after death. S72 independently corroborates the ship/race layout and final endpoint. Actual inter-round movement timing and a complete reorder sequence are absent from the saved montage/captures; installed client functions in report 02 can establish declared animation behavior, not observed execution. Reusing a SNAP ARCADE treatment for the same explanatory sequence is a proposed original adaptation, not a reconstruction of proprietary artwork.

## Primary public source checks and stale-copy risks

Public pages were retrieved through the web reader on 2026-11-09. A private factual transcription and URL/web-reference manifest are saved as `private/public-doc-facts.json` and `private/public-doc-facts-manifest.json`; transcription SHA-256 is `5d22642f90d23e8fba9a7f243a1fa2651a1604debfa125cdc6e31dc5d5ba1f36`. This is **not** a publisher HTML hash. Direct HTML cache requests returned 403 and were stopped. No full copyrighted article or reference image is redistributed in these deliverables.

- [Official overview](https://info.curvefever.pro/home) advertises 30 powers and two equipped. Installed registry evidence takes priority for the installed denominator, while server availability remains separate.
- [Powers documentation](https://wiki.curvefever.pro/powers) describes four categories, configurable up/down actions and initial cooldown. [Attack documentation](https://wiki.curvefever.pro/attack) distinguishes shield reflection, projectile/laser/zap, thrown fevers and bomb triggers. They do not provide a complete version-pinned numeric catalog; report 04 uses installed declarations.
- [Survival documentation](https://wiki.curvefever.pro/survival) additionally describes a first gap-collectable award of 1 and optional post-death turrets. These are separate from equipped powers and ordinary +10 survival awards. A collection may not mean every later passage through the same gap awards again.
- [Pickups documentation](https://wiki.curvefever.pro/pickups) lists 18 effect families with self/opponent/all targeting symbols. Report06 compares them with installed pickup entries; do not count each colored target variant as a newly equipped power.
- [Scoring documentation](https://wiki.curvefever.pro/scoring) distinguishes percentage, flattened and flat methods. Mode/default differences and the 300-point saved goal must be reconciled with the installed branches, not silently normalized to older 250-point prose.
- [Official March 14, 2026 tournament page](https://site.curvefever.pro/tournaments/tournaments-2026/2026-03-14-normal-ffa-tournament) specifies flat stealing, marked as added March 11. This dates that event's rule selection, not the installed client's release or universal default. Tournament settings are not ordinary Quickplay rules.

## Changelog search boundary

The public `/changelog` page returned only the JavaScript application shell through the web reader. The official Steam news API (`ISteamNews/GetNewsForApp/v2`, app 1133700, count 30) returned one release-announcement entry dated 2026-09-12; cached JSON SHA-256 `2a09d099b5e7288f6a8df22953e21f7f6cd9fbbe4e127c4c4fd7dde88c5cbba3`. It does not supply a 4.3.0 balance changelog. No version parity is inferred from a recently crawled wiki. Further changelog probing stopped because installed declarations answer the catalog question more directly.

## Remaining high-value visual experiments

If an authorized, authenticated bot room becomes accessible through permitted tools, one continuous match capture should record the room's scoring method, target, power loadouts and modifiers first. Then inspect one round boundary, an exact displayed-score tie, final threshold crossing, and rematch. Powers need isolated before/activate/contact/expire samples with visible tick/time markers and known target defenses. Those experiments would resolve specific unknowns; replaying the Steam montage or collecting more unrelated menu screenshots would not.

## Issue4 REA reuse and focused static work

The active REA session was checked, then the prior canonical constants bundle imported (four records). Module identities were paged from the existing JS-C parent; no repeated full application analysis. The round investigator separately imported the bundle into its own tool session and traced ROUND_COUNTDOWN_DURATION, yielding `ev_15212aa18031989b316cee0aec3ce69fa8d5594c50bc24b3def8a79b5f7f90f3`: partial/ambiguous property provenance with no numeric-value proof. Inert byte inspections supply the exact constants and handlers, with24 round range records plus the P01–P13 catalog scope. Those local source IDs are intentionally distinct from REA-derived conclusions. Whole-renderer semantic parsing, native-provider installation and live protected-process attachment were unnecessary and not attempted.
