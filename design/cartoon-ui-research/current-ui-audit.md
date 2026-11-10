# Current UI audit — evidence before opinion

## Preserved checkpoints

Actual starting HEAD was `b1767dbde98faef925652f8060d31c3b3ac3c902` on `feature/candy-comet-finalization`, with two source files and QA evidence uncommitted. These were preserved separately as `7419afd` on that branch, then design work began on `design/cartoon-ui-research`. Known-working `bbd39c7`, approved slice `43532ca`, all previous 46 proposals, navigation and tests remain untouched.

The finalization checkpoint is **not certified ready**. The most recent real two-client run reached server Final but failed client final/winner presentation assertions. The latest visible-client interval sample was 16.668 ms mean /18.060 ms p95 before the last cosmetic detail adjustment. Earlier 18.895 /24.513 ms normal-client findings remain preserved. Managed-client render stalls are unresolved; no engine cause or physical-device FPS is claimed. These are carry-forward implementation risks, not a reason to modify gameplay during this design assignment.

## Actual images inspected

| Evidence | Actual observation | Artistic judgment and concrete proposal |
|---|---|---|
| `qa/candy-finalization/after-home.png` | Cream/mint field, small title at top left; huge left-aligned PLAY; four identical bottom destination rectangles; small face cores in a sparse demo. | Strong palette and primary action already work. Four bordered destinations feel assembled; replace with quiet labeled shelf, one active trail underline, original category icons. Compose title and character demonstration together rather than independent corners. |
| `qa/candy-finalization/actual-gameplay.png` | Board centered; separate standings box, rocket-pilot box, bordered HOME, paired power boxes and steering boxes; very small mostly circular racers. | Too many equally outlined surfaces dilute hierarchy. Board owns the strongest ink edge; essential score is flat text, powers get physical depth, pilot gets an unboxed symbol + instructions. Avoid another container merely to hold each label. |
| `qa/candy-finalization/after-results.png` | Centered winner strip, rankings panel, four repeated filled rows, coral PLAY AGAIN; trails remain behind. | State is understandable, but winner is another row. Give the winner an asymmetric character stage; standings become a score race with before/delta/final. Do not grant rewards for visual satisfaction. |
| `qa/candy-comet/after-portrait.png` | Compact arena above a large quiet middle; small illustration banner; powers near bottom and steering at bottom corners. | Controls have separation; some space is needed for thumbs and readability. Use part of the middle for a short local identity/standings group, not more decoration. Keep safe areas and physical board ratio. |
| `qa/candy-comet/native-source-art.png` | Consistent six-color face cores with single glint, dark visor and small rockets; artwork is clearest enlarged. | A sound foundation. Give vehicle a distinctive fin/tail silhouette for large illustrations. Gameplay must retain honest tiny silhouettes; no pretend oversized hitboxes in mockups. |
| `qa/playtest-2026-11-10/profile.png` | Genuine wins/losses/kills/deaths/hits/time are centered as compact plain text, with much empty space. | Information lacks grouping and personality. Use a racer portrait, one big wins figure, readable paired metrics and explicit storage context. No fabricated leagues, badges or progression. |
| `design/ui-fresh-direction/snap-home-v1.png` | Earlier **design proposal**, not gameplay: broad flowing trails, strong wordmark, coral CTA and secondary navigation. | Retain curved-trail identity and asymmetric energy. Do not substitute this proposal for actual-engine evidence. |

## Source and recording review

Reviewed `CandyCometArt`, `CandyCometRenderer`, `CandyLayout`, `PlaytestApp`, `PlaytestScoreboard`, `MatchPresentation`, the four-item `Catalog`, Home/AnimatedArena/Components/UICues, `AudioCatalog`, `design/motion-system/README.md` and previous responsive proposal documentation. Existing original WAV construction and cue mapping were inspected; waveform durations are recorded separately. This does not assert an audio listening test or working Roblox playback.

The gallery links the baseline and recent actual Studio recordings. Their presence is not a claim to have watched every frame in this pass. The verified captures above are the basis for visual criticism. Current Shop/Customize remain preview systems; source truth has Starter core, Starter trail, Dashed trail (100) and Ring core (150). Proposed inventory layouts use these names and prices, never imply a live purchase or unavailable progression.

## Problems we will not invent

Current type is legible and the palette is cohesive. There is no evidence that the current game has artificial glossy gradients everywhere; the more obvious weakness is flat, repeated construction. Symmetry is useful in competitive HUD alignment; it is weak when applied indiscriminately to Home and victory. Empty space is not automatically a bug. Character art should not turn into visual noise over lethal trails.

Design status: proposals only. The pending rematch/final regression must be fixed in a later authorized implementation phase regardless of the selected art direction.
