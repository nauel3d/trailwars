--!strict
-- Small local interaction demonstrations. No production transport is imported.
local Kit = require(script.Parent.Components)
local Motion = require(script.Parent.Motion)
local Leaderboard = require(script.Parent.Leaderboard)
local Cues = require(script.Parent.UICues)
local Demos = {}
function Demos.mount(parent: Instance, route: string, options: any?)
	local opts = options or {}
	local prefs = opts.preferences or { reducedMotion = opts.reducedMotion == true }
	local root = Kit.frame(parent, "InteractiveDemo", Kit.colors.paper)
	root.Size = UDim2.fromScale(1, 1)
	root.ClipsDescendants = true
	local motion = Motion.new(root, { preferences = prefs })
	local buttons = Kit.new(prefs.reducedMotion, prefs)
	local title = Kit.text(root, "DemoTitle", route .. " · DEMO", 26)
	title.Position = UDim2.fromOffset(108, 10)
	title.Size = UDim2.new(1, -120, 0, 52)
	local back = buttons:button(root, "Back", "‹ HOME", false, function()
		if opts.close then
			opts.close()
		end
	end)
	Kit.box(back.root, { 12, 12, 88, 52 })
	back.label.TextSize = 16
	local stage = Kit.panel(root, "CosmeticPreview")
	stage.BackgroundColor3 = Kit.colors.mint
	local core = Kit.panel(stage, "PreviewCore")
	Kit.round(core, 99)
	core.BackgroundColor3 = Kit.colors.coral
	core.AnchorPoint = Vector2.new(0.5, 0.5)
	core.ZIndex = 3
	local inner = Kit.frame(core, "RingHole", Kit.colors.mint)
	Kit.round(inner, 99)
	inner.Size = UDim2.fromScale(0.5, 0.5)
	inner.Position = UDim2.fromScale(0.25, 0.25)
	inner.Visible = false
	local label = Kit.text(stage, "PreviewName", "STARTER CORE", 22)
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.fromScale(0.5, 0.97)
	label.Size = UDim2.new(1, -12, 0, 42)
	local info = Kit.text(root, "DemoDisclosure", "LOCAL DEMO · NO LIVE CHANGES", 16)
	local list = Instance.new("ScrollingFrame")
	list.Name = "DemoItems"
	list.BorderSizePixel = 0
	list.BackgroundTransparency = 1
	list.CanvasSize = UDim2.new()
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollBarThickness = 3
	list.Parent = root
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list
	local selected = if route == "SHOP" then 2 else 1
	local equipped = 1
	local phase = "inspect"
	local transactionVersion = 0
	local outcome = true
	local itemButtons = {}
	local names = { "STARTER CORE", "RING CORE", "STARTER TRAIL", "DASHED TRAIL" }
	local owned = { true, false, true, false }
	local costs = { 0, 150, 0, 100 }
	local action: any
	local liveStatus = Kit.text(root, "DemoStatus", "Choose an item to preview", 17)
	local progress = Kit.frame(stage, "PreviewAccent", Kit.colors.blue)
	Kit.round(progress, 5)
	progress.AnchorPoint = Vector2.new(0.5, 0.5)
	progress.Position = UDim2.fromScale(0.5, 0.5)
	progress.Size = UDim2.fromOffset(36, 8)
	local particles = {}
	for i = 1, 8 do
		local p = Kit.frame(
			stage,
			"Confetti" .. i,
			({ Kit.colors.coral, Kit.colors.blue, Kit.colors.yellow })[(i - 1) % 3 + 1]
		)
		p.Size = UDim2.fromOffset(8, 14)
		p.Visible = false
		table.insert(particles, p)
	end
	local board = Leaderboard.mount(list, { demo = true, selfId = "coral", preferences = prefs })
	board.root.Name = "FinalPlacement"
	board.root.Size = UDim2.new(1, -6, 0, 144)
	board.root.LayoutOrder = 1
	board.root.Visible = route == "RESULTS"
	local generation = 0
	local function celebrate()
		generation += 1
		local current = generation
		core.Rotation = -8
		motion:to(core, { Rotation = 0 }, "settle")
		for i, p in particles do
			motion:cancel(p)
			p.Visible = not motion:isReduced() and outcome
			p.Position = UDim2.fromScale(0.5, 0.5)
			p.Rotation = i * 29
			motion:to(
				p,
				{ Position = UDim2.fromScale(0.12 + (i - 1) * 0.105, 0.13 + (i % 3) * 0.13), Rotation = i * 77 },
				"celebrate",
				function()
					if current == generation then
						p.Visible = false
					end
				end,
				function()
					p.Visible = false
				end
			)
		end
	end
	local function refresh()
		if route == "RESULTS" then
			label.Text = if outcome then "VICTORY!" else "NEXT ROUND, NEW CHANCE"
			liveStatus.Text = "DEMO RESULT · NO REWARD GRANTED"
			board.setRows({
				{ id = "coral", name = "YOU · DEMO", score = 42, finalRank = if outcome then 1 else 3 },
				{ id = "blue", name = "BOLT", score = 36, finalRank = if outcome then 2 else 1 },
				{ id = "gold", name = "SUNNY", score = 29, finalRank = if outcome then 3 else 2 },
			}, true)
			action.label.Text = "REPLAY DEMO"
			return
		end
		if route == "SETTINGS" then
			label.Text = "YOUR COMFORT, YOUR PACE"
			action.label.Text = if prefs.reducedMotion then "MOTION: REDUCED" else "MOTION: FULL"
			return
		end
		label.Text = names[selected]
		inner.Visible = selected == 2
		for i, b in itemButtons do
			b:setState(if i == selected then "Selected" else "Default")
		end
		if route == "SHOP" then
			action.label.Text = if phase == "confirm" then "SIMULATE CONFIRM" else "INSPECT ITEM"
		else
			action.label.Text = if owned[selected] then "DEMO EQUIP" else "PREVIEW ONLY"
		end
	end
	local function activate()
		Cues.play(root, "confirm", prefs)
		if route == "RESULTS" then
			outcome = not outcome
			refresh()
			celebrate()
		elseif route == "SETTINGS" then
			prefs.reducedMotion = not prefs.reducedMotion
			motion:setReducedMotion(prefs.reducedMotion)
			buttons.reducedMotion = prefs.reducedMotion
			refresh()
			liveStatus.Text = "Preview preference updated"
		elseif route == "SHOP" then
			if phase == "inspect" then
				phase = "confirm"
				liveStatus.Text = "DEMO CONFIRMATION · no charge"
			else
				phase = "pending"
				transactionVersion += 1
				local version = transactionVersion
				action:setState("Loading")
				liveStatus.Text = "SIMULATED PENDING · NO CHARGE"
				motion:after(0.55, function()
					if phase ~= "pending" or version ~= transactionVersion then
						return
					end
					phase = "inspect"
					action:setState("Default")
					liveStatus.Text = "SIMULATED SUCCESS · NO PURCHASE MADE"
					core.Rotation = -8
					motion:to(core, { Rotation = 0 }, "confirm")
					refresh()
				end)
			end
			if phase ~= "pending" then
				refresh()
			end
		elseif route == "CUSTOMIZE" then
			if owned[selected] then
				equipped = selected
				liveStatus.Text = "✓ EQUIPPED IN DEMO ONLY"
				core.Rotation = -8
				motion:to(core, { Rotation = 0 }, "confirm")
			else
				liveStatus.Text = "UNOWNED PREVIEW · no equipment changed"
			end
		else
			liveStatus.Text = "Planned screen · no matchmaking starts here"
		end
	end
	action = buttons:button(root, "PrimaryAction", "PREVIEW", true, activate)
	action.label.TextSize = 23
	if route == "CUSTOMIZE" or route == "SHOP" then
		for i, name in names do
			local text = name .. (if owned[i] then " · OWNED" else " · " .. costs[i] .. " COINS")
			local b = buttons:button(list, "Item" .. i, text, false, function()
				selected = i
				phase = "inspect"
				transactionVersion += 1
				action:setState("Default")
				liveStatus.Text = if owned[i] then "Owned demo fixture" else "Unowned preview"
				refresh()
				motion:to(
					core,
					{ BackgroundColor3 = if i % 2 == 0 then Kit.colors.blue else Kit.colors.coral },
					"select"
				)
			end)
			b.root.Size = UDim2.new(1, -6, 0, 70)
			b.root.LayoutOrder = i
			b.label.TextSize = 17
			table.insert(itemButtons, b)
		end
		if route == "SHOP" then
			local cancel = buttons:button(list, "CancelDemo", "CANCEL / SIMULATE FAILURE", false, function()
				phase = "inspect"
				liveStatus.Text = "DEMO CANCELED / NOT COMPLETED"
				refresh()
			end)
			cancel.root.Size = UDim2.new(1, -6, 0, 60)
			cancel.root.LayoutOrder = 5
			cancel.label.TextSize = 16
		end
	elseif route == "PLAY" then
		label.Text = "SEE THE FINISH"
		local results = buttons:button(list, "ResultsDemo", "RESULTS DEMO", false, function()
			if opts.navigate then
				opts.navigate("RESULTS")
			end
		end)
		results.root.Size = UDim2.new(1, -6, 0, 64)
		results.label.TextSize = 20
		action.label.Text = "NO MATCHMAKING IN DEMO"
	elseif route == "SETTINGS" then
		local sound = buttons:button(list, "SoundToggle", "SOUND ON / OFF", false, function()
			prefs.muted = not prefs.muted
			liveStatus.Text = if prefs.muted
				then "UI SOUND MUTED"
				elseif Cues.available() then "UI SOUND ON"
				else "SOUND ASSETS PENDING UPLOAD"
		end)
		sound.root.Size = UDim2.new(1, -6, 0, 64)
		sound.label.TextSize = 20
	else
		if route ~= "RESULTS" then
			label.Text = "MOTION PLAN PREVIEW"
		end
	end
	local angle = 0
	motion:loop(function(dt: number)
		angle += dt * 0.8
		core.Position = UDim2.fromScale(0.5 + math.cos(angle) * 0.14, 0.43 + math.sin(angle) * 0.10)
		progress.Rotation = math.deg(angle)
		progress.Position = UDim2.fromScale(0.5 - math.cos(angle) * 0.15, 0.43 - math.sin(angle) * 0.10)
	end, 30)
	local function arrange()
		local w, h = root.AbsoluteSize.X, root.AbsoluteSize.Y
		local compact = w > h
		local bottom = h - 106
		local bodyH = math.max(60, bottom - 90)
		if w >= 900 or compact then
			local pw = math.min(w * 0.44, 500)
			Kit.box(stage, { 12, 78, pw - 18, bodyH })
			Kit.box(list, { pw + 12, 78, w - pw - 24, bodyH })
		else
			local ph = math.min(190, bodyH * 0.44)
			Kit.box(stage, { 12, 78, w - 24, ph })
			Kit.box(list, { 12, ph + 88, w - 24, math.max(48, bodyH - ph - 10) })
		end
		Kit.box(action.root, { 16, h - 76, w - 32, 62 })
		Kit.box(liveStatus, { 16, h - 116, w - 32, 36 })
		info.Visible = h >= 650
		Kit.box(info, { 12, bodyH + 82, w - 24, 30 })
		local s = math.clamp(math.min(stage.AbsoluteSize.X, stage.AbsoluteSize.Y) * 0.28, 26, 100)
		core.Size = UDim2.fromOffset(s, s)
		core.Position = UDim2.fromScale(0.5, 0.43)
		label.TextSize = if stage.AbsoluteSize.Y < 170 then 16 else 22
		if route == "RESULTS" then
			board.setRows({
				{ id = "coral", name = "YOU · DEMO", score = 42, finalRank = if outcome then 1 else 3 },
				{ id = "blue", name = "BOLT", score = 36, finalRank = if outcome then 2 else 1 },
				{ id = "gold", name = "SUNNY", score = 29, finalRank = if outcome then 3 else 2 },
			}, true)
		end
	end
	motion:connect(root:GetPropertyChangedSignal("AbsoluteSize"), arrange)
	root.Position = UDim2.fromOffset(0, 8)
	motion:to(root, { Position = UDim2.new() }, "enter")
	refresh()
	task.defer(arrange)
	if route == "RESULTS" then
		celebrate()
	end
	return {
		root = root,
		action = action,
		select = function(i: number)
			selected = i
			refresh()
		end,
		equipped = function()
			return equipped
		end,
		destroy = function()
			generation += 1
			board.destroy()
			motion:destroy()
			buttons:destroy()
			root:Destroy()
		end,
	}
end
return Demos
