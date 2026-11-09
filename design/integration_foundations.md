# System foundations — integration status

Implementation authored independently from the user brief on 9 November 2026. It contains no reference-game code or assets and makes no claims about observed reference behavior. Visual styling and real gameplay are outside this foundation layer.

## Modes and authority

`Config.EnableStudioMock = true` uses a process-local mock store **only in Studio**. Data resets on stopping play; balances start at zero, and every response identifies `isMock`. Production profiles and live purchases are separately disabled. An unpublished local build must not be described as a published multiplayer game.

`Main.server.luau` disables automatic characters. The client is responsible for its fixed view, steering tutorial, router, mock queue and match HUD. No authoritative match simulation exists here. The `TrailWarsMatchEvent` server remote reserves a future event contract; no client outcome or reward remote exists.

## Client API

Wait for `ReplicatedStorage.TrailWars.TrailWarsRequest`, then call `InvokeServer` from a protected `pcall` (a network failure is distinct from a rejected response).

| Request | Fields | Durable behavior |
|---|---|---|
| Snapshot | `action = "Snapshot"` | Returns cached, lease-valid public profile |
| Equip | `itemId` | Validates catalog, slot and ownership |
| BuyEarned | `itemId` | Checks server cost, subtracts earned coins and adds ownership together |
| SetSetting | `setting`, `value` | Validates range/type and persists |

Response is `{ok, code, profile?, isMock}`. Profile contains `version`, `revision`, `coins`, `xp`, `owned`, `equipped`, `settings`, and `stats`. Internal receipt IDs, lease details and reward ledger never replicate. Setting names are `music`, `sound`, `reducedMotion`, `textScale`; ranges are 0–1, 0–1, boolean, 1–1.5. Persist volume sliders after interaction ends, and debounce setting updates. Do not issue writes every animation frame. Calls are rate limited per player at 0.35 seconds.

Show loading for `LOADING`, retry for `RATE_LIMITED`/`BUSY`/`DATA_UNAVAILABLE`, explicit unavailable status for `PROFILE_UNAVAILABLE`/`SESSION_LOST`, and integration status for `PRODUCTION_NOT_CONFIGURED`. Never replace a failed production load with a writable default profile. On action failures, the client must keep its previous confirmed state and show the returned reason. A delayed network result is not proof of purchase success.

## Persistence and migration

Profiles use one DataStore key per user and `UpdateAsync`. The original implementation acquires a 120-second lease with a random owner token, renews every 30 seconds, and serializes writes per user. Every accepted setting/equip/economy operation commits before success returns; no unsaved dirty balance exists. This conservative design favors correctness for a small prototype over write throughput. On contention, expiration, failure or unknown schema, it refuses the mutation. It never steals a live lease. Reconnecting may require the old lease to expire if release failed.

Callbacks can run more than once; mutation callbacks only edit their supplied copy and perform no network/UI/analytics effects. A committed write followed by a lost response is reconciled by a later authoritative write/read. Failed commits do not update the local cache. Shutdown attempts releases concurrently for up to 25 seconds; lease expiry is the fallback. These properties still require multi-server tests against an isolated published test universe before release.

Version 1 is explicit. `ProfileSchema.migrate` validates current records and refuses unsupported versions or malformed data. Future migrations must add sequential, pure transforms from a known older version, test preservation of entitlement/receipt ledgers, and use a backup/recovery plan. Catalog IDs must remain stable; retain retired items for persisted equipped values. No claim of an implemented v0 migration is made because no prior schema exists.

## Purchases and receipts

`PurchaseService` is the only owner of `MarketplaceService.ProcessReceipt`. It refuses receipts in mock mode, with integration disabled, for absent players, for unknown products, or after failed durable commits. A product must have a configured positive ID in `Catalog` before it can be mapped; no placeholder ID can prompt a real transaction. There is no client-grant event or `PromptProductPurchaseFinished` grant path.

For configured receipts, the durable entitlement and `PurchaseId` tombstone are written in the same profile transaction before `PurchaseGranted`. Cross-server writes require lease ownership; retried receipts return the same grant without repeating it. Tombstones are never silently pruned. The initial ledger cap is 10,000 and safely rejects further grants; replace this prototype retention design with a reviewed scalable ledger before offering repeatable high-volume products. Reward IDs likewise cap at 2,000 and block further rewards rather than risk duplicate grants. Unknown product IDs return `NotProcessedYet`; keep a mapping for retired products so outstanding legitimate receipts can still be processed.

The code currently supports **direct permanent cosmetic entitlement grants** only. This is a plumbing test surface, not a recommendation to sell repeatable copies of a permanent cosmetic. Use passes for justified permanent privileges, and verify `UserOwnsGamePassAsync` on the server before applying pass entitlements. Passes are not implemented because no pass is configured or justified yet. Repeatable developer products need an explicit repeatable grant specification before enabling; do not sell coins or paid random rewards by default. Subscriptions and seasons are deferred.

Retrieve product/pass information with `MarketplaceService:GetProductInfoAsync` on the **client** so the display reflects the user's personalized/regional price. Treat lookup errors and off-sale status as unavailable and do not fall back to hardcoded Robux amounts. The platform prompt is the final checkout. A canceled prompt changes no entitlement. A successful prompt is still pending until authoritative profile confirmation. No real purchases were performed.

Refund/revocation reconciliation is not implemented: purchase receipts are fulfillment evidence, not a generalized refund feed. Do not promise automatic refund removal. Establish a documented support/reconciliation process and entitlement policy before production. No gifting/trading exists; this avoids cross-region transfer complexity.

## Required integration gate

1. Complete the reference audit and approve original MVP cosmetic catalog and balancing hypotheses.
2. Keep local mock labels visible and distinguish demo events from genuine server match events.
3. Create a separate private test universe; enable Studio API access there only if testing real persistence. No publishing is performed by this work.
4. Set `EnableProductionProfiles` only after load, retry, lease-expiry, cross-server, corruption, shutdown, and throttling tests.
5. Configure actual product IDs, permanent/consumable semantics, client runtime price lookup, pending confirmation and support policy.
6. Test receipt replay, concurrent delivery, response loss after commit, absent player, unknown product, datastore outage and ledger capacity. Set `EnableLivePurchases` only after the full purchase review and explicit authorization to sell.
7. Implement a server-only authoritative match adapter before calling `Economy.roundReward`; never infer wins from clients or mock outcomes.

## Validation performed

Rojo 7.7.0 successfully built the project into `work/foundation-check.rbxlx`. This verifies tree/project serialization, **not Luau execution or type checking**. No standalone Luau analyzer, Lune, Selene or StyLua was found in PATH. `tests/FoundationTests.luau` provides 29 meaningful Studio assertions using injected in-memory storage and a deterministic clock; it has not been executed in this foundation subtask. To run, import it as a ModuleScript in an isolated local test place containing the shared/server module hierarchy, then call its returned function from the server Command Bar. It makes no real DataStore or purchase calls.

## Official API sources checked

- [Player data and purchasing systems](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing): atomic profile purchase writes, session locking, and callback retry considerations.
- [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService): `ProcessReceipt`, `GetProductInfoAsync`, and entitlement APIs.
- [Developer products](https://create.roblox.com/docs/production/monetization/developer-products): product integration and client price presentation.
- [Regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing): personalized price lookup; runtime display must avoid fixed Robux amounts.

The APIs were checked against official documentation accessible during this run. No external implementation source was copied.
