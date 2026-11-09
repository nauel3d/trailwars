--!strict
local Kit = require(script.Parent.Components)
local Layout = require(script.Parent.Layout)
local GuiService = game:GetService("GuiService")
local Home = {}
local Demos = require(script.Parent.Demos)
local C = Kit.colors
function Home.mount(parent: Instance, options: any?)
	local opts = options or {}
	local scope = Kit.new(opts.reducedMotion, opts.preferences)
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
	local arena = require(script.Parent.AnimatedArena).mount(hero, opts)
	local modal: Frame? = nil
	local activeDemo: any = nil
	local previous: GuiObject? = nil
	local buttons = {}
	local function close()
		if activeDemo then
			activeDemo.destroy()
			activeDemo = nil
			modal = nil
		end
		content.Visible = true
		arena.setActive(true)

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
		content.Visible = false
		arena.setActive(false)
		activeDemo = Demos.mount(
			root,
			route,
			{ preferences = opts.preferences, reducedMotion = opts.reducedMotion, close = close, navigate = open }
		)
		modal = activeDemo.root
		GuiService.SelectedObject = activeDemo.root:FindFirstChild("Back") :: GuiButton
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
		arena.arrange()
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
			arena.destroy()
			scope:destroy()
			root:Destroy()
		end,
	}
end
return Home
