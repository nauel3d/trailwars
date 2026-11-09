--!strict
-- Included only in the explicit automated test project, not regular builds.
local STS = game:GetService("StudioTestService")
local args = STS:GetTestArgs()
if type(args) ~= "table" or args.case ~= "TrailWarsAuthority" then
	return
end
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local report = Instance.new("RemoteEvent")
report.Name = "GameplayTestReport"
report.Parent = RS
local ready: any = {}
local received: any = {}
report.OnServerEvent:Connect(function(p, payload)
	if payload == "Ready" then
		ready[p.UserId] = true
	elseif type(payload) == "table" then
		received[p.UserId] = payload
	end
end)
local deadline = os.clock() + 45
local function count(t)
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end
while count(ready) < args.players and os.clock() < deadline do
	task.wait(0.1)
end
if count(ready) < args.players then
	STS:EndTest({ ok = false, error = "Client startup deadline", ready = count(ready) })
	return
end
RS:SetAttribute("GameplayTestStart", true)
while os.clock() < deadline do
	local phase = RS.TrailWars:GetAttribute("MatchPhase")
	local complete = count(received) == args.players
	for _, r in received do
		if not r.results then
			complete = false
		end
	end
	if phase == "Results" and complete then
		break
	end
	task.wait(0.1)
end
local result =
	{ ok = true, clients = count(ready), reports = received, engine = "Roblox Studio actual multiplayer", errors = {} }
for _, p in Players:GetPlayers() do
	local r = received[p.UserId]
	if not r or not r.active or not r.results or r.players ~= args.players or r.segments < 1 then
		result.ok = false
		table.insert(result.errors, "Missing client proof: " .. p.Name)
	end
end
local probe = game.ServerScriptService.TrailWars.MatchProbe
result.server = probe:Invoke("Snapshot")
if result.server.state.phase ~= "Results" then
	result.ok = false
	table.insert(result.errors, "Server not finalized")
end
STS:EndTest(result)
