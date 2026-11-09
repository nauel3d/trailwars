--!strict
-- Pure authoritative coordinator. Adapter owns Players/Remotes/persistence.
local Shared = game:GetService("ReplicatedStorage").TrailWars
local Round = require(Shared.RoundSession)
local Protocol = require(Shared.GameplayProtocol)
local Config = require(Shared.GameplayConfig)
local Match = {}
Match.__index = Match
function Match.new(options: any?)
	local opts = options or {}
	return setmetatable({
		members = {},
		queue = {},
		round = nil,
		tick = 0,
		queueClock = 0,
		serial = 0,
		namespace = opts.namespace or "test",
		reward = opts.reward,
		allowRewards = opts.allowRewards == true,
		config = opts.config or {},
		rejected = 0,
		pendingRewards = {},
	}, Match)
end
function Match:add(id: string, name: string)
	if self.members[id] then
		return
	end
	self.members[id] = {
		id = id,
		name = string.sub(name, 1, 20),
		sequence = 0,
		window = -1,
		messages = 0,
		turn = 0,
		lease = 0,
		changes = 0,
		activeTicks = 0,
		joined = true,
	}
end
function Match:remove(id: string)
	self.queue[id] = nil
	if self.round then
		Round.remove(self.round, id)
	end
	self.members[id] = nil
end
function Match:request(id: string, message: any): (boolean, string)
	local m = self.members[id]
	if not m then
		return false, "PLAYER"
	end
	local window = math.floor(self.tick / Config.TickRate)
	if m.window ~= window then
		m.window = window
		m.messages = 0
	end
	m.messages += 1
	if m.messages > Config.MaxInputMessagesPerSecond then
		self.rejected += 1
		return false, "RATE"
	end
	local valid, code = Protocol.validate(message)
	if not valid then
		self.rejected += 1
		return false, code
	end
	if message.sequence <= m.sequence then
		return false, "STALE"
	end
	m.sequence = message.sequence
	if message.action == "Join" or message.action == "Rematch" then
		self.queue[id] = true
		m.joined = true
	elseif message.action == "Leave" then
		self.queue[id] = nil
		m.joined = false
		if self.round then
			Round.remove(self.round, id)
		end
	elseif message.action == "Steer" then
		local r = self.round
		if not r or r.matchId ~= message.matchId or r.phase ~= "Active" then
			return false, "MATCH"
		end
		local p = r.sim.byId[id]
		if not p or not p.alive then
			return false, "SPECTATOR"
		end
		if message.turn ~= m.turn then
			m.changes += 1
		end
		m.turn = message.turn
		m.lease = self.tick + Config.InputLeaseTicks
	elseif message.action == "Resync" then
		if self.tick - (m.lastResync or -1000) < Config.TickRate then
			return false, "RESYNC_RATE"
		end
		m.lastResync = self.tick
		m.resync = true
	end
	return true, "OK"
end
function Match:_start()
	local ids = {}
	for id in self.queue do
		if self.members[id] then
			table.insert(ids, id)
		end
	end
	table.sort(ids)
	if #ids == 0 then
		return
	end
	local roster = {}
	for i = 1, math.min(Config.MaxPlayers, #ids) do
		local id = ids[i]
		local m = self.members[id]
		table.insert(roster, { id = id, name = m.name })
		self.queue[id] = nil
		m.turn = 0
		m.lease = 0
		m.changes = 0
		m.activeTicks = 0
		m.rewarded = false
	end
	self.humanCount = #roster
	if #roster == 1 then
		for i = 1, 3 do
			table.insert(roster, { id = "bot" .. i, name = "BOT " .. i, isBot = true })
		end
	end
	self.serial += 1
	self.round = Round.new(roster, self.config, self.namespace .. ":" .. self.serial)
	self.queueClock = 0
end
function Match:step()
	self.tick += 1
	for key, pending in self.pendingRewards do
		if not self.members[pending.id] then
			self.pendingRewards[key] = nil
		elseif self.tick >= pending.nextTry then
			pending.nextTry = self.tick + Config.TickRate
			if self.reward(pending.id, pending.matchId, pending.won) == true then
				self.pendingRewards[key] = nil
			end
		end
	end
	local r = self.round
	if not r then
		if next(self.queue) then
			self.queueClock += Config.Step
		end
		local queued = 0
		for _ in self.queue do
			queued += 1
		end
		if (queued >= 2 and self.queueClock >= Config.QueueSeconds) or self.queueClock >= Config.SoloPracticeDelay then
			self:_start()
		end
		return
	end
	for id, m in self.members do
		r.inputs[id] = if self.tick <= m.lease then m.turn else 0
		local p = r.sim.byId[id]
		if p and p.alive and r.phase == "Active" then
			m.activeTicks += 1
		end
	end
	Round.step(r)
	if r.phase == "Results" then
		if not r.finalized then
			r.finalized = true
			self.eligible = {}
			for _, p in r.sim.players do
				local m = self.members[p.id]
				if
					not p.isBot
					and m
					and m.joined
					and self.humanCount >= 2
					and m.changes >= 1
					and m.activeTicks >= 100
				then
					self.eligible[p.id] = true
					if self.allowRewards and self.reward then
						self.pendingRewards[r.matchId .. "/" .. p.id] =
							{ id = p.id, matchId = r.matchId, won = r.sim.winnerId == p.id, nextTry = self.tick }
					end
				end
			end
		end
		if r.clock >= Config.ResultsSeconds and next(self.queue) then
			self:_start()
		end
	end
end
function Match:snapshot()
	if self.round then
		local s = Round.snapshot(self.round)
		s.isMock = true
		s.practice = self.humanCount == 1
		return s
	end
	return {
		phase = "Queue",
		matchId = "",
		players = {},
		time = 0,
		tick = 0,
		revision = self.tick,
		segmentCount = 0,
		remaining = 0,
		isMock = true,
	}
end
return Match
