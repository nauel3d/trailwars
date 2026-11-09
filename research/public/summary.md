# Preserved reference findings

Observed installed Windows Steam build 26292297, game UI version 4.3.0, on 2026-11-09. The investigation is partial; it is not an exhaustive reference audit.

Screens and states inspected include home, all six shop categories, a purchase-confirm label, treasure contents and a rarity-odds panel, settings categories, cosmetic inventory, account progression/challenges, leaderboard, room discovery/configuration, social panels, six profile tabs, and an isolated bot match through results and rematch. Bot-match details displayed seven rounds and a duration of 5m 28s. This observation does not establish online competitive behavior. No real purchase or account reset was performed.

Reference complexity includes steering plus powers, multiple progression/currency surfaces, paid functional unlocks, VIP, timed offers and random-reward treasures. Trail Wars intentionally selects a simpler two-direction arcade interaction, minimal navigation, direct cosmetic previews and fair cosmetic-first commerce. These are original product decisions rather than a copied interface.

Read-only REA analysis established an Electron wrapper serving the packaged client over loopback HTTP, a Steam integration bridge, controller declarations, and declared purchase-finalization states. Static declarations do not prove runtime execution or server fulfillment. No process patching, credential collection, protection bypass or protected-session instrumentation was performed.

Unknowns remain: most item-detail variants, real payment/cancellation/fulfillment, account-switch/authentication failures, full reconnect behavior, physical touch/controller tests, online queue variants and replay playback. The bot-match replay control was disabled. Existing screenshots and detailed traversal queues are preserved locally; further inspection is exceptional under issue #1.

Primary secondary sources: [official Steam listing](https://store.steampowered.com/app/1133700/Curve_Fever_Pro/) and [Curve Fever Wiki](https://wiki.curvefever.pro/). Source-documented features are distinguished from direct local observations in the retained reports.
