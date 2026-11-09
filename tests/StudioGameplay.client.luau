--!strict
local RS = game:GetService("ReplicatedStorage")
local report = RS:WaitForChild("GameplayTestReport", 20)
if not report then
	return
end
local gui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TrailWarsGameplay")
local probe = gui:WaitForChild("GameplayProbe")
report:FireServer("Ready")
while not RS:GetAttribute("GameplayTestStart") do
	task.wait(0.05)
end
probe:Invoke("Start")
report:FireServer({ started = true, stamp = os.clock() })
local info = {
	active = false,
	results = false,
	players = 0,
	segments = 0,
	maxPaths = 0,
	matchId = "",
	viewport = tostring(gui.AbsoluteSize),
}
local resynced = false
local started = os.clock()
while os.clock() - started < 20 do
	local s = probe:Invoke("Snapshot")
	if s then
		if s.phase == "Active" then
			info.active = true
			if not resynced and s.time > 1 then
				probe:Invoke("Resync")
				resynced = true
			end
			probe:Invoke("Steer", if math.floor((os.clock() - started) * 2) % 2 == 0 then 1 else 0)
		end
		info.players = math.max(info.players, #s.players)
		info.segments = math.max(info.segments, (s.segmentCount or 0))
		info.maxPaths = math.max(info.maxPaths, gui:GetAttribute("Paths") or 0)
		info.matchId = s.matchId
		if s.phase == "Results" then
			info.results = true
			info.renderedSegments = gui:GetAttribute("Segments")
			info.resynced = resynced
			if info.renderedSegments == s.segmentCount then
				break
			end
		end
	end
	report:FireServer(info)
	task.wait(0.1)
end
report:FireServer(info)
