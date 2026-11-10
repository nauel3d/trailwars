# TRAIL WARS — premium Home / Shop visual review

**Status: unapproved. Two visual prototypes only.** Previous A/B/C directions remain unapproved and preserved. This new work is isolated on `design/premium-video-prototypes`. No Roblox Studio UI implementation, renderer, gameplay, economy, persistence or sound changes occurred.

Open [review.html](review.html), or inspect [Home](home-desktop.png) and [Shop](shop-desktop.png). Both are original generated raster mockups, 1672×941, with accurate requested labels and clearly marked sample data. They are not actual Roblox captures, functioning storefronts or a screenshot background intended for implementation.

## What changed in the visual target

The supplied 30.8-second video demonstrates a substantially richer finish than our rejected concepts: outlined display text, oversized illustrated symbols, graphic product art, readable light/dark edging, glossy dimensional control faces, differentiated themed cards and modals separated by blur. The target is construction and artwork quality, not a palette substitution.

The new original Trail Wars system uses cobalt/indigo with electric turquoise, orange primary controls and warm-white outlined lettering. Racing pods, hollow core rings, directional trails and finned rockets carry the identity. No pets, eggs, chance mechanics, reference branding, product art or exact screen composition is reused. A drawn miniature Home arena is promotional illustration, not a proposed change to the real game's top-down world/collision geometry or a new 3D lobby.

**Home:** strong wordmark; original paint/visor, pit-stop bag, pilot badge and slider illustrations; oversized orange PLAY; lit hover-racer hero; miniature illustrated trail demonstration. Existing four menu destinations remain. There is no invented reward, pass or live player count.

**Shop:** asymmetric four-item showcase instead of a wall of equal cards. Ring Core gets the main illustration; Dashed Trail gets a wide curved-trail display; starters form a quieter lower pair. Product-specific cool-cyan, purple, amber and teal lighting. Orange price actions, green ownership states, selected orange tab and substantial red close control remain semantically distinct. Existing catalog only: Ring core 150 coins, Dashed trail 100 coins, Starter core owned, Starter trail owned. 480 is an explicit sample balance. No purchases are enabled.

## Critical comparison with the supplied video

| Benchmark detail | Evidence in our two prototypes | What is still unproved |
|---|---|---|
| Outlined rounded typography and readable shadow | Large cream lettering with deep indigo outlines and offset extrusion; clear title/action/description sizes | Native Roblox font/outline reproduction and localization still need a later approved slice |
| Dimensional buttons | Lit upper edge, warm bevel, dark lower extrusion; PLAY visually dominates Home | PNGs do not demonstrate engine hover/press. The gallery's separate local material study tests a short press/release only |
| Original illustrated icons | Custom rendered visor/paint tool, racing bag, pilot badge, sliders and category core/trail art | Independent layered source icons/skins and native focus variants must be authored after approval |
| Product variety and finish | Hollow torus core, segmented cyan trail, orange starter racer, smooth orange trail; distinct lighting and artwork scale | Final card animation and touch reflow are outside this two-screen gate |
| Modal separation | Shop's lit frame, dark/blurred outer backdrop, substantial close action and differentiated header | Blur intensity/lifetime, keyboard focus trapping and transitions have not been tested in Roblox |
| Coherent personality | Original fins, hover rings, racing chevrons and curved trails recur across both screens | The dramatic Home illustration must remain outside competitive live gameplay; no arena embellishment approval is implied |

These prototypes are a visible step toward the supplied benchmark, not a claim that a production system now meets it. The reference is richer than the rejected minimalist package; the new artwork and materials address that gap. Remaining concerns: Home's four secondary controls still share one construction, bright cyan trim could become repetitive if extended indiscriminately, and tiny gameplay racers cannot carry this much illustration detail. Active HUD design should be much quieter. Your visual judgment is the gate.

## Motion intention, not an engine claim

Proposed press 60–70ms, 3–5px face depression with shadow compression; release 110–150ms, restrained overshoot. Hover brightens the face rather than scaling the entire menu. Selected category remains distinct from focus. Modal settles within roughly 180–220ms; input/close is immediately available. Reduced motion removes travel/overshoot. These are original intended timings, not a measured copy of the reference. `review.html` includes a local interactive material test; it neither launches Roblox nor changes gameplay.

## Preservation / limitations

`bbd39c7` remains the known-working gameplay fallback. Pending Candy changes and unresolved evidence remain at `7419afd` on `feature/candy-comet-finalization`; rejected design work remains at `37c195a` on `design/cartoon-ui-research`. The latest client-Final/winner regression is unresolved. Managed-client performance investigation remains unresolved, with no asserted engine/scheduler cause or physical-device FPS. These visual proposals do not certify or repair it.

Only Home and Shop are developed here. No replacement HUD, powers, countdown, results, customization or mobile package is implemented or claimed approved. After explicit direction approval, those families can use the selected materials with practical native layouts and a proportionally correct, uncluttered arena. No full-screen raster is intended as the interactive Roblox UI: separate artwork, native text/buttons, reusable skins and bounded motion would be required.

## Provenance

Reviewed the supplied local video across its complete timeline using 123 chronological quarter-second frame samples, the actual final decoded frame, native-size UI details and a denser modal-transition sequence. The review method and time ranges are in [video-study.md](video-study.md). No real-time audio playback or audio-design claim is made. Source video and extracted reference frames remain private/local; they are not uploaded to GitHub.

The two final images were made with the built-in `image_gen` tool. One targeted Shop revision separated item backdrops/lighting while preserving labels/prices/layout. Exact prompts, constraints and that revision are saved in [prompts.json](prompts.json). Original generated files remain under the tool's generated-images directory; final copies live in this folder. [assets.json](assets.json) records dimensions and SHA-256. The editable prompts/specification do not imply that raster illustrations have editable vector layers.

**Stop for visual approval. Do not implement, merge or publish this direction.**
