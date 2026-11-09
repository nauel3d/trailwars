--!strict
local Catalog = require(script.Parent.Catalog)
local Config = require(script.Parent.Config)
local Schema = {}
function Schema.copy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[key] = Schema.copy(child)
	end
	return result
end
function Schema.new(): any
	return {
		version = Config.SchemaVersion,
		revision = 0,
		coins = 0,
		xp = 0,
		owned = { core_default = true, trail_default = true },
		equipped = { core = "core_default", trail = "trail_default" },
		settings = { music = 0.5, sound = 0.7, reducedMotion = false, textScale = 1 },
		stats = { rounds = 0, wins = 0 },
		receipts = {},
		rewards = {},
	}
end
local function finite(n: any): boolean
	return type(n) == "number" and n == n and math.abs(n) < math.huge
end
function Schema.setting(key: any, value: any): boolean
	if key == "reducedMotion" then
		return type(value) == "boolean"
	end
	if key == "music" or key == "sound" then
		return finite(value) and value >= 0 and value <= 1
	end
	if key == "textScale" then
		return finite(value) and value >= 1 and value <= 1.5
	end
	return false
end
function Schema.migrate(raw: any): (any?, string?)
	if raw == nil then
		return Schema.new(), nil
	end
	if type(raw) ~= "table" or raw.version ~= Config.SchemaVersion then
		return nil, "UNSUPPORTED_SCHEMA" -- Never overwrite newer/corrupt data with defaults.
	end
	for _, key in { "revision", "coins", "xp" } do
		if not finite(raw[key]) or raw[key] < 0 or raw[key] % 1 ~= 0 then
			return nil, "CORRUPT_PROFILE"
		end
	end
	for _, key in { "owned", "equipped", "settings", "stats", "receipts", "rewards" } do
		if type(raw[key]) ~= "table" then
			return nil, "CORRUPT_PROFILE"
		end
	end
	for key, value in raw.settings do
		if not Schema.setting(key, value) then
			return nil, "CORRUPT_SETTINGS"
		end
	end
	for _, key in { "music", "sound", "reducedMotion", "textScale" } do
		if raw.settings[key] == nil then
			return nil, "CORRUPT_SETTINGS"
		end
	end
	for _, key in { "rounds", "wins" } do
		if not finite(raw.stats[key]) or raw.stats[key] < 0 or raw.stats[key] % 1 ~= 0 then
			return nil, "CORRUPT_STATS"
		end
	end
	for id, owned in raw.owned do
		if type(id) ~= "string" or type(owned) ~= "boolean" then
			return nil, "CORRUPT_OWNERSHIP"
		end
	end
	for slot, id in raw.equipped do
		local item = Catalog.ById[id]
		if item == nil or item.slot ~= slot or not raw.owned[id] then
			return nil, "CORRUPT_EQUIPMENT"
		end
	end
	for id, productId in raw.receipts do
		if type(id) ~= "string" or not finite(productId) then
			return nil, "CORRUPT_RECEIPTS"
		end
	end
	for id, granted in raw.rewards do
		if type(id) ~= "string" or granted ~= true then
			return nil, "CORRUPT_REWARDS"
		end
	end
	if
		raw.lease ~= nil
		and (type(raw.lease) ~= "table" or type(raw.lease.owner) ~= "string" or not finite(raw.lease.expires))
	then
		return nil, "CORRUPT_LEASE"
	end
	return Schema.copy(raw), nil
end
function Schema.public(profile: any): any
	local result = Schema.copy(profile)
	result.receipts, result.rewards, result.lease = nil, nil, nil
	return result
end
return Schema
