# Remaining risks and integration work

- Gameplay is mocked: matchmaking, collision simulation, rounds, authoritative match rewards and multiplayer recovery still require gameplay systems.
- Responsive Frames and TextFits are useful engine checks, but physical touch, controller navigation, safe areas and real phone performance remain unverified.
- Production profiles and live purchases are disabled. Real product IDs, runtime pricing, private-universe failure/race tests and receipt archival must precede activation. Bounded transaction ledgers deliberately fail closed when full.
- The local raw reference audit is preserved but incomplete. Public research is a redacted summary and evidence manifest; neither imported reference assets nor extracted code ship with the UI.
- Optional UI Labs function stories use the same App but await a plugin-level preview check. Headless tests run real foundation Luau with minimal adapters, not Roblox engine emulation or full API typechecking.

Continue source-first: edit, run changed-scope checks, build and commit. Schedule engine checks around concrete new integration risks; do not repeat reference inspection without a blocking question.
