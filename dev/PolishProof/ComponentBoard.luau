--!strict
-- UI Labs component proof; scrolling belongs to this workbench, never Home.
local Kit = require(script.Parent.Components)
local Board = {}
function Board.mount(target: Instance, options: any?)
	local opts = options or {}
	local scope = Kit.new(opts.reducedMotion)
	local root = Instance.new("ScrollingFrame")
	root.Name = "ComponentWorkbench"
	root.BackgroundColor3 = Kit.colors.mint
	root.BorderSizePixel = 0
	root.Size = UDim2.fromScale(1, 1)
	root.CanvasSize = UDim2.new()
	root.AutomaticCanvasSize = Enum.AutomaticSize.Y
	root.ScrollBarThickness = 4
	root.Parent = target
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 16)
	pad.PaddingBottom = UDim.new(0, 24)
	pad.PaddingLeft = UDim.new(0, 16)
	pad.PaddingRight = UDim.new(0, 16)
	pad.Parent = root
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 14)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = root
	local count = 0
	local function row(object: GuiObject, height: number)
		count += 1
		object.LayoutOrder = count
		object.Size = UDim2.new(1, -6, 0, height)
	end
	row(Kit.text(root, "Title", "SNAP ARCADE · COMPONENT PROOF", 24), 76)
	local status = Kit.text(root, "Status", "Interact with the controls", 18)
	local function report(value: string)
		status.Text = value
	end
	for _, spec in
		{
			{ "Primary", true, "Default" },
			{ "Secondary", false, "Default" },
			{ "Selected", false, "Selected" },
			{ "Disabled", false, "Disabled" },
			{ "Loading", true, "Loading" },
		}
	do
		local b = scope:button(root, spec[1], string.upper(spec[1]), spec[2], function()
			report(spec[1] .. " activated")
		end)
		b:setState(spec[3])
		row(b.root, 64)
	end
	row(Kit.currency(root, 480), 62)
	local card = Kit.panel(root, "CosmeticCard")
	row(card, 148)
	local ring = Kit.panel(card, "Ring")
	ring.BackgroundColor3 = Kit.colors.blue
	Kit.round(ring, 99)
	Kit.box(ring, { 18, 20, 60, 60 })
	local hole = Kit.frame(ring, "Hole", Kit.colors.paper)
	Kit.round(hole, 99)
	Kit.box(hole, { 14, 14, 32, 32 })
	local title = Kit.text(card, "ItemName", "RING CORE", 23)
	title.Position = UDim2.fromOffset(92, 12)
	title.Size = UDim2.new(1, -104, 0, 54)
	local state = Kit.text(card, "Ownership", "PREVIEW · 150 COINS", 17)
	state.Position = UDim2.fromOffset(12, 92)
	state.Size = UDim2.new(1, -24, 0, 38)
	local tabs = Kit.frame(root, "Tabs")
	row(tabs, 60)
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(1 / 3, -8, 1, -4)
	grid.CellPadding = UDim2.fromOffset(8, 0)
	grid.Parent = tabs
	local tabButtons = {}
	for i, name in { "ALL", "CORES", "TRAILS" } do
		local tab = scope:button(tabs, name, name, false, function()
			for _, button in tabButtons do
				button:setState(if button.root.Name == name then "Selected" else "Default")
			end
			report("Tab: " .. name)
		end)
		tab.root.LayoutOrder = i
		tab.label.TextSize = 16
		table.insert(tabButtons, tab)
	end
	tabButtons[1]:setState("Selected")
	local enabled = opts.reducedMotion == true
	local setting: any
	setting = scope:button(root, "ReducedMotion", "REDUCED MOTION", false, function()
		enabled = not enabled
		scope.reducedMotion = enabled
		setting:setState(if enabled then "Selected" else "Default")
		report("Reduced motion: " .. (if enabled then "ON" else "OFF"))
	end)
	row(setting.root, 64)
	row(status, 60)
	return function()
		scope:destroy()
		root:Destroy()
	end
end
return Board
