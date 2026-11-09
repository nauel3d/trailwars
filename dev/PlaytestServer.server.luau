--!strict
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Run = game:GetService("RunService")
local Http = game:GetService("HttpService")
local S = game.ServerScriptService.TrailWars
local Profiles = require(S.ProfileStore)
local Store = require(S.MockStore)
local Stats = require(RS.TrailWars.PlaytestStats)
local Match = require(S.PlaytestMatchService)
local Stepper = require(RS.TrailWars.FixedStepper)
Players.CharacterAutoLoads = false
local profiles = Profiles.new(Store.new()) -- No DataStore access or production writes.
local sessions: any = {}
local pending = {}
local departed = {}
local cursors: any = {}
local function enqueue(id, kind, eventId, value)
	table.insert(pending, { id = id, kind = kind, eventId = eventId, value = value })
end
local testArgs = game:GetService("StudioTestService"):GetTestArgs()
local config = if type(testArgs) == "table" and testArgs.case == "Nov10"
	then { CountdownSeconds = 0.5, MaxRoundSeconds = 8, IntermissionSeconds = 2 }
	else { MaxRoundSeconds = 30 }
local match = Match.new(Http:GenerateGUID(false), {
	round = function(id, event, d)
		enqueue(id, "round", event, d)
	end,
	match = function(id, event, won)
		enqueue(id, "match", event, won)
	end,
}, config)
local intent = Instance.new("RemoteEvent")
intent.Name = "PlaytestIntent"
intent.Parent = RS.TrailWars
local frames = Instance.new("RemoteEvent")
frames.Name = "PlaytestFrame"
frames.Parent = RS.TrailWars
local function flush(p)
	local session = sessions[p]
	if not session then
		return
	end
	local elapsed = math.floor(os.clock() - session.start)
	local ok = profiles:transact(p.UserId, function(profile)
		return Stats.time(profile, session.id, elapsed)
	end)
	if ok then
		session.saved = elapsed
	end
end
local function add(p)
	departed[p.UserId] = nil
	local ok = profiles:load(p.UserId)
	if ok then
		profiles:transact(p.UserId, function(profile)
			return Stats.ensure(profile)
		end)
	end
	sessions[p] = { id = Http:GenerateGUID(false), start = os.clock(), saved = 0 }
	match:add("u" .. p.UserId, p.DisplayName)
	cursors[p] = { id = nil, count = 0, full = true }
	local leader = Instance.new("Folder")
	leader.Name = "leaderstats"
	leader.Parent = p
	for _, name in { "Wins", "Kills", "Score", "Minutes" } do
		local v = Instance.new("IntValue")
		v.Name = name
		v.Parent = leader
	end
end
local function drain()
	local keep = {}
	for _, event in pending do
		local uid = tonumber(event.id:sub(2))
		local ok = profiles:transact(uid, function(profile)
			return Stats[event.kind](profile, event.eventId, event.value)
		end)
		if not ok then
			table.insert(keep, event)
		end
	end
	pending = keep
end
Players.PlayerAdded:Connect(add)
for _, p in Players:GetPlayers() do
	task.spawn(add, p)
end
Players.PlayerRemoving:Connect(function(p)
	local id = "u" .. p.UserId
	match:remove(id)
	drain()
	flush(p)
	cursors[p] = nil
	sessions[p] = nil
	if match.round and not match.round.finalized then
		departed[p.UserId] = { roundId = match.round.matchId }
	else
		profiles:release(p.UserId)
	end
end)
intent.OnServerEvent:Connect(function(p, message)
	local ok = match:request("u" .. p.UserId, message)
	if
		ok
		and cursors[p]
		and (message.action == "Join" or message.action == "Rematch" or message.action == "Resync")
	then
		cursors[p].full = true
	end
end)
local function statistics()
	local out = {}
	for p, session in sessions do
		local profile = profiles:snapshot(p.UserId)
		if profile and profile.playtest then
			local elapsed = math.floor(os.clock() - session.start)
			local stats = Stats.public(profile, elapsed)
			stats.totalPlaySeconds += math.max(0, elapsed - (profile.playtest.sessions[session.id] or 0))
			local id = "u" .. p.UserId
			local d = match.delta and match.delta[id]
			if match.round and not match.round.finalized and d and match.series.byId[id].connected then
				for key, value in d do
					stats[key] += value
				end
			end
			local score = if match.series and match.series.byId[id] then match.series.byId[id].score else 0
			table.insert(out, { id = id, name = p.DisplayName, stats = stats, score = score })
			local l = p:FindFirstChild("leaderstats")
			if l then
				l.Wins.Value = stats.matchesWon
				l.Kills.Value = stats.kills
				l.Score.Value = score
				l.Minutes.Value = math.floor(stats.totalPlaySeconds / 60)
			end
		end
	end
	return out
end
local function publish()
	if #pending > 0 then
		drain()
	end
	for uid, item in departed do
		local waiting = false
		for _, e in pending do
			if tonumber(e.id:sub(2)) == uid then
				waiting = true
			end
		end
		if not waiting and (not match.round or match.round.finalized or match.round.matchId ~= item.roundId) then
			profiles:release(uid)
			departed[uid] = nil
		end
	end
	local state = match:snapshot()
	state.statistics = statistics()
	state.storage = "MOCK · server lifetime only"
	local segments = if match.round then match.round.sim.index.segments else {}
	for p, c in cursors do
		local full = c.full or c.id ~= state.roundId
		local from = if full then 1 else c.count + 1
		local last = math.min(#segments, from + 599)
		local delta = {}
		for i = from, last do
			local x = segments[i]
			table.insert(delta, { owner = x.owner, ax = x.ax, ay = x.ay, bx = x.bx, by = x.by })
		end
		frames:FireClient(p, { state = state, segments = delta, from = from, full = full })
		c.id = state.roundId
		c.count = last
		c.full = false
	end
end
local acc = Stepper.new(0.02, 8, 0.5)
local pub = 0
local save = 0
Run.Heartbeat:Connect(function(dt)
	acc:advance(dt, function()
		match:step()
	end)
	pub += dt
	save += dt
	if pub >= 0.1 then
		pub = 0
		publish()
	end
	if save >= 5 then
		save = 0
		drain()
		for p in sessions do
			flush(p)
		end
	end
end)
if Run:IsStudio() then
	local probe = Instance.new("BindableFunction")
	probe.Name = "PlaytestProbe"
	probe.Parent = S
	probe.OnInvoke = function(action, id, value)
		if action == "Snapshot" then
			return {
				state = match:snapshot(),
				statistics = statistics(),
				log = match.log,
				settlements = match.settlements,
				pending = #pending,
			}
		elseif action == "Flush" then
			drain()
			for p in sessions do
				flush(p)
			end
			return statistics()
		elseif action == "Request" then
			return match:request(id, value)
		elseif action == "Fixture" and type(testArgs) == "table" and testArgs.case == "Nov10" then
			return value(match) -- Studio engine fixture only; never a remote, not available in normal builds.
		end
		return nil
	end
end
game:BindToClose(function()
	drain()
	for p in sessions do
		flush(p)
		profiles:release(p.UserId)
	end
	for uid in departed do
		profiles:release(uid)
	end
end)
