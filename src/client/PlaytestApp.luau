--!strict
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Round = require(RS.TrailWars.RoundSession)
local Config = require(RS.TrailWars.GameplayConfig)
local Stepper = require(RS.TrailWars.FixedStepper)
local Layout = require(RS.TrailWars.GameplayLayout)
local Input = require(script.Parent.GameplayInput)
local Renderer = require(script.Parent.GameplayRenderer)
local App = {}
function App.mount(parent: Instance, components: Instance, transport: any?)
	local Kit = require(components.Components)
	local Home = require(components.Home)
	local Demos = require(components.Demos)
	local Board = require(script.Parent.PlaytestScoreboard)
	local Panels = require(script.Parent.PlaytestPanels)
	local Motion = require(components.Motion)
	local gui = Instance.new("ScreenGui")
	gui.Name = "TrailWarsGameplay"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.ScreenInsets = Enum.ScreenInsets.None
	gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	gui.ClipToDeviceSafeArea = false
	gui.Parent = parent
	local background = Kit.frame(gui, "Paper", Kit.colors.paper)
	background.Size = UDim2.fromScale(1, 1)
	local safe = Kit.frame(gui, "SafeArea")
	local screen = Kit.frame(safe, "Match", Kit.colors.paper)
	screen.Size = UDim2.fromScale(1, 1)
	screen.Visible = false
	local preferences = { reducedMotion = GuiService.ReducedMotionEnabled, volume = 0.22, muted = false }
	local scope = Kit.new(preferences.reducedMotion, preferences)
	local field = Kit.frame(screen, "Arena", Kit.colors.mint)
	field.ClipsDescendants = true
	Kit.round(field, 12)
	Kit.outline(field)
	local renderer = Renderer.new(field, Kit, Config)
	local clock = Kit.text(screen, "Clock", "", 20)
	local status = Kit.text(screen, "Status", "", 16)
	local center = Kit.text(screen, "Countdown", "", 54)
	center.ZIndex = 8
	center.TextStrokeColor3 = Kit.colors.paper
	center.TextStrokeTransparency = 0.2
	local board = Board.mount(screen, Kit, Motion, preferences)

	local round: any = nil
	local snapshot: any = nil
	local home: any = nil
	local demo: any = nil
	local selfId = if transport then transport.selfId else "you"
	local acc = Stepper.new(Config.Step, Config.MaxCatchupSteps, Config.MaxBacklogSeconds)
	local mode = "Home"
	local debugTurn: number? = nil
	local nextRound = 0
	local left = scope:button(screen, "Left", "◀", false, function() end)
	local right = scope:button(screen, "Right", "▶", false, function() end)
	local input = Input.new(left.root, right.root, function(value)
		transport:send("Steer", value)
	end)
	local powerButtons = {}
	for _, slot in { "Homing", "Jump" } do
		powerButtons[slot] = scope:button(screen, slot, slot, false, function()
			transport:send("Activate", nil, slot)
		end)
		powerButtons[slot].label.TextSize = 16
	end
	scope:connect(game:GetService("UserInputService").InputBegan, function(i, processed)
		if processed or not input.enabled then
			return
		end
		if i.KeyCode == Enum.KeyCode.W or i.KeyCode == Enum.KeyCode.Up or i.KeyCode == Enum.KeyCode.ButtonX then
			transport:send("Activate", nil, "Homing")
		elseif i.KeyCode == Enum.KeyCode.S or i.KeyCode == Enum.KeyCode.Down or i.KeyCode == Enum.KeyCode.ButtonY then
			transport:send("Activate", nil, "Jump")
		end
	end)
	local function clearHome()
		if home then
			home.destroy()
			home = nil
		end
		if demo then
			demo.destroy()
			demo = nil
		end
	end
	local showHome: any
	local start: any
	local back = scope:button(screen, "Home", "HOME", false, function()
		showHome()
	end)
	local replay = scope:button(screen, "Rematch", "PLAY AGAIN", true, function()
		start()
	end)
	replay.label.TextSize = 22
	local function arrange()
		local full = GuiService:GetInsetArea(Enum.ScreenInsets.None)
		local area = GuiService:GetInsetArea(Enum.ScreenInsets.CoreUISafeInsets)
		local origin = area.Min - full.Min
		Kit.box(safe, { origin.X, origin.Y, area.Width, area.Height })
		local w, h = area.Width, area.Height
		local l = Layout.compute(w, h - 54)
		l.bottom += 54
		Kit.box(field, l.field)
		Kit.box(clock, { l.pad, 0, math.max(80, w - 120), l.top })
		clock.TextXAlignment = Enum.TextXAlignment.Left
		Kit.box(back.root, { w - 100 - l.pad, 4, 100, l.top - 8 })
		back.label.TextSize = 16
		local controlW = math.clamp(w * 0.19, 64, 112)
		Kit.box(left.root, { l.pad, h - l.bottom + 8, controlW, l.bottom - 16 })
		Kit.box(right.root, { w - controlW - l.pad, h - l.bottom + 8, controlW, l.bottom - 16 })
		Kit.box(status, { controlW + l.pad + 4, h - l.bottom + 4, w - 2 * (controlW + l.pad + 4), l.bottom - 8 })
		Kit.box(center, { l.field[1] + 4, l.field[2] + l.field[4] * 0.3, l.field[3] - 8, l.field[4] * 0.4 })
		Kit.box(board.root, { w - l.side + l.pad, l.top, l.side - 2 * l.pad, 180 })
		Kit.box(replay.root, { math.max(8, (w - 200) / 2), h - 60, math.min(200, w - 16), 48 })
		for i, slot in { "Homing", "Jump" } do
			Kit.box(powerButtons[slot].root, { l.pad + (i - 1) * (w / 2), h - 132, w / 2 - l.pad * 2, 48 })
		end
		left.root.Position = UDim2.fromOffset(l.pad, h - 76)
		left.root.Size = UDim2.fromOffset(controlW, 64)
		right.root.Position = UDim2.fromOffset(w - controlW - l.pad, h - 76)
		right.root.Size = UDim2.fromOffset(controlW, 64)
		Kit.box(status, { controlW + l.pad + 4, h - 78, w - 2 * (controlW + l.pad + 4), 66 })
	end
	showHome = function()
		mode = "Home"
		screen.Visible = false
		input.enabled = false
		input:clear()
		debugTurn = nil
		if transport then
			transport:leave()
		end
		round = nil
		snapshot = nil
		renderer:reset()
		clearHome()
		home = Home.mount(safe, {
			preferences = preferences,
			coins = 0,
			navigate = function(route)
				if route == "PLAY" then
					start()
				elseif route == "PROFILE" or route == "SETTINGS" then
					clearHome()
					mode = "Panel"
					demo = Panels.mount(safe, Kit, transport, route, showHome, preferences)
					demo.update(transport.lobby or transport.state)
				else
					clearHome()
					demo = Demos.mount(safe, route, {
						preferences = preferences,
						close = showHome,
						navigate = function(nextRoute)
							if nextRoute == "PLAY" then
								start()
							else
								showHome()
							end
						end,
					})
				end
			end,
		})
	end
	start = function()
		clearHome()
		mode = "Match"
		screen.Visible = true
		input:clear()
		debugTurn = nil
		renderer:reset()
		acc = Stepper.new(Config.Step, Config.MaxCatchupSteps, Config.MaxBacklogSeconds)
		if transport then
			transport:join()
		else
			nextRound += 1
			round = Round.new({
				{ id = "you", name = "YOU" },
				{ id = "blue", name = "BLUE", isBot = true },
				{ id = "sun", name = "SUN", isBot = true },
				{ id = "mint", name = "MINT", isBot = true },
			}, nil, "practice-" .. nextRound)
		end
		arrange()
	end
	local function paint(state: any)
		snapshot = state
		renderer:roster(state.players)
		if round then
			local delta = {}
			for i = renderer.consumed + 1, #round.sim.index.segments do
				table.insert(delta, round.sim.index.segments[i])
			end
			renderer:append(delta)
		end
		renderer:draw(state.players)
		local me: any = nil
		local alive = 0
		for _, p in state.players do
			if p.id == selfId then
				me = p
			end
			if p.alive then
				alive += 1
			end
		end
		local active = state.phase == "Active"
		local results = state.phase == "Final"
		local intermission = state.phase == "Intermission"
		local actor = state.powers and state.powers.actors[selfId]
		input.enabled = active and me ~= nil and (me.alive or actor and actor.state == "EliminatedTurret")
		if not input.enabled then
			input:clear()
		end
		replay.root.Visible = results
		left.root.Visible = not results and not intermission
		right.root.Visible = left.root.Visible
		status.Visible = not results and not intermission
		status.Text = if state.phase == "Queue"
			then "FINDING PLAYERS · BOTS FILL TO FOUR"
			elseif state.phase == "Countdown" then "A/D · ARROWS · HOLD TO TURN"
			elseif actor and actor.state == "EliminatedTurret" then "ROCKET CONTROL\nHOLD ◀ / ▶ TO STEER"
			elseif me and not me.alive then "ELIMINATED · SPECTATING"
			elseif not me then "SPECTATING · NEXT ROUND QUEUED"
			else "RELEASE = STRAIGHT\nBOTH = STRAIGHT"
		local score = 0
		if state.series then
			for _, p in state.series.players do
				if p.id == selfId then
					score = p.score
				end
			end
		end
		clock.Text = string.format(
			"ROUND %d · SCORE %d / %d · %d ALIVE",
			if state.series then state.series.round else 0,
			score,
			state.settings.target,
			alive
		)
		clock.TextSize = if safe.AbsoluteSize.X < 500 then 14 else 18
		center.Text = if state.phase == "Queue"
			then "FINDING PLAYERS…"
			elseif state.phase == "Countdown" then tostring(state.remaining)
			else ""
		local large = results or intermission
		board.root.Visible = large or (safe.AbsoluteSize.X >= 700 and safe.AbsoluteSize.Y >= 500)
		if large then
			local w, h = safe.AbsoluteSize.X, safe.AbsoluteSize.Y
			local bw = math.min(w - 24, 540)
			local bh = math.min(h - 134, 340)
			Kit.box(board.root, { (w - bw) / 2, 60, bw, bh })
			board.title.Text = if results
				then "MATCH FINAL · " .. (if state.series and table.find(state.series.winnerIds, selfId)
					then "YOU WIN!"
					else "PLACEMENTS")
				else "ROUND COMPLETE · NEXT IN " .. state.intermission
		else
			Kit.box(board.root, { safe.AbsoluteSize.X - 184, 60, 168, 230 })
			board.title.Text = "SCORES"
		end
		if state.series then
			board.set(state.series.players, state.series.ledger, large)
		end
		for slot, button in powerButtons do
			button.root.Visible = not large
			local cooldown = if actor then actor[slot] else 0
			button.label.Text = string.upper(slot)
				.. (if cooldown > 0 then string.format(" · %.1fs", cooldown) else " · READY")
			local enabled = active and me and me.alive and cooldown <= 0
			button.root.Active = enabled == true
			button.root.Selectable = enabled == true
			button.face.BackgroundColor3 = if enabled then Kit.colors.mint else Kit.colors.paper
			button.label.TextTransparency = if enabled then 0 else 0.4
		end
		renderer:projectiles(state.powers.projectiles)

		gui:SetAttribute("Phase", state.phase)
		gui:SetAttribute("Tick", state.tick)
		gui:SetAttribute("Segments", renderer.consumed)
		gui:SetAttribute("Paths", renderer.pathCount)
	end
	scope:connect(RunService.Heartbeat, function(dt)
		if mode == "Panel" and demo and demo.update then
			demo.update(transport.lobby or transport.state)
		end
		if mode ~= "Match" then
			return
		end
		if round then
			round.inputs[selfId] = debugTurn or input:value()
			acc:advance(dt, function()
				Round.step(round)
			end)
			paint(Round.snapshot(round))
		elseif transport then
			transport:step(dt, debugTurn or input:value())
			if transport.state then
				if transport.reset then
					renderer:reset()
					transport.reset = false
				end
				renderer:roster(transport.state.players)
				renderer:append(transport:drain())
				paint(transport.state)
			else
				center.Text = "FINDING A ROUND…"
			end
		end
	end)
	scope:connect(gui:GetPropertyChangedSignal("AbsoluteSize"), arrange)
	scope:connect(GuiService:GetPropertyChangedSignal("TopbarInset"), arrange)
	scope:connect(GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"), function()
		preferences.reducedMotion = GuiService.ReducedMotionEnabled
	end)
	arrange()
	showHome()
	return {
		gui = gui,
		start = start,
		home = showHome,
		snapshot = function()
			return snapshot
		end,
		steer = function(value)
			assert(value == nil or value == -1 or value == 0 or value == 1, "Turn must be -1, 0 or 1")
			debugTurn = value
			transport:send("Steer", value or 0)
		end,
		destroy = function()
			input:destroy()
			scope:destroy()
			board.destroy()
			renderer:destroy()
			clearHome()
			if transport then
				transport:destroy()
			end
			gui:Destroy()
		end,
	}
end
return App
