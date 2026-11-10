--!strict
local ST = game:GetService("StudioTestService")
local args = ST:GetTestArgs()
if type(args) ~= "table" or args.case ~= "Nov10" then
	return
end
local RS = game.ReplicatedStorage
local Players = game:GetService("Players")
local report = Instance.new("RemoteEvent")
report.Name = "Nov10TestReport"
report.Parent = RS
local ready = {}
local reports = {}
report.OnServerEvent:Connect(function(p, data)
	if data == "Ready" then
		ready[p.UserId] = true
	elseif type(data) == "table" then
		reports[p.UserId] = data
	end
end)
local function count(t)
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end
local deadline = os.clock() + 65
while count(ready) < 2 and os.clock() < deadline do
	task.wait(0.1)
end
if count(ready) < 2 then
	ST:EndTest({ ok = false, error = "Two clients did not start", ready = count(ready) })
	return
end
local humans = Players:GetPlayers()
table.sort(humans, function(a, b)
	return a.UserId > b.UserId
end)
local a, b = "u" .. humans[1].UserId, "u" .. humans[2].UserId
RS:SetAttribute("Nov10A", a)
RS:SetAttribute("Nov10B", b)
RS:SetAttribute("Nov10Start", true)
local probe = game.ServerScriptService.TrailWars:WaitForChild("PlaytestProbe")
local flags = {
	jumpCross = false,
	homingHit = false,
	turretHit = false,
	turretSteered = false,
	kill = false,
	cooldown = false,
	cleanup = false,
	final = false,
	rematch = false,
}
local prepared = {}
local firstId = nil
local released = false
local crossedTick = nil
local killed = false
local lastRocketHeading = nil
local finalLog = {}
local finals = nil
local firstSeries = nil
deadline = os.clock() + 90
while os.clock() < deadline do
	probe:Invoke("Fixture", nil, function(m)
		m.config.BotPowers = false
		if not m.series or not m.round then
			return
		end
		firstSeries = firstSeries or m.series.matchId
		local r = m.round
		local sim = r.sim
		if m.series.matchId == firstSeries and not prepared[r.matchId] then
			prepared[r.matchId] = true
			for i, p in sim.players do
				if p.id == a then
					p.x = 300
					p.y = 300
					p.heading = 0
				elseif p.id == b then
					p.x = 650
					p.y = 300
					p.heading = math.pi
				else
					p.isBot = false
					p.x = 1290
					p.y = 500 + i * 30
					p.heading = 0
				end
			end
			if m.series.round == 1 then
				firstId = r.matchId
				sim.config.MaxRoundSeconds = 15 -- Allow a controlled miss to expire before the next auto-launch.
				sim.config.Speed = 0
				local bot = sim.byId.bot3
				bot.x = 360
				bot.y = 360
				bot.heading = 0
				sim.byId.bot4.x = 1000
				sim.byId.bot4.y = 650
				sim.index:insert({ owner = b, ax = 315, ay = 280, bx = 315, by = 320, endDistance = 0 })
				sim.index:insert({ owner = a, ax = 500, ay = 280, bx = 500, by = 320, endDistance = 0 })
				m.powers.actors[a].ready.Jump = 0
				m.powers.actors[a].ready.Homing = 0
			else
				sim.byId[b].x = 500
			end
		end
		if r.matchId == firstId and m.phase == "Active" then
			if m.powers.actors[a].jumpUntil > 0 and not released then
				sim.config.Speed = 105
				released = true
			end
			local player = sim.byId[a]
			if player.x > 330 and player.alive and not flags.jumpCross then
				flags.jumpCross = true
				crossedTick = m.tick
				sim.byId[b].x = 510
				sim.byId[b].y = 300
				sim.byId[b].heading = math.pi
			end
			if crossedTick and not sim.byId[b].alive and not killed then
				killed = true
				sim.config.Speed = 0
			end
			for _, q in m.powers.projectiles do
				if q.kind == "Turret" and q.owner == b then
					if lastRocketHeading and math.abs(q.heading - lastRocketHeading) > 0.01 then
						flags.turretSteered = true
						RS:SetAttribute("Nov10Steered", true)
					end
					lastRocketHeading = q.heading
				end
			end
			local activations = {}
			for _, e in m.powers.events do
				if e.id == a then
					activations[e.slot] = (activations[e.slot] or 0) + 1
				end
			end
			if activations.Homing == 1 and activations.Jump == 1 then
				flags.cooldown = true
			end
			for _, e in m.log do
				if e.kind == "Homing" and e.owner == a then
					flags.homingHit = true
				end
				if e.kind == "Turret" and e.owner == b then
					flags.turretHit = true
				end
				if e.kind == "Eliminated" and e.victim == b and e.owner == a then
					flags.kill = true
				end
			end
			if flags.turretHit and flags.turretSteered then
				sim.config.Speed = 105
				for _, id in { "bot3", "bot4" } do
					if sim.byId[id].alive then
						sim.byId[id].x = 1290
						sim.byId[id].heading = 0
					end
				end
			end
		end
		if m.phase == "Intermission" or m.phase == "Final" then
			if m.powers.closed and #m.powers.projectiles == 0 then
				flags.cleanup = true
			end
		end
		if m.phase == "Final" and m.series.matchId == firstSeries then
			flags.final = true
			finals = m:snapshot()
			finalLog = table.clone(m.log)
		end
		if firstSeries and m.series.matchId ~= firstSeries then
			flags.rematch = true
		end
	end)
	-- A server-side Final is not proof that either client rendered results.
	-- Do not tell clients to clear their result screens until BOTH acknowledged
	-- the real winner card. This also makes a missing Final packet fail visibly.
	local bothSawFinal = count(reports) == 2
	for _, r in reports do
		if not r.final or (not args.renderControl and not r.winnerPresentation) then
			bothSawFinal = false
		end
	end
	if flags.final and bothSawFinal then
		RS:SetAttribute("Nov10Rematch", true)
	end
	local bothRematched = count(reports) == 2
	for _, r in reports do
		if not r.rematch or not r.clientFrameTiming then
			bothRematched = false
		end
	end
	if flags.rematch and bothRematched then
		break
	end
	task.wait(0.02)
