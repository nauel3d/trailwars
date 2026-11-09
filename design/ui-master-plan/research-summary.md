# Research and design rationale

Reviewed 2026-11-09. Primary sources below inform design proposals. These are neither measured Trail Wars user outcomes nor proof of higher clicks, retention or revenue. No new Steam/REA or Nintendo runtime inspection was conducted.

## Nintendo principles, interpreted for Trail Wars

| Source observation | Design inference / proposal | Limit |
|---|---|---|
| Big Brain Academy developers describe observing children, adjusting difficulty and softening negative answer sounds | Use a gentle error cue, understandable labels and an encouraging Play again. Test novice comprehension rather than assuming fast navigation | This interview does not quantify Trail Wars retention or prescribe our UI timings |
| Nintendo Switch Sports developers describe continuity between art, interaction and sound, and balancing music so interaction cues remain clear | Make tactile buttons, restrained motion and short sounds one coherent material language. Avoid an unrelated flashy victory style | Do not import its sports setting, menus, sounds or characters |
| Kirby developers describe allocating UI space for longer English text rather than squeezing other languages into Japanese-sized controls | Design for long labels before export; wrap/recompose with a text budget. Never solve localization with unreadable blanket scaling | Does not prove a particular font or pixel size is universally accessible |

Sources: [Big Brain Academy, chapter 2](https://www.nintendo.com/sg/interview/azls/02.html); [Nintendo Switch Sports interview](https://www.nintendo.com/en-gb/News/2022/May/Ask-the-Developer-Vol-5-Nintendo-Switch-Sports-2215553.html); [Kirby interface/localization discussion](https://www.nintendo.com/ph/interview/arzg/04.html). These are historical first-party process accounts, not claims about the current versions' uninspected menus.

## Current Roblox engineering evidence

- [Adaptive design](https://create.roblox.com/docs/production/publishing/adaptive-design) recommends adapting available content, text and input. [Cross-platform guidance](https://create.roblox.com/docs/projects/cross-platform) supports input-aware action presentation. The proposal therefore chooses compositions from safe parent dimensions and retains semantic state when input changes.
- [List/flex layouts](https://create.roblox.com/docs/ui/list-flex-layouts) can own child arrangement. [Position and size](https://create.roblox.com/docs/ui/position-and-size) describes dimensions/anchors. [Size modifiers](https://create.roblox.com/docs/ui/size-modifiers) supplies constraints. The important engineering inference is one owner per dimension, not combining every available constraint indiscriminately.
- [ScreenInsets](https://create.roblox.com/docs/reference/engine/enums/ScreenInsets) distinguishes noninteractive full-bleed backgrounds from important content that avoids CoreGui and cutouts. [GuiService](https://create.roblox.com/docs/reference/engine/classes/GuiService) exposes PreferredTextSize, PreferredTransparency, ReducedMotionEnabled and focus state. Integrate these preferences after approval rather than depending only on a custom setting.
- [Nine-slice](https://create.roblox.com/docs/ui/9-slice) preserves corners while stretching edges/center. Prototype evidence shows that baked notches and variable light gradients still stretch badly. The documented pivot is to separate special rim pieces, not claim nine-slice solves all artwork.
- [Roblox UI/UX design](https://create.roblox.com/docs/production/game-design/ui-ux-design) distinguishes visual craft from communication and navigation. Text-fit success alone cannot approve composition, reachability or emotional quality.

## Reused Roblox market research

The earlier preserved public evidence includes current icons/two thumbnails each for RIVALS, Blade Ball, Epic Minigames, Super Bomb Survival, Dandy's World, Dress To Impress and DOORS. See ../creative-review-2026/research/references.json and the source image contact sheet. Visible motifs include dominant subject silhouettes, clear warm/cool separation, consistent logo/character signatures and explicit gameplay tension. Public presentation does not establish their private menu conversion, shop revenue or retention. We did not invent in-game menu details from those images.

For Trail Wars, the core-and-trail encounter must be recognizable across icon, Home, collection preview and results. A large slogan alone did not communicate survival tension in the old design. Preserve a coherent ring/route signature, one obvious Play action and a curated cosmetic presentation. These are design hypotheses to validate, not promises of popularity.

Roblox's [June 2026 discovery explanation](https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox) separates initial play-through/bounce and longer-term value signals. Proposed future tests should compare understandable metadata, start-to-first-play friction and repeated-session usability. There is no causal conversion data for any Trail Wars concept yet.

## Honest critique of the preserved experiment

The approved logo, palette and material reference are strong. The technical art extraction recovered useful pieces. However, the experiment accumulated two rendering kits, blanket scales, long portrait pages, inconsistent native text sizing and asset-mask artifacts. Home's one-screen requirement was lost during responsive revisions. A dark screen recolor or nine-sliced glossy rectangle alone cannot create professional composition. Broad implementation is stopped while this complete design is reviewed.

## Recommended design direction

Keep the approved tactile peach/plum identity. Make Play primary, cosmetic choice understandable, errors calm and match views spare. Define separate Home, inventory, dialog and HUD compositions rather than one universal scrolling layout. Deliver restrained purposeful feedback. The owner must approve this proposed system; the prior style approval does not approve its navigation or new layouts.
