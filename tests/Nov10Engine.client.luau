--!strict
local RS = game.ReplicatedStorage
local report = RS:WaitForChild("Nov10TestReport", 25)
if not report then
	return
end
local gui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TrailWarsGameplay")
local probe = gui:WaitForChild("GameplayProbe")
report:FireServer("Ready")
while not RS:GetAttribute("Nov10Start") do
	task.wait(0.05)
end
probe:Invoke("Start")
local me = "u" .. game.Players.LocalPlayer.UserId
local a = RS:GetAttribute("Nov10A")
local b = RS:GetAttribute("Nov10B")
local result = {
	active = false,
	intermission = false,
	final = false,
	projectiles = false,
	jumpVisible = false,
	rounds = 0,
	controls = true,
	rematch = false,
}
local fired = false
local rematched = false
local first = nil
local deadline = os.clock() + 85
while os.clock() < deadline do
	local s = probe:Invoke("Snapshot")
	if s then
		if not first and s.seriesId ~= "" then
			first = s.seriesId
		end
		if s.phase == "Active" then
			result.active = true
			result.rounds = math.max(result.rounds, s.series.round)
			local actor = s.powers.actors[me]
			if me == a and s.series.round == 1 and not fired then
				fired = true
				probe:Invoke("Power", "Jump")
				probe:Invoke("Power", "Jump")
				probe:Invoke("Power", "Homing")
				probe:Invoke("Power", "Homing")
			end
			if actor and actor.jumping then
				result.jumpVisible = true
			end
			if #s.powers.projectiles > 0 then
				result.projectiles = true
			end
			if me == b and actor and actor.state == "EliminatedTurret" then
				probe:Invoke("Steer", if RS:GetAttribute("Nov10Steered") then 0 else 1)
			end
		elseif s.phase == "Intermission" then
			probe:Invoke("Steer", 0)
			result.intermission = true
		elseif s.phase == "Final" then
			result.final = true
		end
		if RS:GetAttribute("Nov10Rematch") and not rematched then
			rematched = true
			probe:Invoke("Start")
		end
		if first and first ~= "" and s.seriesId ~= first then
			result.rematch = true
		end
		result.controls = gui.SafeArea.Match.Homing.AbsoluteSize.Y >= 44
			and gui.SafeArea.Match.Jump.AbsoluteSize.Y >= 44
	end
	report:FireServer(result)
	if result.rematch then
		break
	end
	task.wait(0.08)
end
report:FireServer(result)
