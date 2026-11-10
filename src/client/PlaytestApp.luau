--!strict
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Round = require(RS.TrailWars.RoundSession)
local Config = require(RS.TrailWars.GameplayConfig)
local Stepper = require(RS.TrailWars.FixedStepper)
local Layout = require(RS.TrailWars.CandyLayout)
local Input = require(script.Parent.GameplayInput)
local Renderer = require(script.Parent.CandyCometRenderer)
local Presentation = require(script.Parent.MatchPresentation)
local PowerDefs = require(RS.TrailWars.PowerDefinitions)
local App = {}
function App.mount(parent: Instance, components: Instance, transport: any?)
	-- This is a 2D game: unrelated avatar fall damage must not flash over the arena.
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
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
	local fieldShadow = Kit.frame(screen, "BoardShadow", Kit.colors.ink)
	Kit.round(fieldShadow, 18)
	local fieldFrame = Kit.frame(screen, "BoardFrame", Kit.colors.paper)
	Kit.round(fieldFrame, 18)
	Kit.outline(fieldFrame, Kit.colors.ink, 2)
	local field = Kit.frame(screen, "Arena", Color3.fromRGB(233, 247, 237))
	field.ClipsDescendants = true
	Kit.round(field, 4)
	Kit.outline(field, Kit.colors.ink, 1)
	local renderer = Renderer.new(
		field,
		Kit,
		Config,
		{ selfId = if transport then transport.selfId else "you", preferences = preferences }
	)
	local Art = require(script.Parent.CandyCometArt)
	local pilot = Kit.frame(screen, "PilotCard", Kit.colors.mint)
	Kit.round(pilot, 18)
	local portrait = Kit.frame(pilot, "Portrait")
	portrait.Size = UDim2.fromOffset(56, 56)
	portrait.Position = UDim2.fromOffset(8, 8)
	portrait.Rotation = -15
	local pilotArt = Art.core(portrait, Kit, Kit.colors.coral)
	local pilotRocket = Kit.frame(pilot, "RocketPortrait")
	pilotRocket.Size = UDim2.fromOffset(56, 38)
	pilotRocket.Position = UDim2.fromOffset(8, 20)
	Art.rocket(pilotRocket, Kit, true)
	local pilotLabel = Kit.text(pilot, "PilotLabel", "YOUR COMET\nHOMING + JUMP", 16)
	pilotLabel.Position = UDim2.fromOffset(72, 8)
	pilotLabel.Size = UDim2.new(1, -80, 1, -16)
	pilotLabel.TextXAlignment = Enum.TextXAlignment.Left
	local feedback = Kit.text(screen, "ImpactFeedback", "", 14)
	feedback.TextColor3 = Kit.colors.ink
	local clock = Kit.text(screen, "Clock", "", 20)
	local status = Kit.text(screen, "Status", "", 16)
	local center = Kit.text(screen, "Countdown", "", 54)
	center.ZIndex = 8
	center.TextStrokeColor3 = Kit.colors.paper
	center.TextStrokeTransparency = 0.2
	local board = Board.mount(screen, Kit, Motion, preferences)
	local presentation =
		Presentation.mount(screen, Kit, Motion, preferences, if transport then transport.selfId else "you", pilot)
	local layout = nil
	local uiCache = {}
	local lastUIKey = nil
	local layoutVersion, lastLayoutVersion = 0, -1
	local pilotAllowed = false
	local function write(object, property, value)
		uiCache[object] = uiCache[object] or {}
		if uiCache[object][property] ~= value then
			object[property] = value
			uiCache[object][property] = value
		end
	end

	local round: any = nil
	local snapshot: any = nil
	local home: any = nil
	local demo: any = nil
	local selfId = if transport then transport.selfId else "you"
	local acc = Stepper.new(Config.Step, Config.MaxCatchupSteps, Config.MaxBacklogSeconds)
	local mode = "Home"
	local panelClock = 0
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
		local meter = Kit.frame(powerButtons[slot].face, "ChargeTrack", Kit.colors.ink)
		meter.Position = UDim2.new(0, 8, 1, -7)
		meter.Size = UDim2.new(1, -16, 0, 3)
		Kit.round(meter, 99)
		local fill = Kit.frame(meter, "Charge", Kit.colors.blue)
		fill.Size = UDim2.fromScale(0, 1)
		Kit.round(fill, 99)
		powerButtons[slot].meter = fill
		local badge = Kit.frame(powerButtons[slot].face, "PowerBadge")
		badge.Size = UDim2.fromOffset(26, 24)
		badge.Position = UDim2.new(0, 10, 0.5, -12)
		if slot == "Homing" then
			Art.rocket(badge, Kit, false)
		else
			Kit.round(badge, 99)
			badge.BackgroundTransparency = 0
			badge.BackgroundColor3 = Kit.colors.blue
			local arrow = Kit.text(badge, "AirArrow", "↑", 22, Kit.colors.paper)
			arrow.ZIndex = 9
		end
		powerButtons[slot].label.Position = UDim2.fromOffset(42, 0)
		powerButtons[slot].label.Size = UDim2.new(1, -48, 1, 0)
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
	local skip = scope:button(screen, "SkipAnimation", "SKIP ANIMATION", false, function()
		board.skip()
	end)
	local function arrange()
		local full = GuiService:GetInsetArea(Enum.ScreenInsets.None)
		local area = GuiService:GetInsetArea(Enum.ScreenInsets.CoreUISafeInsets)
		local origin = area.Min - full.Min
		Kit.box(safe, { origin.X, origin.Y, area.Width, area.Height })
		local w, h = area.Width, area.Height
		local l = Layout.compute(w, h)
		layout = l
		layoutVersion += 1
		Kit.box(field, l.field)
		local f = l.field
		Kit.box(fieldFrame, { f[1] - 6, f[2] - 6, f[3] + 12, f[4] + 12 })
		Kit.box(fieldShadow, { f[1] - 6, f[2], f[3] + 12, f[4] + 12 })
		Kit.box(clock, l.header)
		clock.TextXAlignment = Enum.TextXAlignment.Left
		Kit.box(back.root, l.home)
		back.label.TextSize = 16
		Kit.box(left.root, l.left)
		Kit.box(right.root, l.right)
		Kit.box(status, l.status)
		status.TextSize = if l.landscape then 12 else 14
		Kit.box(feedback, l.feedback)
		feedback.Visible = not l.landscape
		pilotAllowed = l.desktop or (not l.landscape and h - 144 - (f[2] + f[4] + 44) >= 76)
		pilot.Visible = pilotAllowed
		uiCache[pilot] = nil
		if l.desktop then
			Kit.box(pilot, { l.standings[1], 380, 192, 76 })
			Kit.box(feedback, { l.standings[1], 470, 192, 70 })
		else
			Kit.box(pilot, { (w - math.min(280, w - 24)) / 2, f[2] + f[4] + 44, math.min(280, w - 24), 76 })
		end
		Kit.box(center, { l.field[1] + 4, l.field[2] + l.field[4] * 0.3, l.field[3] - 8, l.field[4] * 0.4 })
		Kit.box(board.root, l.standings)
		Kit.box(replay.root, { math.max(8, (w - 200) / 2), h - 60, math.min(200, w - 16), 48 })
		skip.root.Position = replay.root.Position
		skip.root.Size = replay.root.Size
		Kit.box(powerButtons.Homing.root, l.homing)
		Kit.box(powerButtons.Jump.root, l.jump)
		for _, button in powerButtons do
			button.label.TextSize = if w < 360 then 14 else 16
		end
		powerButtons.Homing.root.NextSelectionRight = powerButtons.Jump.root
		powerButtons.Jump.root.NextSelectionLeft = powerButtons.Homing.root
		powerButtons.Homing.root.NextSelectionDown = left.root
		powerButtons.Jump.root.NextSelectionDown = right.root
		left.root.NextSelectionRight = right.root
		right.root.NextSelectionLeft = left.root
		left.root.NextSelectionUp = powerButtons.Homing.root
		right.root.NextSelectionUp = powerButtons.Jump.root
	end
	showHome = function()
		mode = "Home"
		presentation.hide()
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
		presentation.hide()
		lastUIKey = nil
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
		renderer:events(state.roundId, state.visualEvents or {})
		write(feedback, "Text", renderer:feedback())
		renderer:projectiles(state.powers.projectiles)
		local key = tostring(state.revision) .. ":" .. tostring(state.roundId) .. ":" .. state.phase
		if key == lastUIKey and layoutVersion == lastLayoutVersion then
			return
		end
		lastUIKey, lastLayoutVersion = key, layoutVersion
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
		local localSprite = renderer.sprites[selfId]
		if localSprite then
			write(pilotArt.shell, "BackgroundColor3", localSprite.color)
			write(pilotArt.shade, "BackgroundColor3", localSprite.color:Lerp(Kit.colors.ink, 0.22))
			write(pilotArt.face, "BackgroundColor3", localSprite.color)
			write(pilotArt.rim, "BackgroundColor3", localSprite.color:Lerp(Kit.colors.paper, 0.55))
		end
		portrait.Visible = me ~= nil and me.alive
		pilotRocket.Visible = actor ~= nil and actor.state == "EliminatedTurret"
		pilotLabel.Text = if actor and actor.state == "EliminatedTurret"
			then "ROCKET PILOT\nTURN TO TAG!"
			elseif me and me.jumping then "UP & OVER!\nWALLS STILL HURT"
			elseif me and not me.alive then "NICE RUN!\nSPECTATING"
			else "YOUR COMET\nTURN. TAG. SURVIVE."
		input.enabled = active and me ~= nil and (me.alive or actor and actor.state == "EliminatedTurret")
		if not input.enabled then
			input:clear()
		end
		replay.root.Visible = results
		skip.root.Visible = intermission
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
		write(
			clock,
			"Text",
			string.format(
				"ROUND %d · %d:%02d\n%d ALIVE · SCORE %d/%d",
				if state.series then state.series.round else 0,
				math.floor(state.time / 60),
				math.floor(state.time % 60),
				alive,
				score,
				state.settings.target
			)
		)
		clock.TextSize = if safe.AbsoluteSize.X < 500 then 14 elseif safe.AbsoluteSize.Y < 500 then 16 else 22
		write(center, "Text", if state.phase == "Queue" then "FINDING PLAYERS…" else "")
		local large = results or intermission
		write(pilot, "Visible", pilotAllowed and me ~= nil and not large)
		board.root.Visible = large or (safe.AbsoluteSize.X >= 1000 and safe.AbsoluteSize.Y >= 600)
		local boardRect = presentation.update(state, me, layout.field, renderer.sprites, powerButtons)
		if large then
			Kit.box(board.root, boardRect)
			write(board.title, "Text", if results then "FINAL PLACEMENTS" else "ROUND SCORE REVEAL")
		else
			Kit.box(board.root, layout.standings)
			write(board.title, "Text", "LIVE STANDINGS")
		end
		if state.series then
			board.set(state.series.players, state.series.ledger, large, renderer.sprites, state.settings.target)
		end
		for slot, button in powerButtons do
			write(button.root, "Visible", not large)
			local cooldown = if actor then actor[slot] else 0
			local enabled = active and me and me.alive and cooldown <= 0
			local powerState = if not active
				then "Waiting"
				elseif not me or not me.alive then "Out"
				elseif cooldown > 0 then "Charging"
				else "Ready"
			if button.powerState ~= powerState then
				button.powerState = powerState
				button:setState(if enabled then "Default" else "Disabled")
				button.root:SetAttribute("PowerState", powerState)
				-- setState settles press depth, so invalidate only the overridden style keys.
				uiCache[button.face] = nil
				uiCache[button.label] = nil
			end
			write(
				button.label,
				"Text",
				string.upper(slot)
					.. "\n"
					.. (if powerState == "Charging" then string.format("%.1fs", cooldown) else string.upper(powerState))
			)
			write(
				button.face,
				"BackgroundColor3",
				if enabled then (if slot == "Jump" then Kit.colors.blue else Kit.colors.coral) else Kit.colors.paper
			)
			write(button.label, "TextColor3", if enabled then Kit.colors.paper else Kit.colors.ink)
			write(button.label, "TextTransparency", if enabled then 0 else 0.25)
			write(
				button.meter,
				"Size",
				UDim2.fromScale(math.clamp(1 - cooldown / (PowerDefs[slot].CooldownTicks / 50), 0, 1), 1)
			)
			write(button.meter, "BackgroundColor3", if enabled then Kit.colors.paper else Kit.colors.blue)
		end

		gui:SetAttribute("Phase", state.phase)
		gui:SetAttribute("Tick", state.tick)
		gui:SetAttribute("Segments", renderer.consumed)
		gui:SetAttribute("Paths", renderer.pathCount)
	end
	scope:connect(RunService.Heartbeat, function(dt)
		panelClock += dt
		if panelClock >= 0.25 and mode == "Panel" and demo and demo.update then
			panelClock = 0
			demo.update(transport.lobby or transport.state)
		end
		if mode ~= "Match" then
			return
		end
		renderer:step(dt)
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
		board.setReducedMotion(preferences.reducedMotion)
		presentation.setReduced(preferences.reducedMotion)
		lastUIKey = nil
	end)
	arrange()
	showHome()
	return {
		gui = gui,
		setReducedMotion = function(value)
			preferences.reducedMotion = value == true
			board.setReducedMotion(preferences.reducedMotion)
			presentation.setReduced(preferences.reducedMotion)
			lastUIKey = nil
		end,
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
			presentation.destroy()
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
