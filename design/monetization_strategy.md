# Cosmetic economy and commerce requirements

**PROVISIONAL**. Reference investigation remains incomplete. No final paid bundle, live product ID, Robux price, subscription, seasonal plan or purchase activation is selected. Current build must keep unconfigured commerce disabled. This document separates reference observations, original proposals and platform requirements.

## Evidence that informs the proposal

Installed Windows Steam UI evidence: `S01_shop_gems` displays six gem packages with money prices and bonus/discount presentation; `S02_shop_deals` displays a timed starter offer; `S03_shop_vip` advertises XP acceleration, extra challenges, cosmetics and nonrecurring durations; `S04_shop_battlepass` offers pass and tier-skip packages; `S06_shop_treasures` lists themed/previous-pass treasures; `S07_treasure_valentine` offers a 50-gem treasure; `S08_treasure_rare_info` exposes odds information; `S11_shop_powers` sells functional powers; `S21_skin_locked` provides an unlock-path explanation and preview; `S28_battlepass_loaded` shows locked free/paid rewards and boosts; `S32_challenges` shows daily/weekly tasks and a VIP route. These are observed displays, not verified fulfillment.

The file named `S05_pass_insufficient` shows a **Confirm** button; its filename alone does not prove an insufficient-balance error. The result must remain unverified unless subsequent evidence demonstrates it. Static Steam payment branches and their limits are documented in `research/07_runtime_findings.md`.

Original recommendation: keep direct appearance ownership and useful previews; simplify unlock paths; cut paid powers, paid randomized rewards, tier skips, XP boosts and urgency messages from launch. A paid core must collide exactly like a free core. Do not sell stealth, narrower trails, smaller collision geometry, control responsiveness, visibility reduction, stronger steering or a revive. Outcome fairness and collision readability are constraints on every cosmetic.

## Original offer structure

Launch economy proposal: one earned currency only if playtesting demonstrates that it improves cosmetic choice. Default core/trail are free. A small earnable set gives a reachable first unlock and longer voluntary goals. No currency expires. Do not expose a paid currency conversion ladder. If commerce is eventually approved, sell a clearly described permanent appearance or small permanent collection directly, leaving comparable-quality earnable choices. Core/trail, elimination/result effects and profile accents are possibilities, not an approved launch inventory.

| Mechanism | Proposed disposition | Rationale |
| --- | --- | --- |
| Permanent appearance entitlement | Candidate pass, after audit/validation | One-time ownership matches a permanent benefit. No gameplay advantage. |
| Repeatable developer product | Infrastructure only; offer deferred | Repeatable purchases need an honest repeatable benefit. Do not use a consumable API to accidentally sell permanent ownership repeatedly. |
| Earned cosmetic unlock | Candidate MVP | Server-owned balance and exact item choice, with no paid-only obstacle. |
| Subscription / VIP duration | LATER, disabled | Adds renewal, cancellation, status and entitlement complexity without validated launch need. |
| Seasonal pass / tier skip | CUT from launch | Adds progression pressure and UI branches before core play is validated. |
| Random paid treasure | CUT | Direct ownership is easier to understand and avoids randomized paid reward complexity. |
| Paid cosmetic gifting/trading | LATER, absent | Additional transfer, abuse and managed-price arbitrage concerns are unnecessary for MVP. |

Passes are one-time purchases; developer products support repeatable purchases. Use the platform mechanism that matches the intended benefit. [Roblox passes](https://create.roblox.com/docs/production/monetization/passes), [developer products](https://create.roblox.com/docs/production/monetization/developer-products).

## Price and prompt contract

Do not hardcode displayed Robux amounts or infer a user's price from another account. Fetch current product information on the purchasing player's client through `GetProductInfoAsync` with the correct information type, validate metadata availability/offsale status, and show the returned price only while it is current enough for the flow. The native Roblox purchase prompt remains the final price confirmation. Price fetch failure disables purchasing with Retry; no default number replaces it. [Roblox regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing).

IDs remain zero/absent behind explicit configuration gates until real products are created in the correct experience. Creation and publication remain outside the current authorization. Enablement checklist: confirm owning experience; create reviewed offer; record actual ID/type/benefit mapping; verify runtime metadata under at least two eligible test accounts; verify cancellation and delayed grant; run receipt/persistence fault tests; then deliberately enable the feature. No client may override enablement or choose a grant mapping.

## Developer-product grant requirements

One server `MarketplaceService.ProcessReceipt` handler routes allowlisted product IDs. Receipt callbacks, rather than client prompt-finished events, decide developer-product fulfillment. Durable grant/replay protection precedes acknowledgment; return pending when processing cannot safely finish. [MarketplaceService API](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService).

Implementation acceptance requirements:

1. Verify receipt player/product identifiers and allowlisted configured mapping; a nonexistent or unknown product remains ungranted and produces a bounded diagnostic. Never silently acknowledge an unmapped paid purchase.
2. Store PurchaseId evidence and the benefit atomically in the same authoritative record, or use a proven recoverable transaction protocol. A record that only says “processing” must have a recovery path. Two unrelated writes cannot be assumed atomic.
3. Treat receipt callbacks as repeatable and unordered. Same receipt twice must grant once; different receipts for a repeatable product must each grant once. Keep enough durable dedupe information to reconcile old retries; define growth/retention before sale.
4. Serialize profile mutation and coordinate session ownership. Update transforms must be retry-safe, non-yielding and pure with respect to external side effects. Notifications occur after durable success, never inside a retryable transform. [Data stores](https://create.roblox.com/docs/cloud-services/data-stores).
5. On unavailable/locked profile, throttling, datastore error or uncertain write outcome, leave the receipt pending. Reprocessing reconciles durable state before deciding whether anything remains to grant. Never create a temporary default profile and save it over inaccessible data.
6. Cross-server replay test: two callbacks with identical PurchaseId race; exactly one durable benefit appears. Crash test: stop after commit but before acknowledgment; retry acknowledges without granting again. Save-overwrite test: old autosave cannot erase a committed receipt or inventory item.
7. Prompt cancellation closes local UI without granting or deducting. Prompt completion may request a status refresh but cannot itself grant. Delayed callback survives closing menus/rejoining. User copy distinguishes “checking” from “granted.”
8. Refund/revocation handling requires a documented support/reconciliation procedure appropriate to the product. Do not assume every platform event provides an automatic revocation callback. Never delete earned inventory or create negative currency based solely on a client report.
9. Entitlements for passes are checked server-side with ownership APIs on join and after a relevant prompt; the pass itself remains the platform entitlement. Store only the necessary derived state and reconcile failures explicitly. Do not route pass ownership through a developer-product receipt mapping.

## Fairness and presentation acceptance

Compare free and premium cosmetics in the same arena with identical speed/geometry. Their trail centerline and width must match; visibility must remain within a readable envelope under low effects. No item can suppress opponent recognition or create persistent screen clutter. Store details say what changes and show it at gameplay scale. Owned state prevents accidental duplicate permanent purchase. Close and Cancel are as accessible as Buy; no purchase popup interrupts elimination or results.

Commercial success hypotheses: buyers understand permanent ownership, previews reduce uncertainty, and voluntary purchases support development without changing win probability. These require playtests and telemetry designed without collecting unrelated personal information. They are not measured conclusions from this session.
