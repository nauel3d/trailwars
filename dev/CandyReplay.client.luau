--!strict
-- Standalone, labelled deterministic engine replay. No remotes, storage or real match results.
local RS = game.ReplicatedStorage
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
local Replay = require(RS.TrailWars.CandyReplay)
local model = Replay.new()
local t: any = { selfId = "comet", reset = true, state = model:snapshot(), paused = false, cursor = 0, clock = 0 }
function t:send(_action, _turn, _slot, _settings) end
function t:join()
	self.wanted = true
	self.reset = true
	self.cursor = 0
end
function t:leave()
	self.wanted = false
end
function t:step(dt, _turn)
	if not self.paused then
		self.clock = math.min(self.clock + dt, 0.2)
		while self.clock >= 0.02 do
			self.clock -= 0.02
			model:step()
		end
	end
	self.state = model:snapshot()
end
function t:drain()
	local out = {}
	for i = self.cursor + 1, #model.round.sim.index.segments do
		out[#out + 1] = model.round.sim.index.segments[i]
	end
	self.cursor = #model.round.sim.index.segments
	return out
end
function t:destroy() end
local before = RS:GetAttribute("CandyBaseline") == true
local approved = RS:GetAttribute("CandyApproved") == true
local app = require(
	if before
		then RS.TrailWarsUI.CandyBaselineApp
		elseif approved then RS.TrailWarsUI.CandyApprovedApp
		else RS.TrailWarsUI.PlaytestApp
)
local proof = app.mount(game.Players.LocalPlayer:WaitForChild("PlayerGui"), RS.TrailWarsDev, t)
proof.start()
local note = Instance.new("TextLabel")
note.Name = "ReplayNotice"
note.Text = "ENGINE REPLAY · " .. (if before then "BEFORE / bbd39c7" else "CANDY COMET / ART REVIEW")
note.BackgroundTransparency = 1
note.TextColor3 = Color3.fromRGB(25, 42, 70)
note.Font = Enum.Font.FredokaOne
note.TextSize = 11
note.Size = UDim2.new(1, 0, 0, 16)
note.Position = UDim2.new(0, 0, 1, -16)
note.Parent = proof.gui
local probe = Instance.new("BindableFunction")
local artBoard = nil
local take = 0
probe.Name = "CandyReplayProbe"
probe.Parent = proof.gui
probe.OnInvoke = function(action, value)
	if action == "Lifecycle" then
		local counts = {}
		for i = 1, 5 do
			model = Replay.new()
			take += 1
			model.round.matchId = "lifecycle" .. take
			model.powers.roundId = model.round.matchId
			for _ = 1, 500 do
				model:step()
			end
			t.cursor, t.clock, t.reset, t.paused = 0, 0, true, true
			task.wait(0.3)
			local paths, rockets, effects = 0, 0, 0
			for _, x in proof.gui:GetDescendants() do
				if x:IsA("Path2D") then
					paths += 1
				end
				if x:IsA("Frame") and x.Name == "Rocket" then
					rockets += 1
				end
				if x:IsA("Frame") and x.Name:match("^Impact%d+$") and x.Visible then
					effects += 1
				end
			end
			counts[i] = {
				paths = paths,
				rockets = rockets,
				effects = effects,
				descendants = #proof.gui:GetDescendants(),
				segments = proof.gui:GetAttribute("Segments"),
			}
		end
		for i = 2, #counts do
			assert(
				counts[i].descendants == counts[1].descendants and counts[i].paths == counts[1].paths,
				"Repeated-round GUI growth"
			)
		end
		proof.home()
		task.wait(0.2)
		local remaining = 0
		for _, x in proof.gui.SafeArea.Match.Arena:GetChildren() do
			if x:IsA("Path2D") or x.Name == "Rocket" or x.Name:match("^Core_") then
				remaining += 1
			end
		end
		assert(remaining == 0, "Arena geometry leaked on Home")
		proof.start()
		return { rounds = counts, homeArenaObjects = remaining }
	elseif action == "Stress" then
		model = Replay.new(true)
		take += 1
		model.round.matchId = "stress-take" .. take
		model.powers.roundId = model.round.matchId
		for _ = 1, math.clamp(value or 0, 0, 1000) do
			model:step()
		end
		t.cursor, t.clock, t.reset, t.paused = 0, 0, true, true
	elseif action == "FrameProfile" then
		proof.start()
		t.paused = false
		local result = require(RS.TrailWarsUI.CandyFrameProfile)(proof.gui, value, function()
			return model:snapshot()
		end)
		t.paused = true
		return result
	elseif action == "ArtBoard" then
		if artBoard then
			artBoard:Destroy()
			artBoard = nil
		else
			artBoard = require(RS.TrailWarsUI.CandyArtBoard)(proof.gui)
			t.paused = true
		end
	elseif action == "Reduced" and proof.setReducedMotion then
		proof.setReducedMotion(value)
	elseif action == "Benchmark" then
		return require(RS.TrailWarsUI.CandyBenchmark)(proof.gui)
	elseif action == "Seek" then
		assert(type(value) == "number" and value >= 0 and value <= 3000, "Bounded replay tick required")
		model = Replay.new()
		take += 1
		model.round.matchId = "candy-review-take" .. take
		model.powers.roundId = model.round.matchId
		for _ = 1, value do
			model:step()
		end
		t.cursor, t.clock, t.reset, t.paused = 0, 0, true, true
	elseif action == "Pause" then
		t.paused = true
	elseif action == "Resume" then
		t.paused = false
	end
	local snapshot = model:snapshot()
	return {
		tick = model.tick,
		state = snapshot,
		events = model.events,
		activations = model.activations,
		segments = #model.round.sim.index.segments,
		paths = proof.gui:GetAttribute("Paths"),
		before = before,
	}
end
