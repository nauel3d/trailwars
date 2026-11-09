--!strict
-- Additive extension. Legacy economy/cosmetics/settings and stats are never reset.
local Stats = {}
Stats.keys = {
	"matchesPlayed",
	"matchesWon",
	"matchesLost",
	"roundsPlayed",
	"roundsWon",
	"deaths",
	"kills",
	"powerHits",
	"turretHits",
	"scoreStolen",
	"totalPlaySeconds",
}
local function number(n: any)
	return type(n) == "number" and n == n and n >= 0 and n % 1 == 0 and n <= 1000000000
end
function Stats.ensure(profile: any): (boolean, string)
	if profile.playtest == nil then
		local values = {}
		for _, key in Stats.keys do
			values[key] = 0
		end
		values.roundsPlayed = profile.stats.rounds
		values.roundsWon = profile.stats.wins
		profile.playtest = { version = 1, stats = values, rounds = {}, matches = {}, sessions = {} }
	end
	local p = profile.playtest
	if
		type(p) ~= "table"
		or p.version ~= 1
		or type(p.stats) ~= "table"
		or type(p.rounds) ~= "table"
		or type(p.matches) ~= "table"
		or type(p.sessions) ~= "table"
	then
		return false, "UNSUPPORTED_STATS"
	end
	for _, key in Stats.keys do
		if not number(p.stats[key]) then
			return false, "CORRUPT_STATS"
		end
	end
	return true, "OK"
end
local function ledger(profile: any, kind: string, id: any, delta: any)
	local ok, code = Stats.ensure(profile)
	if not ok then
		return false, code
	end
	if type(id) ~= "string" or #id < 1 or #id > 160 or type(delta) ~= "table" then
		return false, "EVENT"
	end
	if profile.playtest[kind][id] then
		return true, "ALREADY_SAVED"
	end
	local count = 0
	for _ in profile.playtest[kind] do
		count += 1
	end
	if count >= 2000 then
		return false, "LEDGER_FULL"
	end
	for key, value in delta do
		if profile.playtest.stats[key] == nil or not number(value) or key == "totalPlaySeconds" then
			return false, "DELTA"
		end
	end
	for key, value in delta do
		profile.playtest.stats[key] += value
	end
	profile.playtest[kind][id] = true
	return true, "SAVED"
end
function Stats.round(profile: any, id: string, delta: any)
	return ledger(profile, "rounds", id, delta)
end
function Stats.match(profile: any, id: string, won: boolean)
	return ledger(
		profile,
		"matches",
		id,
		{ matchesPlayed = 1, matchesWon = if won then 1 else 0, matchesLost = if won then 0 else 1 }
	)
end
function Stats.time(profile: any, sessionId: string, elapsed: number)
	local ok, code = Stats.ensure(profile)
	if not ok then
		return false, code
	end
	if type(sessionId) ~= "string" or #sessionId > 160 or not number(elapsed) then
		return false, "TIME"
	end
	local previous = profile.playtest.sessions[sessionId] or 0
	if elapsed > previous then
		profile.playtest.stats.totalPlaySeconds += elapsed - previous
		profile.playtest.sessions[sessionId] = elapsed
	end
	return true, "SAVED"
end
function Stats.public(profile: any, sessionSeconds: number)
	local copy = table.clone(profile.playtest.stats)
	copy.sessionPlaySeconds = math.floor(sessionSeconds)
	return copy
end
function Stats.format(seconds: number): string
	return string.format("%dh %02dm", math.floor(seconds / 3600), math.floor(seconds % 3600 / 60))
end
return Stats
