# TRAIL WARS — cartoon UI design approval package

Open **[review-gallery.html](review-gallery.html)**. It includes existing actual Studio captures, dated reference images/sources, three materially different concept systems, a recommended direction, editable high-fidelity proposals and an interactive motion study.

**Recommendation: A / Candy Comet Arcade. Unapproved; not implemented.** B / Stickerbook Showdown is the handmade alternate; C / Miniature Toy Arena is the more dimensional but costlier alternative. Review all three in `exports/concept-comparison.png`, then A's Home/HUD/Results and the matching mobile screens. `exports/recommended-preview.png` is a convenient contact sheet; `a-home-desktop-1920.png` and `a-results-desktop-1920.png` are larger exports.

## Package

- `reference-research.md`: eight Roblox experiences, visual observations vs judgments, linked footage and explicit evidence gaps. Thirteen inspected images, dated sources and developer material where found. `references/sources.json` records original URLs, attribution, dimensions and checksums.
- `current-ui-audit.md`: image-backed criticism and concrete improvements; exact preserved commits and unresolved implementation risks.
- `concept-comparison.md`: three directions, distinct materials/compositions, weighted rubric and trade-offs.
- `design-principles.md`, `style-guide.md`: proposed identity, palette, native fonts, shapes, spacing and asset grammar.
- `concepts/`: three moodboards, Home/HUD/Results alternatives, plus portrait HUD comparisons.
- `screen-designs/`: A's Home, Queue/Countdown, HUD, Inter-round, Results, Customize, Shop, Profile and Settings, desktop/portrait; separate compact landscape Home/HUD, 320×568 Home/HUD, turret portrait and tablet HUD.
- `component-designs/`: original independent racer, Homing, turret, navigation icons, sliced action/panel skins, component and important-state boards. Text remains independent in the intended native implementation.
- `motion-storyboards/`: storyboard SVG/PNG export, full event/easing/cancellation/audio table and local interactive score/press/reduced-motion study. Optional audio is existing original WAV playback, not a Roblox upload.
- `exports/`: 43 board PNGs, comparison/contact sheets and two 1920×1080 representatives. SVG source remains editable; PNGs are labeled design proposals, not actual game captures.
- `implementation-feasibility.md`: official Roblox sources, layout rules, safe areas, controls, type/accessibility, asset boundaries and future acceptance gates.
- `qa/`: local gallery browser captures and validation. Temporary raster inputs are ignored; original editable text is not replaced by the raster export layers.

## Preservation and scope

Starting HEAD was `b1767db` on `feature/candy-comet-finalization`. Its pending two-file edits and QA evidence were preserved as **`7419afd`** on that branch before this assignment. Current design work is isolated on **`design/cartoon-ui-research`**. `bbd39c7` remains the known-working fallback; `43532ca` approved slice and all 46 prior proposals/tests/navigation are preserved. This phase changes only this design folder and its ignore rule, with no replacement UI, renderer, server, economy or persistence edits.

Important carry-forward risk: the latest actual two-client run failed client Final/winner assertions even though the server reached Final. The latest pending implementation is **not release-certified**. Managed-client render stalls remain unresolved; the cause is not established. Earlier normal visible-client Studio measurements are preserved, with no physical-device FPS claim. These issues require a later authorized implementation/regression pass, not a hidden gameplay rewrite during this assignment.

The current Roblox audio fallback remains silent because the permission check failed; no new upload/permission probe occurs here. Existing local WAVs can be auditioned manually in the gallery. All displayed match/profile/currency values in proposed screens are sample data. Only the four existing catalog items/prices are represented. No live purchase, ranking league or reward grant is implied.

## Reproduce local designs

From repository root, with Python 3 + Pillow/requests, Node + sharp 0.35.5 and Playwright 1.62.1 (the existing bundled runtime):

```powershell
python design/cartoon-ui-research/source/build_designs.py
python design/cartoon-ui-research/source/export.py
node design/cartoon-ui-research/source/render.mjs
python design/cartoon-ui-research/source/build_gallery.py
node design/cartoon-ui-research/source/check_gallery.mjs
```

Set `TRAILWARS_NODE_MODULES` to your Node dependency directory if not using this workstation's existing runtime. Gallery browser check uses local Chrome at its standard Windows path. No network is needed to rebuild original designs. `collect_references.py` optionally repeats the public image acquisition; do not use it to overwrite historical records casually. References remain their creators' work and are for research, never shipped game assets. Fonts retain OFL notices in `source/fonts/`.

## Validation and limits

Local gallery checks inspect links, JavaScript errors, phone-width overflow, screen-family filtering, sample score/rank completion, repeated interruption and reduced motion. Editable SVG XML, PNG dimensions, text fit, real-board ratio and unchanged game paths are checked separately. These are **design checks**, not Roblox engine, actual-client frame-rate, sound, physical-phone or gameplay certification. Existing source checks passed at the preservation checkpoint; no claims are transferred to an unimplemented design.

The research does not pretend full coverage: moving playback/audio and physical mobile behavior were not inspected for all references, and some images are historical. Gaps are called out in `reference-research.md`, rather than filled with invented observations. The recommendations are art-direction judgments informed by visible evidence and source feasibility.

## Approval boundary

**Research → compare → design → present → stop.** Explicitly choose or revise a visual direction before any Roblox implementation. No publishing or merging. A successful local gallery check, draft PR or positive design discussion is not implementation approval.
