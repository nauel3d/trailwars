--!strict
export type Settings = { music: number, sound: number, reducedMotion: boolean, textScale: number }
export type Profile = {
	version: number, revision: number, coins: number, xp: number,
	owned: { [string]: boolean }, equipped: { [string]: string },
	settings: Settings, stats: { rounds: number, wins: number },
	receipts: { [string]: number }, rewards: { [string]: boolean },
	lease: { owner: string, expires: number }?,
}
export type Request = { action: string, itemId: string?, setting: string?, value: any }
export type Response = { ok: boolean, code: string, profile: any?, isMock: boolean }
-- The future authoritative match service calls the server RewardService. No client
-- remote accepts wins, XP, collision outcomes, or rewards.
export type MatchEvent = {
	kind: "Queue" | "Countdown" | "Started" | "Eliminated" | "Spectating" | "Results" | "Home",
	matchId: string, isMock: boolean, remaining: number?, winnerUserId: number?,
}
return table.freeze({
	RemoteName = "TrailWarsRequest",
	MatchEventName = "TrailWarsMatchEvent",
	Actions = table.freeze({ Snapshot = true, Equip = true, BuyEarned = true, SetSetting = true }),
})
