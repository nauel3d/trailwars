# Original store flow and state map

**PROVISIONAL**. Commerce stays disabled with placeholder IDs until a reviewed offer is configured and integration tests pass. No final theme/bundle has been selected. The following is a state contract and is not proof that a live checkout works.

```text
HOME -> SHOP -> ITEM DETAIL
                  |
                  +-- owned -> CUSTOMIZE -> request Equip -> accepted / rejected
                  |
                  +-- earnable -> SERVER QUOTE -> CONFIRM / CANCEL
                  |                              |
                  |                              +-> atomic check + spend + own
                  |                                  success / insufficient / retry
                  |
                  +-- paid & enabled -> client product metadata
                  |                    loading / unavailable / offsale / ready
                  |                                      |
                  |                             ROBLOX NATIVE PROMPT
                  |                              cancel / prompt closes
                  |                                      |
                  |                              CHECK ENTITLEMENT
                  |                              pending / granted / retry
                  |
                  +-- unconfigured -> explanation (no purchase prompt)
```

| State | User-visible copy / action | Authoritative input | Allowed exit and durable effect |
| --- | --- | --- | --- |
| Catalog loading | “Loading appearances…”; Back | catalog version | Back; no mutation. |
| Empty / unavailable | “No items are available right now.” Retry / Back | service response | No simulated offers. |
| Owned | “Owned”; View in Customize | server inventory or validated entitlement | No duplicate permanent Buy. |
| Earned quote | exact name, cost and balance; Cancel / Unlock | server catalog + profile | Cancel unchanged; Confirm sends quote/item identity. |
| Insufficient | “You need more earned currency”; Back | atomic server rejection | No automatic paid top-up. |
| Earned pending | “Unlocking…”; Close | server request ID | Duplicate request deduped; close does not cancel committed mutation. |
| Metadata pending | “Checking current price…” | purchasing client's platform response | Back; paid action disabled. |
| Metadata failed / offsale | “Purchase unavailable”; Retry / Back | platform metadata error/status | No fallback price. |
| Commerce disabled | “Purchases aren't configured in this build.” | server/client configuration gate | Preview or Back. |
| Native prompt | Roblox-owned interface | MarketplaceService | User authorizes/cancels; game does not recreate final payment dialog. |
| Prompt closed | “Checking purchase status…” if appropriate | status refresh only | Never grant from client event. |
| Receipt pending | “Your item is still being checked. You can keep playing.” | durable reconciliation status | Close, status retry; receipt remains recoverable. |
| Granted | “Added to your collection”; Equip / Continue | server-confirmed ownership | Equip validates again; no automatic repeat purchase. |
| Failure | specific recoverable availability copy | authoritative error classification | Retry status or Back; do not ask user to buy again for an uncertain receipt. |

Request-race rules: selection A's response cannot replace selection B's details; rapid repeated Confirm submits one transaction; closing/reopening detail retrieves current ownership; two servers receiving the same receipt produce one benefit; late receipt completion updates collection even when Shop is closed. If a platform prompt is still open, block a second prompt and explain the state.

Preview never writes ownership, consumes currency or equips. Confirmation lists exact permanent benefit; if a future repeatable offer is introduced, its repeatable nature must be explicit before opening the platform prompt. No random rewards, fake discounts, urgency countdowns or loss-framed cancel labels.

Test sequence: unavailable configuration; valid metadata; metadata failure; offsale item; cancel before server request; insufficient earned currency; success; forged item ID; duplicate transaction; datastore failure; commit-before-ack crash; duplicate receipt after rejoin; pass entitlement refresh; delayed grant with menu closed. Record each as pass/fail/blocked in QA using real runtime evidence.

Current platform basis: use local-player runtime product data for personalized prices; developer-product grants require server receipt processing; permanent passes use ownership entitlement checks. [Regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing), [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService).
