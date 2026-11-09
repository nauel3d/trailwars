# Responsive layout contract

Proposal for approval. This replaces both failed extremes: a long scrolling Home document and shrinking the entire desktop screenshot with one UIScale. Home is always a single complete game menu. The available safe rectangle determines a deliberate composition, with art yielding space before text or actions.

## Coordinate ownership

One ScreenShell owns the safe-area rectangle. Interactive content uses CoreUISafeInsets; noninteractive background can extend underneath system bars. Layout consumes the measured parent rectangle after insets, not a device-name table. Never subtract CoreGui insets twice. Resize/orientation/safe-area notifications coalesce into one next-frame layout pass; semantic selection and in-flight actions survive.

Proposed units are logical screen pixels at UI scale 100%. Type: 18px body default, 16px auxiliary minimum, 22–28px section title, 40–72px display where space allows. Primary actions ≥56px tall, other actions ≥48px with ≥8px gap. Decorative icons can be smaller; their hit rectangles cannot silently shrink with a parent UIScale. Final engine tests must measure effective screen-space bounds.

## Composition selection

Starting thresholds are design hypotheses. Choose the richest mode whose **minimum content constraints fit**, then allow a 24px hysteresis zone to avoid oscillation near a breakpoint. Text preference and long labels can select a more compact composition even on a wide display.

| Mode | Starting safe-content conditions | Home | Collection / shop | Settings / profile |
|---|---|---|---|---|
| Spacious landscape | W≥1180, H≥680, aspect≥1.3 | Rail, large central arena signature, fixed Play/action rail, quiet profile summary | Side-by-side catalog and preview, 2–3 grid columns, detail dialog | Category rail + content, sparse profile metrics |
| Compact landscape | aspect≥1.45, H<680 or W<1180 | Compact top bar, 4 secondary icon+text actions, art compressed/cropped deliberately, Play pinned | 2-column grid with preview on selection, action dock fixed, no offscreen page CTA | Compact category tabs, content pane may scroll, footer fixed |
| Tablet / intermediate | W≥600 and not spacious landscape | Two-zone menu; comfortable controls, reduced logo decoration | 2-column inventory with preview beside/below; scroll grid only | Two-panel or tabbed details as dimensions permit |
| Narrow portrait | W<600 | Logo/status, compact arena vignette, dominant Play, 2×2 secondary actions; **no page scrolling** | Core/Trail tabs, 2-column item grid, selected-item bottom sheet; grid scrolls within a fixed pane | Category tabs; bounded content scroll; Back and Save/status remain visible |

Home's minimum portrait composition fits 320×568 before platform insets: reserve 64px header, 120–160px arena vignette, 56px Play, 112px secondary navigation and 16–24px status, plus gaps. At large text, shorten the decorative headline and reduce/remove the vignette before reducing target or body text size. At very short landscape heights, use a horizontal action layout rather than stacking the portrait screen. Optional stats/XP/marketing copy hide first. No essential action moves offscreen.

## Layout mechanisms and ownership rules

| Mechanism | Intended role | Guardrail |
|---|---|---|
| UDim2 scale + offsets / AnchorPoint | Proportional panel areas with explicit gutters and anchored action docks | Panel owns placement; do not also let a layout own the same Position |
| UIListLayout + UIFlexItem | Rows/columns that wrap or fill available space | Use flex only where child size ownership is clear; no layout + conflicting size-constraint loop |
| UIGridLayout | Known-size item tiles, columns derived from minimum width | Recompute columns from pane width; finite catalog need not virtualize |
| AutomaticSize | Content-driven label/row height | Measure at settled width; never let child Y expand a parent whose Y determines that same child |
| AutomaticCanvasSize | Collection/settings inner content | One scroll owner per axis. Home has no page scroll owner |
| UISizeConstraint | Minimum action geometry, bounded content width | Check final screen-space target after all parent transforms |
| UITextSizeConstraint | Bound decorative/display text | Do not shrink body text to hide overflow; wrap or recompose instead |
| UIAspectRatioConstraint | Core icons and gameplay/cosmetic illustration | Never lock the whole interface to desktop aspect ratio |
| UIScale | Short local press feedback or optional art scale | Not the responsiveness algorithm; no blanket fit-to-screen on the entire interface |
| Nine-slice | Button/card skins and repeatable borders | Corners fixed, center free of variable lighting or notch art |
| ScrollingFrame | Long inventory, settings content, long item description | Fixed header and Close/Back/CTA outside scroll, visible scroll affordance |

## Per-screen invariants

- Home: no scrollbar, no scroll gesture required, Play + all four destinations visible. Under pressure remove secondary summary, shorten headline, simplify art. Do not hide navigation in an unlabeled hamburger.
- Collection: tabs + Back fixed; grid may scroll; selected Details/Equip dock remains fixed. Portrait uses an item sheet rather than stacking a desktop preview and every card into one page.
- Shop: exactly two earnable offers today, both visible on common phones. No empty Featured section. Confirmation and balance never below a catalog scroll edge.
- Profile: identity and key metrics fit; future long history would be a separate inner pane, not a reason to shrink Home.
- Settings: three categories Audio / Controls / Readability. Category tabs and Back fixed, rows scroll if needed. No giant single page of every setting.
- Dialog: max width 560–640px; max height safeH−32. Long description scrolls, action row stays outside. Portrait bottom sheet respects bottom inset, expanded text can use a full-safe-area dialog.
- HUD: no menu rail or shop UI. Match status is compact. Touch steering occupies bottom corner regions, drawn bounds match hit targets; camera/playfield integration must test trail visibility. No joystick or ability buttons.
- Results: primary Play again and secondary Home fixed. Confirmed rewards in one bounded panel; pending settlement is text, never an invented payout.

## Stress cases

Test 320×568, 360×640, 390×844, 568×320, 844×390, 768×1024, 1024×768, 1280×720, 1672×941, 1920×1080 and 2560×1080 ultrawide at 100/125/150% text. Use long translated action labels at +40% and +80%, a 24-character player name, 999,999,999 coins, zero stats, unavailable data and reconciling purchase. Large values use grouped numerals; ellipsis only for identity labels with an accessible full-name detail. Never abbreviate a purchase price to an ambiguous “1K”.

Test runtime mode transitions in both directions. Returning from portrait must restore rail/grid visibility and focus without stale hidden controls. Test multiple input methods on the same viewport. Physical devices, console safe areas and actual controllers remain mandatory after approval; static mockups do not verify them.

## Verification gate

Before broad replacement, build one isolated approved Home shell and ItemTile/Dialog proof in three modes. Assert containment, effective hit bounds, no critical overlap, no hidden focus target, text fit and Home no-scroll. Compare PNG captures with each mode's own approved mockup. Two failed approaches trigger a documented pivot, not more per-device patches.
