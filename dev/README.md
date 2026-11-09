# Preview components without running the game

Build/sync `preview.project.json` with Rojo. Open the optional [UI Labs plugin](https://ui-labs.luau.page/docs/installation) in Studio edit mode and select a `*.story` module under ReplicatedStorage/TrailWarsDev/Stories. The plugin is not installed automatically and no utility/runtime package is required for function stories.

Stories mount the same `App.mount(target, options)` used by the production bootstrap. Each returns cleanup, has its own widgets/connections/tweens and injects an isolated mock transport. No player, Steam session, live server or Marketplace call is required. Use Home, Customize, Shop, large-text Settings, Tutorial, Queue, HUD, Spectator, Results, locked-item, confirmation and error stories to compare states. UI Labs can resize/multi-mount them in edit mode.

Mock fixtures are excluded from `default.project.json`; preview data is clearly labeled and never becomes a player's real balance. The CLI build/test loop is the default. Preview/Studio rendering is a checkpoint, not a per-edit requirement.
