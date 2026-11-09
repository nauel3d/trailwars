# Economy balance hypotheses and validation plan

**PROVISIONAL; no live prices or approved offer.** All values below are internal test assumptions for an earned-currency simulation. They must not be shown as fabricated production balances or implemented as confirmed Robux prices. No final paid bundle is selected while the reference audit remains open.

Goal: a newcomer can make an appearance choice during a first short session; longer goals remain optional. Cosmetic choice must never require wins. Do not reward AFK time, client-claimed results or purchases with combat advantage.

| Hypothesis | Starting simulation value | Expected implication | Experiment / rejection condition |
| --- | --- | --- | --- |
| Completed eligible round reward | 10 earned units | Participation matters without requiring victory. | Measure legitimate completion time and abuse attempts; reject if AFK farming dominates. |
| Small placement bonus | 0–4 earned units | Skill recognition without large earnings inequality. | Compare new/experienced time-to-unlock; remove if skill gap discourages newcomers. |
| First alternate appearance | 100 units | About 8–10 eligible rounds at 10–14 units each. | Use actual round cadence; reject if onboarding session cannot make progress visible. |
| Mid-term appearance | 300 units | About 22–30 eligible rounds. | Inspect voluntary session return and frustration, not only conversion. |
| Longer appearance | 600 units | About 43–60 eligible rounds. | Remove if it is interpreted as mandatory status or progression gating. |
| Daily streak | None | No punishment for missed days. | Keep absent unless a user-need study supports a nonpunitive alternative. |
| Currency expiry | None | Prior play remains useful. | Never introduce as a purchase pressure lever. |
| Paid currency packs | None at launch | No exchange-rate calculation or double currency UI. | Revisit only after evidence of a clear user need, not monetization imitation. |

Time-to-unlock arithmetic is `ceil(cost / expected legitimate reward)`; it does not include queue, loading or result-screen time. At a **hypothetical** 75-second round plus 15-second turnaround, 10 rounds are 15 minutes; this is not a measured gameplay duration. Do not present these estimates to players until measured under actual game conditions.

Server-owned reward records contain round ID, eligibility outcome and transaction ID. A trusted future match service supplies result facts. The mock harness supplies no production reward eligibility. A completed-round grant retries safely and cannot repeat when results are reopened. Currency remains a nonnegative bounded integer; cost is catalog-owned and atomically checked with ownership before spending.

No actual Robux tiers are set. Later pricing research should compare relative tiers (single appearance, small collection, larger collection) with exact declared contents and runtime user price. Set maximum spending expectations through honest contents, not fake discounts. Do not convert observed euro reference prices into Robux recommendations.

Measure: first unlock completion rate; median and 90th-percentile eligible rounds to unlock; ratio of free/premium equipped items; duplicate-purchase attempts; failed grants and reconciliation age; understanding of permanent ownership. Analyze new and returning players separately. A test should be rejected if it harms core comprehension, lengthens rematch friction, increases support burden, or makes free appearance quality feel deliberately inferior.

Balance changes must version catalog costs; pending earned unlocks use a server quote/version so a stale client cannot be charged a surprise changed amount. Existing permanent ownership is preserved during catalog migration. Adjust future rewards prospectively; do not remove already-earned currency to hit a target.

Launch gate: validate round duration and reward eligibility first, test persistence and replay resistance second, then decide whether earned currency is actually simpler than direct milestone unlocks. If currency adds explanation burden without meaningful choice, use deterministic cosmetic milestones instead.
