--!strict
-- Development only; excluded from default.project.json and production build.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("TrailWars")
local Schema = require(Shared.ProfileSchema)
local Catalog = require(Shared.Catalog)
local Fixtures = {}
function Fixtures.profile(coins: number?): any
	local profile = Schema.new()
	profile.coins = coins or 480
	profile.xp = 120
	profile.stats = { rounds = 12, wins = 3 }
	return Schema.public(profile)
end
function Fixtures.transport(initial: any): (any) -> any
	local profile = Schema.copy(initial)
	return function(message: any): any
		local ok, code = true, "OK"
		if message.action == "Equip" then
			local item = Catalog.ById[message.itemId]
			if not item or not profile.owned[message.itemId] then
				ok, code = false, "NOT_OWNED"
			else
				profile.equipped[item.slot] = item.id
				code = "EQUIPPED"
			end
		elseif message.action == "BuyEarned" then
			local item = Catalog.ById[message.itemId]
			if not item or not item.earnedCost then
				ok, code = false, "NOT_FOR_SALE"
			elseif profile.owned[item.id] then
				ok, code = false, "ALREADY_OWNED"
			elseif profile.coins < item.earnedCost then
				ok, code = false, "INSUFFICIENT_FUNDS"
			else
				profile.coins -= item.earnedCost
				profile.owned[item.id] = true
				code = "PURCHASED"
			end
		elseif message.action == "SetSetting" then
			if Schema.setting(message.setting, message.value) then
				profile.settings[message.setting] = message.value
				code = "SAVED"
			else
				ok, code = false, "INVALID_SETTING"
			end
		elseif message.action ~= "Snapshot" then
			ok, code = false, "INVALID_REQUEST"
		end
		return { ok = ok, code = code, profile = Schema.copy(profile), isMock = true }
	end
end
return Fixtures
