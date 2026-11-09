# Gameplay video evidence — bounded reconstruction reference

Recorded 2026-11-09. This report distinguishes observed rendered footage, approximate image measurements, and unknown reference mechanics. It does not recover source constants or claim that trailer playback equals simulation time.

## Source and inspection

**V1 — Curve Fever Pro Trailer**, movie ID **256759594**, published on the [official Steam listing](https://store.steampowered.com/app/1133700/Curve_Fever_Pro/). Discovery: [public Steam appdetails](https://store.steampowered.com/api/appdetails?appids=1133700). Its metadata supplied this [HLS master](https://video.akamai.steamstatic.com/store_trailers/1133700/239161/ba5d3ecfe9ca7f45ea1d5a23624f9d20aba8e19d/1751193303/hls_264_master.m3u8?t=1772365672). A video-only highest-resolution copy was successfully remuxed with the installed imageio_ffmpeg executable. A separate attempted parallel segment fetch timed out and was not used as evidence.

- Local private copy: `private/video-steam-trailer.mp4`, 33,303,794 bytes.
- SHA-256: `d33527625e3cbc9b3cfb0e73bb6fd8c23fa8b9a567a160f4b63cd6a8b2596146`.
- OpenCV container/decode metadata: **1920 × 1080**, **1690 frames**, **30000/1001 fps**, duration **56.389667 s**. This is the retained video's duration, not a match duration.
- Actual inspection: decoded contact sheet every 3 seconds across the entire video, then decoded full-size samples at 5/5.5/6/6.5, 23/23.5/24/24.5/25/25.5/26/26.5/27/27.5/28 and 37/37.5/38/38.5/39/39.5/40 seconds. `private/video-overview.jpg`, `private/video-sequence.jpg`, `private/video-frame-*.png`, `private/video-probe.json` preserve those samples. No claim of having watched inaccessible YouTube footage or listened to audio is made.
- The footage contains earlier branding, Goal 250 and Round 2 at 24s. Its exact build/date is unverified. It is **not established as build 26292297 / UI 4.3.0**. Use existing installed-build captures for current UI facts.

The older official reveal URL supplied during investigation, [Curve Fever Pro reveal](https://www.youtube.com/watch?v=0oSS2Ve-Nqo), was not retrieved or inspected in this pass and supplies no measurements.

## Timestamp ledger

Times below are nominal seek times in V1. The 24.0/24.5 samples correspond approximately to frames 719/734, or 23.990633/24.491133s. Other times have approximately one-frame (0.0334s) seek granularity.

| Question | Inspected interval | Observation and boundary |
|---|---|---|
| Forward movement | 23.9906–24.4911s | Multiple colored ship/head markers advance while deposited trails remain. Purple head follows a straight diagonal; green head travels approximately horizontally near bottom border. Input state is not visible; this alone does not establish what happens when no key is held. |
| Turning | 24.0–24.5s; 37.0–40.0s | Orange, blue and green paths show smooth rounded arcs and changing headings. The latter close-up has camera movement/zoom and powers, so its pixels are not used for normalized speed. Exact held-key turn rate is unknown. |
| Trail creation | 24.0–24.5s | Purple trail grows behind the moving head while its earlier endpoint remains fixed around (731,657). Green bottom trail also extends. |
| Trail persistence | 25.0–28.0s | Long earlier path portions remain while heads advance. Camera effects occur; no lifetime/despawn duration is measured. |
| Trail gaps | 18s overview; 25.0–28.0s | Disconnected trail sections and rounded endpoints are visible. No defensible periodic interval, gap length distribution or cause can be recovered from this edited material. |
| Core versus trail width | 24.0–24.5s | White/colored head markers are visibly wider than the solid trail body; particle wakes/score labels/icons are separate decoration. Approximate visual widths below are not collision hitboxes. |
| Wall interaction | 24.0–24.5s; 25.0–28.0s | Green travels close to bottom/right arena edges. No isolated wall impact with unambiguous elimination cause was observed in these samples. Exact wall padding and lethal threshold remain unknown. |
| Self/other-trail collision | 6.5s, 18s, 25.0–28.0s, 37.0–40.0s | Crowded curves, effects and attacks are visible; no controlled before/contact/after sequence isolates self-trail death or enemy-trail death. General trail danger is corroborated by official listing copy, not measured here. |
| Countdown | 5.0–6.0s; 23.0–24.5s | Sparse opening field and heads are visible, but no readable complete numerical countdown. Installed-build S45 separately observes a match-start label of 5; it does not measure round-start duration. |
| Round end/winner | 36.0–40.0s | Promotional caption “Win” overlays continuing play with two visible heads. It is not a verified winner screen or last-survivor transition. No complete round boundary/round duration measured. |

## Approximate measurements

The board in 24.0–24.5s is almost full-frame, with inner horizontal bounds approximately x=6..1914: **W ≈1908px**, uncertainty ±8px. Earlier trail anchors and boundary remain fixed across this half-second pair; no obvious zoom/cut occurs in that pair. Coordinate picks are manual image estimates, not machine segmentation. Broad intervals intentionally include head shape, antialiasing and point-selection ambiguity. Frame samples alone cannot prove playback speed or absence of a speed modifier.

| Quantity | Approximate image evidence | Interval / interpretation |
|---|---|---|
| Purple head travel | (626,545) → (574,488); displacement ≈77px in 15 frames / 0.5005s | **0.070–0.095 W per video-second** (roughly 134–181px/s); central estimate ≈0.081. Straight segment makes chord/path difference small. This is observed screen travel, not exact base speed. |
| Green head travel | (1638,1045) → (1717,1048); displacement ≈79px over same interval | **0.070–0.095 W per video-second**; agrees with purple within manual uncertainty. Player powers/input not identified. |
| Orange curved trail radius | Circle-like trail arc around (1411,405), spanning roughly x=1354..1468 | **48–72px = 0.025–0.038 W**. Visual circle-fit estimate only; continuous held-input and exact circularity unverified. |
| Visible trail body width | Straight purple/green and clear orange arc portions, excluding wake | **9–15px = 0.0047–0.0079 W**. Compression, orientation and antialiasing affect visible edge. |
| Visible head/core marker width | Purple/green/blue ship/head shapes, excluding long particles, UI and labels | **16–26px = 0.0084–0.0137 W**. Cosmetics differ; does not recover circular core diameter or hitbox. |
| Derived angular-rate family | If travel speed above is unmodified and the orange radius approximates a held turn, omega=v/r | **1.8–3.8 rad/video-second** (about 105–218 degrees/s). **Inference only**, mixing players in a trailer; do not describe as measured control rate. |

These intervals support a tunable independent prototype around speed **0.08 arena-width/s**, trail width **0.006 arena-width**, and turn radius **0.03 arena-width**, if desired. Those are custom defaults selected inside broad visual intervals, **not recovered original constants**. A 40-second round cap, 3-second countdown, collision grace, gap cadence and scoring choices cannot be derived from V1 and must be explicitly labeled custom if used. Arena height is separate from width; do not treat these normalized widths as viewport fractions when the board is letterboxed.

## Bounded official tutorial review

Reviewed [REA guides](https://rea.tools/guides/), the [browser observation guide](https://rea.tools/guides/browser/), and [REA showcases](https://rea.tools/showcase/). The browser example separates an observed action/network request from later code tracing and states that earlier requests lie outside a capture window. The reconstruction showcases emphasize validating recovered behavior against an original artifact. Applied here: preserve source identity, separate images from inference, give narrow measurement windows, and leave collision/countdown/round rules unresolved. No REA installation or broad provider setup was needed for decoding this public video.

## Privacy and remaining evidence

Private reference video and decoded screenshots stay under `research/gameplay-reconstruction/private/`, currently covered by `/research/*` ignore rules. Commit only this written observation report and `measurements.csv` if explicitly force-adding research deliverables; do not add the private directory. No commercial media are proposed for Roblox or GitHub.

The measurements partially answer movement, turn shape, trail deposition and relative visual width. Exact controls/physics constants, core hitbox, swept collision rule, self-collision grace, wall behavior, trail gap timing, complete round countdown and last-survivor/round-end timing remain unresolved. The current-build screenshots and accessibility report `../04_gameplay_and_controls.md` are complementary evidence and must retain their own limits.
