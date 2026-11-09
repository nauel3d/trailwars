--!strict
local Kit = require(script.Parent.Components)
local Layout = require(script.Parent.Layout)
local GuiService = game:GetService("GuiService")
local Home = {}
local C = Kit.colors
local function curve(a: Vector2, b: Vector2, c: Vector2, d: Vector2, t: number): Vector2
	return a * (1 - t) ^ 3 + b * (3 * (1 - t) ^ 2 * t) + c * (3 * (1 - t) * t ^ 2) + d * t ^ 3
end
local function derivative(a: Vector2, b: Vector2, c: Vector2, d: Vector2, t: number): Vector2
	return (b - a) * (3 * (1 - t) ^ 2) + (c - b) * (6 * (1 - t) * t) + (d - c) * (3 * t ^ 2)
end
function Home.mount(parent: Instance, options: any?)
	local opts = options or {}
	local scope = Kit.new(opts.reducedMotion)
	local root = Kit.frame(parent, "SnapArcadeProof", C.paper)
	root.Size = UDim2.fromScale(1, 1)
	root.ClipsDescendants = true
	local wash = Kit.frame(root, "MintWash", C.mint)
	wash.Rotation = -22
	wash.Size = UDim2.fromScale(0.7, 0.9)
	wash.Position = UDim2.fromScale(-0.32, -0.42)
	local floor = Kit.frame(root, "MintFooter", C.mint)
	floor.Size = UDim2.fromScale(1.2, 0.15)
	floor.Position = UDim2.fromScale(-0.1, 0.92)
	floor.Rotation = 2
	local content = Kit.frame(root, "Content")
	content.Size = UDim2.fromScale(1, 1)
	local logo = Kit.frame(content, "Wordmark")
	local logoArt = Instance.new("ImageLabel")
	logoArt.Name = "OriginalWordmark"
	logoArt.BackgroundTransparency = 1
	logoArt.Image = "rbxassetid://91226746983685"
	logoArt.ScaleType = Enum.ScaleType.Fit
	logoArt.Size = UDim2.fromScale(1, 0.8)
	logoArt.Parent = logo
	local badge = Kit.frame(logo, "ArcadeBadge", C.blue)
	Kit.round(badge, 8)
	badge.Position = UDim2.fromScale(0.08, 0.78)
	badge.Size = UDim2.fromScale(0.84, 0.2)
	local badgeLabel = Kit.text(badge, "Label", "SNAP ARCADE", 14, C.paper)
	local currency = Kit.currency(content, opts.coins or 480)
	local balanceLabel = currency:FindFirstChild("Balance") :: TextLabel
	local heading = Kit.text(content, "Heading", "LAST CORE STANDING", 34)
	local hero = Kit.frame(content, "TrailIllustration")
	local paths = {}
	for i, color in { C.blue, C.coral, C.yellow } do
		local border = Instance.new("Path2D")
		border.Name = "Path" .. i .. "Outline"
		border.Color3 = C.ink
		border.ZIndex = 1
		border.Parent = hero
		local fill = Instance.new("Path2D")
		fill.Name = "Path" .. i .. "Color"
		fill.Color3 = color
		fill.ZIndex = 2
		fill.Parent = hero
		local core = Kit.panel(hero, "Core" .. i)
		core.BackgroundColor3 = C.paper
		Kit.round(core, 99)
		core.AnchorPoint = Vector2.new(0.5, 0.5)
		local center = Kit.frame(core, "Color", color)
		center.Size = UDim2.new(1, -10, 1, -10)
		center.Position = UDim2.fromOffset(5, 5)
		Kit.round(center, 99)
		core.ZIndex = 3
		table.insert(paths, { border = border, fill = fill, core = core })
	end
	local you = Kit.panel(hero, "YouBadge")
	Kit.text(you, "Label", "YOU", 19)
	local modal: Frame? = nil
	local modalScope: any = nil
	local previous: GuiObject? = nil
	local buttons = {}
	local function close()
		if modalScope then
			modalScope:destroy()
			modalScope = nil
		end
		if modal then
			modal:Destroy()
			modal = nil
		end
		for _, control in buttons do
			control.root.Selectable = true
		end
		if previous and previous.Parent then
			GuiService.SelectedObject = previous
		end
	end
	local function open(route: string)
		close()
		root:SetAttribute("LastDestination", route)
		if opts.navigate then
			opts.navigate(route)
			return
		end
		previous = GuiService.SelectedObject
		for _, control in buttons do
			control.root.Selectable = false
		end
		modalScope = Kit.new(opts.reducedMotion)
		modal = Kit.frame(root, "ProofDialog", C.ink)
		modal.BackgroundTransparency = 0.25
		modal.Size = UDim2.fromScale(1, 1)
		local shield = Instance.new("TextButton")
		shield.Name = "InputShield"
		shield.Text = ""
		shield.Modal = true
		shield.BackgroundTransparency = 1
		shield.Size = UDim2.fromScale(1, 1)
		shield.Selectable = false
		shield.Parent = modal
		local panel = Kit.panel(modal, "Dialog")
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
		panel.Position = UDim2.fromScale(0.5, 0.5)
		panel.Size = UDim2.new(1, -32, 0, 260)
		local max = Instance.new("UISizeConstraint")
		max.MaxSize = Vector2.new(520, 400)
		max.Parent = panel
		local title = Kit.text(panel, "Title", route, 28)
		title.Position = UDim2.fromOffset(12, 16)
		title.Size = UDim2.new(1, -24, 0, 44)
		local copy =
			Kit.text(panel, "Explanation", "Component proof only. Remaining screens wait for visual approval.", 18)
		copy.Position = UDim2.fromOffset(20, 76)
		copy.Size = UDim2.new(1, -40, 0, 70)
		local back = modalScope:button(panel, "Close", "BACK", false, close)
		back.root.Position = UDim2.new(0, 20, 1, -80)
		back.root.Size = UDim2.new(1, -40, 0, 60)
		GuiService.SelectedObject = back.root
	end
	local play = scope:button(content, "Play", "PLAY  ▶", true, function()
		open("PLAY")
	end)
	table.insert(buttons, play)
	for _, name in { "CUSTOMIZE", "SHOP", "PROFILE", "SETTINGS" } do
		table.insert(
			buttons,
			scope:button(content, name, name, false, function()
				open(name)
			end)
		)
	end
	local function arrange()
		if not root.Parent or root.AbsoluteSize.X < 1 then
			return
		end
		local l = Layout.home(root.AbsoluteSize.X, root.AbsoluteSize.Y, opts.textScale or 1)
		root:SetAttribute("LayoutMode", l.mode)
		Kit.box(logo, l.logo)
		badgeLabel.TextSize = math.min(16, l.logo[3] * 0.084)
		Kit.box(currency, l.currency)
		balanceLabel.TextSize = (if l.mode == "Portrait" then 16 else 20) * l.textScale
		Kit.box(heading, l.heading)
		heading.Visible = l.showHeading
		heading.TextSize = l.headingSize
		Kit.box(play.root, l.play)
		play.label.TextSize = l.playSize
		for i = 1, 4 do
			Kit.box(buttons[i + 1].root, l.nav[i])
			buttons[i + 1].label.TextSize = l.navSize
		end
		hero.Visible = l.showPreview
		if not l.showPreview then
			return
		end
		Kit.box(hero, l.preview)
		local w, h = l.preview[3], l.preview[4]
		local specs = {
			{ Vector2.new(0.02, 0.33), Vector2.new(0.35, 0.36), Vector2.new(0.12, -0.05), Vector2.new(0.66, 0.16) },
			{ Vector2.new(0.05, 0.87), Vector2.new(0.62, 0.47), Vector2.new(0.06, 0.25), Vector2.new(0.88, 0.57) },
			{ Vector2.new(0.22, 0.92), Vector2.new(0.58, 0.55), Vector2.new(0.55, 0.96), Vector2.new(0.90, 0.80) },
		}
		local thickness = math.clamp(w * 0.029, 7, 23)
		for i, path in paths do
			local spec = specs[i]
			local points = {}
			for step = 0, 16 do
				local t = step / 16
				local p = curve(spec[1], spec[2], spec[3], spec[4], t)
				local tangent = derivative(spec[1], spec[2], spec[3], spec[4], t) / 48
				table.insert(
					points,
					Path2DControlPoint.new(
						UDim2.fromScale(p.X, p.Y),
						UDim2.fromScale(-tangent.X, -tangent.Y),
						UDim2.fromScale(tangent.X, tangent.Y)
					)
				)
			end
			path.border:SetControlPoints(points)
			path.border.Thickness = thickness + 3
			path.fill:SetControlPoints(points)
			path.fill.Thickness = thickness
			local endpoint = spec[4] * Vector2.new(w, h)
			local size = math.clamp(w * 0.08, 26, 64)
			path.core.Position = UDim2.fromOffset(endpoint.X, endpoint.Y)
			path.core.Size = UDim2.fromOffset(size, size)
		end
		local endpoint = specs[2][4] * Vector2.new(w, h)
		Kit.box(you, { endpoint.X - 33, endpoint.Y - math.clamp(w * 0.04, 13, 32) - 46, 66, 34 })
	end
	scope:connect(root:GetPropertyChangedSignal("AbsoluteSize"), arrange)
	scope:connect(game:GetService("UserInputService").InputBegan, function(input: InputObject, processed: boolean)
		if modal and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
			close()
		elseif not processed and not modal and input.KeyCode == Enum.KeyCode.Return then
			play:activate()
		end
	end)
	task.defer(arrange)
	return {
		root = root,
		buttons = buttons,
		arrange = arrange,
		close = close,
		destroy = function()
			close()
			scope:destroy()
			root:Destroy()
		end,
	}
end
return Home
