--!strict
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("TrailWars")
local Catalog = require(Shared.Catalog)
local Schema = require(Shared.ProfileSchema)
local Config = require(Shared.Config)
local Economy = {}
function Economy.equip(profile: any, itemId: any): (boolean, string)
	if type(itemId) ~= "string" then return false, "INVALID_ITEM" end
	local item = Catalog.ById[itemId]
	if not item then return false, "INVALID_ITEM" end
	if profile.owned[itemId] ~= true then return false, "NOT_OWNED" end
	profile.equipped[item.slot] = itemId
	return true, "EQUIPPED"
end
function Economy.buyEarned(profile: any, itemId: any): (boolean, string)
	if type(itemId) ~= "string" then return false, "INVALID_ITEM" end
	local item = Catalog.ById[itemId]
	if not item or not item.earnedCost then return false, "NOT_FOR_SALE" end
	if profile.owned[itemId] then return false, "ALREADY_OWNED" end
	if profile.coins < item.earnedCost then return false, "INSUFFICIENT_FUNDS" end
	profile.coins -= item.earnedCost
	profile.owned[itemId] = true
	return true, "PURCHASED"
end
function Economy.setting(profile: any, key: any, value: any): (boolean, string)
	if not Schema.setting(key, value) then return false, "INVALID_SETTING" end
	profile.settings[key] = value
	return true, "SAVED"
end
local function count(records: any): number
	local result = 0
	for _ in records do result += 1 end
	return result
end
-- Server only. The future match service must pass a durable, unique match ID.
-- Never expose this function through a client remote.
function Economy.roundReward(profile: any, matchId: string, didWin: boolean): (boolean, string)
	if #matchId < 1 or #matchId > 128 then return false, "INVALID_MATCH" end
	if profile.rewards[matchId] then return true, "ALREADY_GRANTED" end
	if count(profile.rewards) >= Config.MaxRewardRecords then return false, "REWARD_LEDGER_FULL" end
	profile.rewards[matchId] = true
	profile.stats.rounds += 1
	if didWin then profile.stats.wins += 1 end
	-- Provisional test economy, not final balancing.
	profile.coins += if didWin then 15 else 5
	profile.xp += if didWin then 20 else 10
	return true, "REWARDED"
end
function Economy.receipt(profile: any, purchaseId: string, productId: number, itemId: string): (boolean, string)
	local recorded = profile.receipts[purchaseId]
	if recorded ~= nil then
		return recorded == productId, if recorded == productId then "ALREADY_GRANTED" else "RECEIPT_CONFLICT"
	end
	if count(profile.receipts) >= Config.MaxReceiptRecords then return false, "RECEIPT_LEDGER_FULL" end
	if not Catalog.ById[itemId] then return false, "INVALID_PRODUCT_GRANT" end
	-- Receipt tombstone and entitlement share one atomic profile commit.
	profile.owned[itemId] = true
	profile.receipts[purchaseId] = productId
	return true, "GRANTED"
end
return Economy