end
local saved = probe:Invoke("Flush")
local savedAgain = probe:Invoke("Flush")
local ok = true
local errors = {}
for key, value in flags do
	if not value then
		ok = false
		table.insert(errors, key)
	end
end
for _, p in saved do
	local previous = nil
	for _, q in savedAgain do
		if q.id == p.id then
			previous = q.stats
		end
	end
	if not previous or p.stats.matchesPlayed ~= 1 or previous.matchesPlayed ~= 1 then
		ok = false
		table.insert(errors, "match idempotency " .. p.id)
	end
	local expectedKills, expectedPower, expectedTurret = 0, 0, 0
	for _, e in finalLog do
		if e.owner == p.id then
			if e.kind == "Eliminated" and e.cause == "Trail" then
				expectedKills += 1
			elseif e.kind == "Homing" then
				expectedPower += 1
			elseif e.kind == "Turret" then
				expectedTurret += 1
			end
		end
	end
	if p.stats.kills ~= expectedKills or p.stats.powerHits ~= expectedPower or p.stats.turretHits ~= expectedTurret then
		ok = false
		table.insert(errors, "cause-based stats " .. p.id)
	end
	local won = table.find(finals.series.winnerIds, p.id) ~= nil
	if p.stats.matchesWon ~= (if won then 1 else 0) or p.stats.matchesLost ~= (if won then 0 else 1) then
		ok = false
		table.insert(errors, "final stats " .. p.id)
	end
end
for _, p in humans do
	local r = reports[p.UserId]
	if
		not r
		or not r.active
		or not r.intermission
		or not r.final
		or (not args.renderControl and not r.winnerPresentation)
		or not r.cooldownProgress
	then
		ok = false
		table.insert(errors, "client flow " .. p.Name)
	end
end
ST:EndTest({
	ok = ok,
	flags = flags,
	errors = errors,
	statistics = saved,
	clients = reports,
	final = finals,
	events = finalLog,
	method = "Actual two-client Roblox engine; controlled geometry fixtures, real RemoteEvent intents; no fabricated hit/death/score events",
})
