--!strict
-- Opt-in, original scoring experiment. No runtime bootstrap requires this module.
-- Only a future server adapter may submit authoritative round outcomes.
local Series = {}
Series.__index = Series
local defaults = {
	Mode = "Circuit",
	Rounds = 3,
	Target = 12,
	MaxRounds = 5,
	MaxOvertimes = 1,
	WinnerBonus = 1,
	MinRounds = 1,
	PointValue = 1,
}
local function integer(value: any, low: number, high: number): boolean
	return type(value) == "number" and value == value and value >= low and value <= high and value % 1 == 0
end
function Series.new(matchId: string, roster: any, options: any?)
	assert(
		type(matchId) == "string" and #matchId > 0 and #matchId <= 96,
		"Series needs a bounded server match identity"
	)
	assert(type(roster) == "table" and #roster >= 2 and #roster <= 6, "Series needs two to six competitors")
	local config = table.clone(defaults)
	for k, v in options or {} do
		assert(config[k] ~= nil, "Unknown series option")
		config[k] = v
	end
	assert(config.Mode == "Circuit" or config.Mode == "Sprint", "Unknown series mode")
	for _, key in { "Rounds", "MaxRounds", "MinRounds" } do
		assert(integer(config[key], 1, 12), "Invalid round bound")
	end
	assert(
		integer(config.Target, 1, 1000) and integer(config.MaxOvertimes, 0, 3) and integer(config.WinnerBonus, 0, 3),
		"Invalid scoring bound"
	)
	assert(integer(config.PointValue, 1, 100), "Invalid point value")
	local self: any = setmetatable({
		matchId = matchId,
		config = table.freeze(config),
		players = {},
		byId = {},
		phase = "Ready",
		round = 0,
		revision = 0,
		lastSequence = 0,
		settled = {},
		overtimes = 0,
		nextOvertime = false,
		winnerIds = {},
		history = {},
	}, Series)
	for _, item in roster do
		assert(
			type(item.id) == "string" and #item.id > 0 and #item.id <= 64 and not self.byId[item.id],
			"Competitors need unique stable IDs"
		)
		local p = { id = item.id, name = item.name or item.id, score = 0, connected = true }
		table.insert(self.players, p)
		self.byId[p.id] = p
	end
	return self
end
function Series:_leaders()
	local winners = {}
	local highest = -1
	for _, p in self.players do
		if p.connected then
			if p.score > highest then
				highest = p.score
				winners = {}
			end
			if p.score == highest then
				table.insert(winners, p.id)
			end
		end
	end
	table.sort(winners)
	return winners, highest
end
function Series:_finish(reason: string, winners: any)
	self.phase = "Final"
	self.reason = reason
	self.winnerIds = winners
	self.activeRoundId = nil
	self.revision += 1
end
function Series:beginRound(): (boolean, string)
	if self.phase ~= "Ready" and self.phase ~= "Intermission" then
		return false, "PHASE"
	end
	local ids = {}
	for _, p in self.players do
		if p.connected then
			table.insert(ids, p.id)
		end
	end
	if #ids < 2 then
		self:_finish("Abandoned", {})
		return false, "ABANDONED"
	end
	self.round += 1
	self.activeRoundId = self.matchId .. ":r" .. self.round
	self.activeIds = ids
	self.activeOvertime = self.nextOvertime
	self.nextOvertime = false
	self.phase = "RoundActive"
	self.revision += 1
	return true, self.activeRoundId
end
function Series:disconnect(id: string): (boolean, string)
	if self.phase == "Final" then
		return false, "FINAL"
	end
	local p = self.byId[id]
	if not p then
		return false, "PLAYER"
	end
	if not p.connected then
		return true, "ALREADY_LEFT"
	end
	p.connected = false
	self.revision += 1
	local connected = 0
	for _, item in self.players do
		if item.connected then
			connected += 1
		end
	end
	if connected < 2 then
		self:_finish("Abandoned", {})
	end
	return true, "LEFT"
end
function Series:settleRound(matchId: any, roundId: any, sequence: any, rows: any): (boolean, string)
	if matchId ~= self.matchId then
		return false, "MATCH"
	end
	if type(roundId) ~= "string" then
		return false, "ROUND"
	end
	if self.settled[roundId] then
		return true, "ALREADY_SETTLED"
	end
	if self.phase ~= "RoundActive" or roundId ~= self.activeRoundId then
		return false, "ROUND"
	end
	if not integer(sequence, 1, 1000000000) or sequence <= self.lastSequence then
		return false, "STALE"
	end
	local n = #self.activeIds
	if type(rows) ~= "table" or #rows ~= n then
		return false, "ROSTER"
	end
	local allowed = {}
	for _, id in self.activeIds do
		allowed[id] = true
	end
	local seen = {}
	local deadCounts = {}
	local alive = 0
	for _, row in rows do
		if type(row) ~= "table" or not allowed[row.id] or seen[row.id] or type(row.alive) ~= "boolean" then
			return false, "ROSTER"
		end
		seen[row.id] = true
		if row.alive then
			if not self.byId[row.id].connected then
				return false, "LEFT_ALIVE"
			end
			alive += 1
		else
			if not integer(row.placement, 1, n) then
				return false, "PLACEMENT"
			end
			deadCounts[row.placement] = (deadCounts[row.placement] or 0) + 1
		end
	end
	-- Existing Simulation gives simultaneous deaths the pre-batch alive count.
	local ranks = {}
	for rank in deadCounts do
		table.insert(ranks, rank)
	end
	table.sort(ranks)
	local ahead = alive
	for _, rank in ranks do
		ahead += deadCounts[rank]
		if rank ~= ahead then
			return false, "PLACEMENT_GROUP"
		end
	end
	for _, row in rows do
		if row.alive and row.placement ~= nil and (alive ~= 1 or row.placement ~= 1) then
			return false, "PLACEMENT"
		end
	end
	local ledger = { roundId = roundId, round = self.round, sequence = sequence, awards = {} }
	for _, row in rows do
		local p = self.byId[row.id]
		local points = if row.alive then n - alive else n - row.placement
		if row.alive and alive == 1 then
			points += self.config.WinnerBonus
		end
		if not p.connected then
			points = 0
		end
		points *= self.config.PointValue
		local before = p.score
		p.score += points
		table.insert(ledger.awards, { id = p.id, before = before, delta = points, total = p.score })
	end
	self.settled[roundId] = true
	self.lastSequence = sequence
	self.activeRoundId = nil
	table.insert(self.history, ledger)
	self.revision += 1
	local leaders, highest = self:_leaders()
	local finish = self.activeOvertime
		or (
			if self.config.Mode == "Circuit"
				then self.round >= self.config.Rounds
				else (highest >= self.config.Target and self.round >= self.config.MinRounds)
					or self.round >= self.config.MaxRounds
		)
	if finish then
		if #leaders > 1 and self.overtimes < self.config.MaxOvertimes then
			self.overtimes += 1
			self.nextOvertime = true
			self.phase = "Intermission"
		else
			self:_finish(if #leaders > 1 then "SharedVictory" else "Points", leaders)
		end
	else
		self.phase = "Intermission"
	end
	return true, "SETTLED"
end
function Series:snapshot()
	local players = {}
	for _, p in self.players do
		table.insert(players, table.clone(p))
	end
	table.sort(players, function(a, b)
		if a.connected ~= b.connected then
			return a.connected
		end
		if a.score ~= b.score then
			return a.score > b.score
		end
		return a.id < b.id -- Stable presentation only; equal scores retain equal places.
	end)
	local rank = 1
	for i, p in players do
		if i > 1 and (p.score ~= players[i - 1].score or p.connected ~= players[i - 1].connected) then
			rank = i
		end
		p.rank = rank
	end
	local ledger = nil
	if #self.history > 0 then
		local last = self.history[#self.history]
		ledger = { roundId = last.roundId, round = last.round, sequence = last.sequence, awards = {} }
		for _, award in last.awards do
			table.insert(ledger.awards, table.clone(award))
		end
	end
	return {
		matchId = self.matchId,
		phase = self.phase,
		round = self.round,
		roundId = self.activeRoundId,
		revision = self.revision,
		overtime = self.nextOvertime or self.activeOvertime,
		winnerIds = table.clone(self.winnerIds),
		reason = self.reason,
		players = players,
		ledger = ledger,
		prototype = true,
	}
end
return Series
