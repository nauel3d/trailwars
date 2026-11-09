# Bundled Studio verification — 2026-11-09

Verified the clean Rojo preview build in one Studio checkpoint after source implementation and successful CLI/CI checks. No further Steam or REA inspection was used. The production build excludes preview fixtures and tests.

## Responsive engine checks

`scripts/studio_layout_check.luau` mounted the actual App into Frames at 1365×768, 768×1024, 390×844 and 320×568, with 100% and 150% text. Twelve routes/states produced 96 combinations: Home, Customize, Shop, Settings, Profile, Tutorial, queue, HUD, spectator, results, locked item and purchase confirmation.

The initial sweep found one TextFits failure: YOUR PROGRESS on Home at 320×568 / 150%. Shortened the label to PROGRESS in source and the verification place. Rechecked that affected combination: zero TextFits failures. The other 95 combinations had zero failures initially. CLI checks and both Rojo builds passed again after the fix.

This checks text geometry in the Roblox engine, including offscreen scroll content. Frame-sized simulation does not establish physical-device performance, notches, touch ergonomics, scroll accessibility or actual tablet/controller behavior. Desktop Home was visually reviewed at 1408×642 through the connector capture `TrailWars_Home_Final`.

## Functional checks

Actual keyboard activation traversed Home → Tutorial → Queue → Countdown → HUD → Spectator → Results → Rematch → Leave → Customize. Holding A displayed Steer LEFT. These are explicit mock match states; there is no playable round simulation or reward grant.

Opening the ring inventory card displayed its cosmetic description and insufficient-funds state. Closing details restored focus to that inventory card. Toggling reduced motion changed the UI and a fresh real RemoteFunction snapshot confirmed `settings.reducedMotion = true` in the server's Studio mock profile.

An isolated client fixture then tested the new UI's earned-purchase confirmation and equip path: 480 coins → ring purchase for 150 → 330 coins, ring owned, ring equipped. This fixture uses the development transport, not a real purchase or durable server. The prior prototype's server-backed purchase evidence and the current 40-assertion foundation suite remain separately documented. The fixture was destroyed and the normal server-connected App remounted afterward.

## Performance observation

Final desktop Studio Home, 120 RenderStepped samples: median 16.624ms, p95 18.144ms, max 29.822ms, mean 16.680ms. Viewport 1408×642. Current GUI construction CPU time 8.053ms; max navigation construction 8.867ms on that mount. These exclude network and render completion and are not phone benchmarks or a controlled comparison with the prototype.

Console inspection showed built-in Assistant plugin load failures and an asset-type mismatch for rbxassetid://203785492. No TrailWars script exception appeared. TrailWars UI uses native elements and does not reference that asset.

## Remaining release work

Physical phones/tablets/controllers, safe-area and touch verification, live private-universe DataStore races and reconnection, real Marketplace configuration and receipt retention/archival remain release gates. Production profiles and live purchases stay disabled. UI Labs stories are provided, but the optional UI Labs plugin was not installed or independently exercised. No game was published.
