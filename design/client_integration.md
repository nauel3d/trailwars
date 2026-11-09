# Provisional client wireframe

The reference audit is unfinished, so this client deliberately uses neutral grayscale wireframes. Its appearance is **not an approved original brand direction**. No reference images, interface assets, audio, animations or commercial source code are included. The prototype can exercise the planned flows while research continues.

`src/client/Main.client.luau` mounts a safe-area ScreenGui with a width-constrained shell, scrollable content, 48–66 pixel action targets, four persistent navigation destinations, back history, profile feedback and item detail/confirmation states. `Widgets.luau` owns per-render connections, selectable controls and lightweight static 2D geometric previews. Remounting a screen disconnects prior handlers. Destroying the GUI removes global input bindings too. Native Roblox UI is sufficient here; no framework dependency is added.

## Reachable routes

| Route | Implemented interactions and states |
|---|---|
| Home | Profile connection/retry, Play tutorial, Customize, profile/progress |
| Tutorial | Keyboard A/D and arrow input, controller D-pad, touch hold buttons, input feedback, start mock flow |
| Customize | Catalog, owned/equipped/locked state, 2D preview, validated server equip |
| Shop | Earned cosmetic cards, cost, details, insufficient funds, confirmation/cancel, pending, confirmed success/failure; paid products visibly unavailable |
| Settings | Saved music/sound toggles, reduced motion, text scale cycle, controls route |
| Profile | Only server-confirmed earned balance, XP, rounds and wins; no invented levels/rewards |
| Mock flow | Queue → countdown → HUD → elimination/spectator → results → rematch, with explicit advance controls and exit |

Mock flow transitions are controlled by the user and prominently marked as local demonstrations. There is no actual matchmaking, opponent data, moving core, timer, collision simulation or reward grant. Results use dashes for unavailable match values. The mock never calls a reward remote. Audio preferences persist but no sound assets exist yet. All transitions are instant, respecting reduced-motion intent without animation cost.

## Network states

The client uses `TrailWarsRequest` as documented in `integration_foundations.md`. Requests disable transactional controls; navigation/back explicitly tells the user to wait while a write is pending. Successful replies replace the public profile; failed calls keep the last confirmed display. A 15-second watchdog handles a stalled `InvokeServer`: it labels the outcome unknown, permits navigation, and requires a successful profile refresh before further mutations. Late replies are ignored using request sequence numbers. An outstanding low-level InvokeServer may remain suspended until Roblox resolves it; no fake cancellation is claimed.

No paid price is displayed because no real product exists. Runtime personalized price lookup must be added when an actual approved catalog/product mapping is configured; the current disabled paid card never prompts a purchase. No hardcoded Robux value, mock premium balance or fake checkout exists. Starter cosmetics are free and always owned; earnable cosmetics start unaffordable because mock balance truthfully begins at zero. Successful earned purchase paths require test-fixture coins or a future authoritative match reward.

## Input and layout verification needed

Keyboard Tab/Shift+Tab explicitly cycles enabled controls; Enter activates the selected action. Gamepad selection uses Roblox directional navigation and native A-button activation. Escape/B closes details or returns through history. Each render restores focus position when possible. Touch controls respond to hold/release and click/selection pulses. Window focus loss clears steering input. All input feedback is an instructional demonstration only.

The root respects `DeviceSafeInsets` and adapts width without viewport polling or per-frame tree rebuilds. Main content scrolls vertically and supports saved text scales of 100%, 125% and 150%. Actual narrow-phone, tablet, desktop and gamepad layout checks remain required in Studio and on physical target devices. Safe-area support is implemented but no physical notch-device validation is claimed. Long localized text, accessibility reader behavior and native modal/platform focus handoff remain unverified.

## Measurements

ScreenGui attributes expose `InitializationMs`, `LastNavigationMs`, `MaxNavigationMs`, `CurrentRoute` and `MetricsScope`. These measure client-side Lua GUI construction time only; they exclude render completion, GPU frames, network profile loading and time waiting for shared modules. The initialization console entry uses the same scope. No FPS, memory, device-level performance or navigation latency results are asserted until the app is run and inspected. Capture hardware, viewport, sample count and profiler conditions alongside those attributes.

## Required tests

1. Open every route, return via Back, Escape and gamepad B, and verify focus and old handler disposal after 100 route changes.
2. At desktop, tablet and 320-pixel phone widths, exercise 100%/150% text, safe insets, scrolling and every bottom-most control.
3. Hold/release both touch zones; test A/D, arrows and D-pad; release app focus and verify no stuck input.
4. Equip a starter item, reject an unowned item via direct remote, buy an earnable item using isolated server test credit, verify duplicate click does not charge twice, and test insufficient funds/cancel.
5. Save settings, refresh snapshot, reconnect with persistent mode in an isolated test universe, and check durable values.
6. Simulate unavailable remote, delayed response beyond 15 seconds, failed datastore, lost lease and rate limit. Confirm no stale success, invented balance or repeated purchase.
7. Traverse every mock stage and rematch; confirm profile coins/XP/wins remain unchanged.
8. Confirm paid controls remain unavailable and no platform checkout can be invoked.

Rojo project build succeeds after adding these client scripts. Rojo serialization is not Luau execution validation. Runtime tests are pending root's isolated Studio test session.
