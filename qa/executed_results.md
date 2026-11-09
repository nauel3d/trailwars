# Executed checks

## Source-first checkpoint — 2026-11-09

Executed `./scripts/bootstrap.ps1`, followed by `./scripts/check.ps1` from the project root. Official Windows release archives are SHA256-pinned; tools remain project-local.

| Check | Result |
|---|---|
| StyLua2.6.0 `--check src dev tests` | PASS |
| Selene0.32.0 `src dev tests` | PASS:0 errors,0 warnings,0 parse errors |
| Luau0.746 `luau-compile --null` | PASS:29 source/story/test files |
| Official Luau CLI + existing FoundationTests through minimal service/module mocks | PASS:40 assertions |
| Rojo7.7.0 production build | PASS |
| Rojo7.7.0 preview build | PASS |
| Built XML boundary validation | PASS: no dev stories, test modules or temporary Studio fixtures in production |

The foundation suite preserves the prior29 assertions and adds recovery/busy/delayed-write checks. It covers ownership, insufficient balance, duplicate earned purchases, invalid settings, receipt replay/conflict, reward replay, failed durable writes, leases and stale-server rejection. The adapter executes actual repository Luau; it does not emulate the Roblox engine. Full Roblox API typechecking and live DataStore/Marketplace behavior are not established by these checks.

## Preserved earlier engine evidence

Before the workflow change, isolated Studio tests passed29 assertions. An actual server-backed Studio mock purchase spent150 of200 fixture coins, granted the ring core and equipped it. The original fixed-height large-text defect was found and corrected. Earlier timeout/fault observations motivated subsequent source recovery barriers. Raw runtime evidence is retained locally and excluded from the public repository.

These earlier checks apply to the preserved prototype, not automatically to the newly styled App. The bundled final engine checkpoint is recorded in [studio_verification.md](studio_verification.md). No physical device or real-money test is claimed.
