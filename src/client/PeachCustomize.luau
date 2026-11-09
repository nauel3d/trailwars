--!strict
-- Appearance only. Catalog, purchases and ownership remain in the existing App.
local Assets = require(script.Parent.PeachAssets)
local Catalog = require(game:GetService("ReplicatedStorage"):WaitForChild("TrailWars").Catalog)
local Peach = {}
local CREAM = Color3.fromRGB(255, 241, 218)
local PLUM = Color3.fromRGB(61, 27, 57)
local ORANGE = Color3.fromRGB(228, 77, 5)
local TEAL = Color3.fromRGB(0, 220, 190)

function Peach.mount(parent: Instance, options: any)
	local W = options.widgets
	local profile = options.profile
	local scaleText = if profile then profile.settings.textScale else 1
	local stage = Instance.new("Frame")
	stage.Name = "ApprovedCustomize"
	stage.Size = UDim2.fromScale(1, 1)
	stage.BackgroundColor3 = Color3.fromRGB(255, 208, 167)
	stage.BorderSizePixel = 0
	stage.Parent = parent
	stage:SetAttribute("PageKind", options.page or "Customize")
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "ResponsiveContent"
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 5
	scroll.ScrollingEnabled = false
	scroll.ScrollBarThickness = 0
	scroll.CanvasSize = UDim2.new()
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.Parent = stage
	local canvas = Instance.new("Frame")
	canvas.Name = "LayeredCanvas"
	canvas.BackgroundTransparency = 1
	canvas.Size = UDim2.fromOffset(1672, 941)
	canvas.Parent = scroll
	local scaler = Instance.new("UIScale")
	scaler.Parent = canvas
	local layout: { [GuiObject]: { number } } = {}
	local selected = if options.initialSelection == "trail_dashed" then "trail_dashed" else "core_ring"
	local selectedButton: TextButton? = nil
	local function rect(object: GuiObject, x: number, y: number, width: number, height: number)
		object.Position = UDim2.fromOffset(x, y)
		object.Size = UDim2.fromOffset(width, height)
		layout[object] = { x, y, width, height }
	end
	local function art(target: Instance, name: string, key: string): ImageLabel
		local image = Instance.new("ImageLabel")
		image.Name = name
		image.BackgroundTransparency = 1
		local asset = Assets[key]
		image.Image = asset.image
		if asset.slice then
			image.ScaleType = Enum.ScaleType.Slice
			image.SliceCenter = Rect.new(table.unpack(asset.slice))
			image.SliceScale = asset.sliceScale or 1
		else
			image.ScaleType = Enum.ScaleType.Stretch
		end
		image.Parent = target
		return image
	end
	local function label(target: Instance, name: string, text: string, size: number, color: Color3?): TextLabel
		local value = Instance.new("TextLabel")
		value.Name = name
		value.BackgroundTransparency = 1
		value.Text = text
		value.Font = Enum.Font.FredokaOne
		value.TextSize = size * scaleText
		value.TextColor3 = color or CREAM
		value.TextWrapped = true
		value.Parent = target
		return value
	end
	local function raisedText(target: Instance, text: string, size: number, color: Color3?, dark: boolean?)
		local shadow = label(target, "TypeShadow", text, size, if dark then CREAM else PLUM)
		shadow.Position = UDim2.fromOffset(0, 3)
		shadow.Size = UDim2.fromScale(1, 1)
		shadow.TextTransparency = 0.24
		local value = label(target, "Label", text, size, color)
		value.Size = UDim2.fromScale(1, 1)
		return value
	end
	local function button(name: string, skin: string, callback: () -> ()): TextButton
		local b = Instance.new("TextButton")
		b.Name = name
		b.Text = ""
		b.BackgroundTransparency = 1
		b.AutoButtonColor = false
		b.Selectable = true
		b.Parent = canvas
		local image = art(b, "Skin", skin)
		image.Size = UDim2.fromScale(1, 1)
		W.connect(b.Activated, callback)
		W.connect(b.MouseButton1Down, function()
			image.Position = UDim2.fromOffset(0, 3)
		end)
		local function release()
			image.Position = UDim2.new()
		end
		W.connect(b.MouseButton1Up, release)
		W.connect(b.MouseLeave, release)
		W.callbacks[b] = callback
		table.insert(W.buttons, b)
		W.firstButton = W.firstButton or b
		W.connect(b.SelectionGained, function()
			image.ImageColor3 = Color3.fromRGB(225, 255, 247)
		end)
		W.connect(b.SelectionLost, function()
			image.ImageColor3 = Color3.new(1, 1, 1)
		end)
		return b
	end
	local background = art(stage, "PeachGradient", "peach_gradient")
	background.Size = UDim2.fromScale(1, 1)
	background.ZIndex = 0
	local function oval(name: string, color: Color3, x: number, y: number, w: number, h: number)
		local object = Instance.new("Frame")
		object.Name = name
		object.BackgroundColor3 = color
		object.BorderSizePixel = 0
		object.Parent = canvas
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.5, 0)
		corner.Parent = object
		rect(object, x, y, w, h)
		return object
	end
	oval("OrangeAccent", Color3.fromRGB(255, 132, 35), 580, -200, 280, 240)
	oval("TurquoiseAccent", Color3.fromRGB(35, 198, 178), 1540, 137, 300, 450)
	local logo = art(canvas, "LockedWordmark", "logo")
	rect(logo, 22, 25, 345, 249)
	local home = button("Button_Home", "button_plum", function()
		options.navigate("Home")
	end)
	rect(home, 366, 10, 221, 83)
	raisedText(home, "← HOME", 36)
	local balance = art(canvas, "BalancePill", "button_plum")
	rect(balance, 1225, 5, 314, 103)
	local coin = art(balance, "Coin", "coin")
	rect(coin, 23, 22, 54, 54)
	local balanceText =
		label(balance, "Balance", if profile then tostring(profile.coins) .. " COINS" else "OFFLINE", 35)
	balanceText.Position = UDim2.fromOffset(82, 5)
	balanceText.Size = UDim2.new(1, -96, 1, -18)
	local profileButton = button("Button_ProfileTop", "button_plum", function()
		options.navigate("Profile")
	end)
	rect(profileButton, 1547, 8, 111, 101)
	local person = art(profileButton, "ProfileIcon", "icon_profile")
	person.Size = UDim2.fromScale(0.66, 0.7)
	person.Position = UDim2.fromScale(0.17, 0.06)
	local title = art(canvas, "HeadingPlate", "pill_cream")
	rect(title, 375, 97, 620, 126)
	title.Rotation = -5
	local first =
		label(title, "HeadingMake", '<font color="#3D1B39">MAKE IT </font><font color="#E44D05">YOURS</font>', 77, PLUM)
	first.RichText = true
	first.Size = UDim2.fromScale(0.94, 0.8)
	first.Position = UDim2.fromScale(0.03, 0.03)
	local second = label(title, "HeadingYours", "YOURS", 57, ORANGE)
	second.Visible = false
	second.Size = UDim2.fromScale(0.4, 0.8)
	second.Position = UDim2.fromScale(0.56, 0.03)
	for index, spec in { { 1030, 37, 80, 28, -45 }, { 1054, 85, 87, 28, -20 }, { 1040, 133, 78, 28, 15 } } do
		local ray = art(canvas, "HeadingAccent" .. index, "tab_orange")
		rect(ray, spec[1], spec[2], spec[3], spec[4])
		ray.Rotation = spec[5]
	end
	for index, row in
		{
			{ "PLAY", "Tutorial", "icon_play" },
			{ "CUSTOMIZE", "Customize", "icon_customize" },
			{ "SHOP", "Shop", "icon_shop" },
			{ "PROFILE", "Profile", "icon_profile" },
			{ "SETTINGS", "Settings", "icon_settings" },
		}
	do
		local nav = button("Button_" .. row[1], if index == 3 then "button_orange" else "button_plum", function()
			options.navigate(row[2])
		end)
		rect(nav, 14, ({ 282, 409, 524, 649, 766 })[index], 360, 128)
		local icon = art(nav, "Icon", row[3])
		icon.Position = UDim2.fromOffset(28, 18)
		icon.Size = UDim2.fromOffset(86, 82)
		local text = raisedText(nav, row[1], if index == 1 or index == 3 then 64 else 46)
		text.Position = UDim2.fromOffset(116, -3)
		text.Size = UDim2.new(1, -133, 1, -9)
		local shadow = nav:FindFirstChild("TypeShadow") :: TextLabel
		shadow.Position = UDim2.fromOffset(116, 0)
		shadow.Size = text.Size
	end
	local ringCard: TextButton
	local trailCard: TextButton
	local preview = Instance.new("Frame")
	preview.Name = "IndependentPreview"
	preview.BackgroundTransparency = 1
	preview.Parent = canvas
	rect(preview, 904, 144, 752, 560)
	local field = art(preview, "PlumField", "plum_texture")
	field.Position = UDim2.fromOffset(29, 45)
	field.Size = UDim2.new(1, -60, 1, -84)
	field.ScaleType = Enum.ScaleType.Tile
	field.TileSize = UDim2.fromOffset(128, 128)
	local fieldCorner = Instance.new("UICorner")
	fieldCorner.CornerRadius = UDim.new(0, 76)
	fieldCorner.Parent = field
	for _, info in
		{
			{ "route_orange", Color3.fromRGB(255, 139, 29), 360, 64, false },
			{ "route_teal", TEAL, 427, 206, true },
			{ "route_cream", CREAM, 582, 305, false },
		}
	do
		local routeArt = art(preview, info[1], info[1])
		routeArt.Position = UDim2.fromOffset(26, 51)
		routeArt.Size = UDim2.new(1, -52, 1, -100)
		routeArt.ImageColor3 = info[2]
		local coreArt =
			art(preview, if info[5] then "SelectedCore" else "OpponentCore", if info[5] then "ring" else "core_neutral")
		coreArt.ImageColor3 = if info[5] then Color3.new(1, 1, 1) else info[2]
		coreArt.AnchorPoint = Vector2.new(0.5, 0.5)
		coreArt.Position = UDim2.new(info[3] / 700, 26 - 52 * info[3] / 700, info[4] / 460, 51 - 100 * info[4] / 460)
		coreArt.Size = UDim2.fromOffset(if info[5] then 75 else 60, if info[5] then 75 else 60)
	end
	local rim = art(preview, "CreamRim", "frame_cream")
	rim.ScaleType = Enum.ScaleType.Stretch
	rim.Size = UDim2.fromScale(1, 1)
	local you = art(preview, "YouBadge", "pill_teal")
	you.AnchorPoint = Vector2.new(0.5, 1)
	you.Position = UDim2.new(427 / 700, 26 - 52 * 427 / 700, 206 / 460, 51 - 100 * 206 / 460 - 44)
	you.Size = UDim2.fromOffset(134, 61)
	raisedText(you, "YOU", 30)
	local topTab = art(preview, "TopTab", "tab_orange")
	topTab.Position = UDim2.new(0.5, -66, 0, -3)
	topTab.Size = UDim2.fromOffset(132, 47)
	local bottomTab = art(preview, "BottomTab", "tab_teal")
	bottomTab.Position = UDim2.new(0.5, -72, 1, -53)
	bottomTab.Size = UDim2.fromOffset(144, 53)
	local function chooseItem(itemId: string, opener: TextButton)
		selected = itemId
		selectedButton = opener
		stage:SetAttribute("SelectedCosmetic", itemId)
		local ringSkin = ringCard:FindFirstChild("Skin") :: ImageLabel
		local trailSkin = trailCard:FindFirstChild("Skin") :: ImageLabel
		ringSkin.Image = Assets[if itemId == "core_ring" then "card_selected" else "card_plum"].image
		trailSkin.Image = Assets[if itemId == "trail_dashed" then "card_selected" else "card_plum"].image
	end
	ringCard = button("Item_core_ring", "card_selected", function()
		chooseItem("core_ring", ringCard)
	end)
	rect(ringCard, 374, 242, 512, 196)
	trailCard = button("Item_trail_dashed", "card_plum", function()
		chooseItem("trail_dashed", trailCard)
	end)
	rect(trailCard, 374, 447, 512, 176)
	selectedButton = ringCard
	chooseItem(selected, if selected == "trail_dashed" then trailCard else ringCard)
	for _, info in
		{
			{ ringCard, "core_ring", "RING CORE", "ring" },
			{ trailCard, "trail_dashed", "DASHED TRAIL", "dashed_icon" },
		}
	do
		local b, id = info[1], info[2]
		local product = art(b, "Cosmetic", info[4])
		product.Position = UDim2.fromOffset(32, 32)
		product.Size = UDim2.fromOffset(160, 140)
		if id == "trail_dashed" then
			product.Position = UDim2.fromOffset(28, 40)
			product.Size = UDim2.fromOffset(168, 102)
		end
		local name = label(b, "ItemName", info[3], if id == "trail_dashed" then 43 else 49)
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.Position = UDim2.fromOffset(204, 17)
		name.Size = UDim2.new(1, -218, 0, 69)
		local pill = art(b, "PricePill", "pill_cream")
		pill.Position = UDim2.fromOffset(202, 91)
		pill.Size = UDim2.new(1, -220, 0, 75)
		local owned = profile and profile.owned[id] == true
		local price = label(
			pill,
			"Price",
			if owned then "✓ OWNED" else tostring(Catalog.ById[id].earnedCost) .. " COINS",
			37,
			PLUM
		)
		price.Position = UDim2.fromOffset(if owned then 4 else 52, -3)
		price.Size = UDim2.new(1, if owned then -8 else -60, 1, -6)
		if not owned then
			local token = art(pill, "Coin", "coin")
			token.Position = UDim2.fromOffset(22, 14)
			token.Size = UDim2.fromOffset(43, 43)
		end
	end
	local paid = art(canvas, "PurchasesUnavailable", "tab_orange")
	rect(paid, 456, 641, 352, 57)
	local paidLabel = label(paid, "DisabledPaidLabel", "PAID ITEMS UNAVAILABLE", 24)
	paidLabel.Size = UDim2.new(1, -20, 1, -10)
	paidLabel.Position = UDim2.fromOffset(10, -2)
	for index, info in
		{ { "core_default", "STARTER CORE", "core" }, { "trail_default", "STARTER TRAIL", "starter_trail_icon" } }
	do
		local b: TextButton
		b = button("Item_" .. info[1], "pill_cream", function()
			options.itemDetails(Catalog.ById[info[1]], b)
		end)
		rect(b, 374, if index == 1 then 704 else 803, 512, 94)
		local icon = art(b, "ItemIcon", info[3])
		icon.Position = UDim2.fromOffset(34, 17)
		icon.Size = UDim2.fromOffset(63, 58)
		if index == 2 then
			icon.Position = UDim2.fromOffset(27, 30)
			icon.Size = UDim2.fromOffset(78, 31)
		end
		local text = label(b, "ItemName", info[2], 31, PLUM)
		text.Position = UDim2.fromOffset(104, 0)
		text.Size = UDim2.fromOffset(249, 73)
		local owned = art(b, "OwnedBadge", "pill_teal")
		owned.Position = UDim2.fromOffset(363, 19)
		owned.Size = UDim2.fromOffset(127, 55)
		local ownedLabel = label(owned, "Owned", if profile and profile.owned[info[1]] then "OWNED" else "OFFLINE", 22)
		ownedLabel.Size = UDim2.new(1, -14, 1, -10)
		ownedLabel.Position = UDim2.fromOffset(7, -1)
	end
	local view = button("Button_ViewItem", "button_orange", function()
		if options.page == "Home" then
			options.navigate("Tutorial")
		else
			options.itemDetails(Catalog.ById[selected], selectedButton)
		end
	end)
	rect(view, 1032, 708, 528, 132)
	raisedText(view, "VIEW ITEM", 66)
	local disclaimer = label(canvas, "CosmeticDisclosure", "Cosmetic only. Same rules.", 29, PLUM)
	rect(disclaimer, 932, 851, 407, 47)
	local mockBadge = art(canvas, "MockBadge", "button_plum")
	rect(mockBadge, 1320, 854, 344, 55)
	local mockText = label(
		mockBadge,
		"MockDisclosure",
		if options.mock then "DESIGN PREVIEW · SAMPLE DATA" else "COSMETIC COLLECTION",
		19
	)
	mockText.Size = UDim2.new(1, -28, 1, -9)
	mockText.Position = UDim2.fromOffset(14, -2)
	local status = label(canvas, "ConnectionStatus", options.status or "", 19, PLUM)
	rect(status, 380, 910, 930, 29)
	local retry: TextButton? = nil
	if not profile or options.needsReconciliation then
		retry = button("Button_ReconcileProfile", "button_plum", options.refresh)
		rect(retry, 920, 910, 630, 64)
		raisedText(retry, if profile then "RECONCILE PROFILE" else "RETRY PROFILE CONNECTION", 26)
	end
	local arrange = require(script.Parent.PeachResponsive).bind(stage, canvas, scroll, layout, scaleText)
	W.connect(stage:GetPropertyChangedSignal("AbsoluteSize"), arrange)
	task.defer(arrange)
	return stage
end
return Peach
