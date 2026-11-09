--!strict
-- Isolated Studio/mock-persistence harness; never activates production storage/purchases.
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Http = game:GetService("HttpService")
local S = game:GetService("ServerScriptService").TrailWars
local Match = require(S.MatchService)
local ProfileStore = require(S.ProfileStore)
local Economy = require(S.EconomyService)
local MockStore = require(S.MockStore)
local Config = require(RS.TrailWars.GameplayConfig)
local Stepper = require(RS.TrailWars.FixedStepper)
Players.CharacterAutoLoads = false
local profiles = ProfileStore.new(MockStore.new())
local testArgs = game:GetService("StudioTestService"):GetTestArgs()
local testConfig = if type(testArgs) == "table" and testArgs.case == "TrailWarsAuthority"
	then { CountdownSeconds = 0.3, MaxRoundSeconds = 6 }
	else nil
local match = Match.new({
	namespace = Http:GenerateGUID(false),
	config = testConfig,
	allowRewards = RunService:IsStudio(),
	reward = function(id, matchId, won)
		return profiles:transact(tonumber(string.sub(id, 2)), function(profile)
			return Economy.roundReward(profile, matchId, won)
		end)
	end,
})
local intent = Instance.new("RemoteEvent")
intent.Name = "GameplayIntent"
intent.Parent = RS.TrailWars
local frames = Instance.new("RemoteEvent")
frames.Name = "GameplayFrame"
frames.Parent = RS.TrailWars
local events = Instance.new("RemoteEvent")
events.Name = "TrailWarsMatchEvent"
events.Parent = RS.TrailWars
local cursors: any = {}
local function add(p)
	match:add("u" .. p.UserId, p.DisplayName)
	profiles:load(p.UserId)
	cursors[p] = { matchId = nil, count = 0, phase = nil, event = 0, full = true }
end
Players.PlayerAdded:Connect(add)
for _, p in Players:GetPlayers() do
	task.spawn(add, p)
end
Players.PlayerRemoving:Connect(function(p)
	match:remove("u" .. p.UserId)
	cursors[p] = nil
	profiles:release(p.UserId)
end)
local requestTrace = {}
intent.OnServerEvent:Connect(function(p, message)
	local ok, code = match:request("u" .. p.UserId, message)
	if testConfig and type(message) == "table" and message.action ~= "Steer" then
		table.insert(requestTrace, {
			id = p.UserId,
			action = message.action,
			sequence = message.sequence,
			tick = match.tick,
			ok = ok,
			code = code,
		})
	end
	if
		ok
		and type(message) == "table"
		and (message.action == "Resync" or message.action == "Join" or message.action == "Rematch")
		and cursors[p]
	then
		cursors[p].full = true
	end
	if ok and type(message) == "table" and message.action == "Leave" then
		events:FireClient(
			p,
			{ kind = "Home", matchId = if match.round then match.round.matchId else "", isMock = true }
		)
	end
end)
local acc = Stepper.new(Config.Step, Config.MaxCatchupSteps, Config.MaxBacklogSeconds)
local publishClock = 0
local function publish()
	local state = match:snapshot()
	local segments = if match.round then match.round.sim.index.segments else {}
	for p, cursor in cursors do
		local full = cursor.full or cursor.matchId ~= state.matchId
		local from = if full then 1 else cursor.count + 1
		local delta = {}
		local last = math.min(#segments, from + Config.MaxSegmentsPerPacket - 1)
		for i = from, last do
			local s = segments[i]
			table.insert(delta, { owner = s.owner, ax = s.ax, ay = s.ay, bx = s.bx, by = s.by })
		end
		local member = match.members["u" .. p.UserId]
		frames:FireClient(
			p,
			{ state = state, segments = delta, from = from, full = full, ack = if member then member.sequence else 0 }
		)
		if cursor.phase ~= state.phase or cursor.matchId ~= state.matchId then
			local kind = if state.phase == "Active" then "Started" else state.phase
			events:FireClient(p, {
				kind = kind,
				matchId = state.matchId,
				isMock = true,
				remaining = state.remaining,
				winnerId = state.winnerId,
				winnerUserId = if state.winnerId then tonumber(string.match(state.winnerId, "^u(-?%d+)$")) else nil,
			})
		end
		if match.round then
			for i = if full then 1 else cursor.event + 1, #match.round.sim.events do
				local e = match.round.sim.events[i]
				events:FireClient(
					p,
					{ kind = "Eliminated", matchId = state.matchId, isMock = true, id = e.id, placement = e.placement }
				)
				if e.id == "u" .. p.UserId then
					events:FireClient(
						p,
						{ kind = "Spectating", matchId = state.matchId, isMock = true, placement = e.placement }
					)
				end
			end
			cursor.event = #match.round.sim.events
		end
		cursor.matchId = state.matchId
		cursor.count = last
		cursor.phase = state.phase
		cursor.full = false
	end
	RS.TrailWars:SetAttribute("MatchPhase", state.phase)
	RS.TrailWars:SetAttribute("MatchTick", state.tick)
end
RunService.Heartbeat:Connect(function(dt)
	acc:advance(dt, function()
		match:step()
	end)
	publishClock += dt
	if publishClock >= 0.1 then
		publishClock = 0
		publish()
	end
end)
if RunService:IsStudio() then
	local probe = Instance.new("BindableFunction")
	probe.Name = "MatchProbe"
	probe.Parent = S
	probe.OnInvoke = function(action, id, message)
		if action == "Request" then
			return match:request(id, message)
		elseif action == "Profile" then
			return profiles:snapshot(tonumber(string.sub(id, 2)))
		end
		return {
			state = match:snapshot(),
			rejected = match.rejected,
			trace = requestTrace,
			droppedSeconds = acc.droppedSeconds,
		}
	end
end
game:BindToClose(function()
	for _, p in Players:GetPlayers() do
		profiles:release(p.UserId)
	end
end)
