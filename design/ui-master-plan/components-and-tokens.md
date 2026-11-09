# Modular components and visual tokens

Design proposal. Approved identity: peach/apricot environment, cream sculpted rims, plum controls, orange primary action, turquoise selection/cosmetic signature. The extracted logo stays a controlled art asset. Native text remains editable. No Nintendo graphic, character, trademark or sound asset is used.

## Color system

| Token | Value | Use |
|---|---|---|
| Peach background | #FFD0A7 | Warm canvas; gentle #FFDCBB light variation |
| Cream face | #FFF1DA | Text on plum/orange, raised frame top |
| Apricot rim shadow | #DF9564 | Material depth, never body text |
| Plum ink | #3D1B39 | Main text on cream/peach |
| Plum panel | #42203F | Content wells and inactive controls |
| Plum light | #71375F | Bevel highlight; not a whole background replacement |
| Orange action | #FF7700 | Dominant Play/confirm button material |
| Turquoise selected | #00DABA | Selected border and equip acknowledgment |
| Warning coral | #B64435 | Error symbol + explicit text on cream |
| Neutral disabled | #947B86 | Desaturated material + “Unavailable” label |

Screen design values are sampled/derived from the approved reference, not exact flat colors throughout textured gradients. Use plum text on cream controls, cream text on plum. Orange buttons need cream lettering with a dark fine edge/shadow; never assume every orange/cream pair meets body-text contrast. Verify actual exported pixels and use a plum text variant for long orange-button copy if required. Color always has a label/shape partner.

## Type, spacing and depth

- Display and action type: Fredoka One, already supported by Roblox's font family. Preserve the locked logo instead of recreating its lettering in native type. Body: Arimo/neutral supported sans; choose the native family after the font proof. Do not fake weight with multiple blurry text copies.
- Body 18px; secondary 16px; section 24–28px; card name 20–24px; primary action 24–32px; short decorative headline 40–72px. Desktop reference reconstruction may use larger art-specific measurements. Text preference adjusts content height and composition.
- Space steps: 4, 8, 12, 16, 24, 32, 48. Screen gutter 16 compact / 24 regular / 40 spacious. Touch gap ≥8. Dialog internal pad 24, reduced to 16 on small phones.
- Visible corner families: pills at half-height; item cards 24–32px; large content wells 48–72px. Texture/slice corners are authoritative visual geometry; native UICorner is for plain masks/fallbacks.
- Depth: control top glint 1–2px, lower bevel 4–8px, local warm shadow offset 4px/blur 8px. Main rim 20–30px at reference size. Never stack several full-screen translucent groups for one shadow.

## Component boundaries

| Component group | Inputs | Outputs / responsibilities | State variants |
|---|---|---|---|
| AppShell + SafeArea + TopBar | safe rect, route, input, profile view | One composition owner, logo, balance, focus boundaries, route mount lifecycle | loading, normal, offline, compact, enlarged text |
| ResponsiveNav | selected root, destinations, modality | Root selection + semantic focus graph; active indicator names actual route | normal, selected, focus, disabled |
| Button family | label, action, variant, busy, disabledReason | Activation intent only, no remotes; shared geometry and feedback | default, hover, focus, pressed, selected, disabled, loading |
| Surface family: Card/Pill/Tabs | content, selection, style key | Shared art, content insets, correct nine-slice metadata | normal, selected, warning, disabled |
| CurrencyDisplay + ProfileSummary | confirmed numbers, stale flag, name | Exact grouped number, explicit stale/unavailable marker | confirmed, loading, stale, empty |
| ItemTile + ScrollGrid | Catalog item, owned/equipped, selection | Item-selected intent, grid/focus key; no price arithmetic authority | owned, locked, equipped, available, purchasing, unavailable |
| TrailPreview | selected/equipped IDs, preview fixture | Separate core/trail art; same collision-size presentation | core/trail sample, missing image, reduced motion |
| ItemDetails + Dialog | parent context, eligibility, transaction state | Stable details view, close, equip/unlock intents; focus trap and restoration | locked, owned, equipped, insufficient, pending, unknown |
| Feedback: Toast/Tooltip/Loading | semantic message, severity, action | Visible message + optional cue, bounded lifetime, pause for focus | info, success, warning, persistent error |
| SettingsRow + Progress | value/draft/save state; optional measured progress | Per-field changes and confirmed display; no fabricated thresholds | editing, saving, saved, partial failure, unavailable |
| MatchHUD + ResultsPanel | future authoritative view model / explicit fixture | Display only; two steering intents; outcome/reward acknowledgment | countdown, active, out, spectating, victory, defeat, settling |

This is approximately 12 meaningful component groups, not dozens of single-use wrappers. Separate visual rendering from layout and controllers. Components can be authored without a player or RemoteFunction through injected, typed view models.

## State semantics

Focus has a cream outer stroke plus plum separation edge, not only turquoise. Press displaces the face toward its shadow; visible and hit bounds stay aligned. Loading preserves the label context (“Unlocking…”) and blocks duplicate activation. Disabled explains the reason on touch/focus; it never looks like an enabled orange CTA. Selected is a persistent turquoise rim + check/label, distinct from transient focus.

Item precedence: unavailable → purchasing/unknown → equipped → owned → affordable locked → insufficient locked. An item preview can change locally; ownership and equipped badges use only confirmed profile state. Button or tile descendants marked decorative never enter the focus order.

## Architecture proposal after approval

Keep the backend modules and public action contracts. Replace the current overlapping W/Peach rendering paths with one component kit and ScreenShell. Suggested client boundaries: Theme/Tokens, Assets, Components, LayoutModes, Router, InputFocus, MotionFeedback, ProfileController, TransactionController, SettingsController, Screens and development Fixtures/Stories.

App-level controllers survive route switches. Render functions receive immutable display snapshots + callbacks. The remote gateway owns request IDs and reconciliation, not an ItemTile. Each mount returns cleanup; its own event/tween scope ends on unmount. Ignore late view callbacks after disposal but retain the app-owned transaction outcome. No frame-loop tree rebuilding, global monkey-patches or preview writes to global selection.
