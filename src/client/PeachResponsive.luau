--!strict
-- Layout in real viewport pixels. Only decorative preview art uses a local scale.
local Responsive = {}
function Responsive.bind(stage: Frame, canvas: Frame, scroll: ScrollingFrame, design: any, textScale: number)
	local TextService = game:GetService("TextService")
	local function get(name: string): any
		return canvas:FindFirstChild(name)
	end
	local preview = get("IndependentPreview")
	local previewScale = Instance.new("UIScale")
	previewScale.Name = "PreviewArtScale"
	previewScale.Parent = preview
	local function box(object: GuiObject, x: number, y: number, w: number, h: number)
		object.Visible = true
		object.Position = UDim2.fromOffset(math.round(x), math.round(y))
		object.Size = UDim2.fromOffset(math.round(w), math.round(h))
	end
	local function measure(label: TextLabel, width: number): number
		return TextService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(math.max(width, 1), 10000)).Y
			+ 4
	end
	local function card(name: string, w: number, baseHeight: number): number
		local item = get(name)
		local title = item.ItemName
		local art = item.Cosmetic
		local iconSize = math.clamp(w * 0.31, 64, 160)
		local left = iconSize + 42
		local available = w - left - 16
		local size = if name == "Item_core_ring" then 49 else 43
		title.TextSize = math.clamp(size * w / 512, 21, size) * textScale
		local titleHeight = measure(title, available)
		box(title, left, 16, available, titleHeight)
		box(art, 22, 24, iconSize, if name == "Item_core_ring" then iconSize else iconSize * 0.62)
		local pill = item.PricePill
		local price = pill.Price
		price.TextSize = math.clamp(37 * w / 512, 18, 37) * textScale
		local coin = pill:FindFirstChild("Coin")
		local coinSize = math.clamp(w * 0.084, 25, 43)
		local priceX = if coin then coinSize + 17 else 7
		local pillWidth = w - left - 12
		local priceHeight = measure(price, pillWidth - priceX - 10)
		local pillHeight = math.max(48, priceHeight + 18)
		local pillY = 16 + titleHeight + 8
		box(pill, left - 5, pillY, pillWidth, pillHeight)
		box(price, priceX, 2, pillWidth - priceX - 10, pillHeight - 10)
		if coin then
			box(coin, 14, (pillHeight - coinSize) / 2 - 4, coinSize, coinSize)
		end
		return math.max(baseHeight, pillY + pillHeight + 14, iconSize + 40)
	end
	local function starter(name: string, w: number): number
		local item = get(name)
		local title, badge = item.ItemName, item.OwnedBadge
		title.TextSize = math.clamp(w * 0.061, 17, 31) * textScale
		badge.Owned.TextSize = math.clamp(w * 0.043, 14, 22) * textScale
		local badgeWidth = math.max(76, w * 0.248, badge.Owned.TextSize * 4.7)
		local iconWidth = math.clamp(w * 0.12, 35, 63)
		local titleX = iconWidth + 36
		local titleWidth = math.max(64, w - titleX - badgeWidth - 24)
		local height =
			math.max(math.clamp(w * 94 / 512, 72, 94), measure(title, titleWidth) + 24, badge.Owned.TextSize * 1.6 + 28)
		box(title, titleX, 2, titleWidth, height - 16)
		box(badge, w - badgeWidth - 14, (height - 54) / 2, badgeWidth, 54)
		box(
			item.ItemIcon,
			22,
			(height - iconWidth) / 2 - 5,
			iconWidth,
			if name == "Item_core_default" then iconWidth else iconWidth * 0.4
		)
		return height
	end
	local names = { "PLAY", "CUSTOMIZE", "SHOP", "PROFILE", "SETTINGS" }
	local function navButton(index: number, x: number, y: number, w: number, h: number, compact: boolean?)
		local b = get("Button_" .. names[index])
		box(b, x, y, w, h)
		local icon, text, shadow = b.Icon, b.Label, b.TypeShadow
		if compact then
			box(icon, 10, (h - 28) / 2 - 3, 28, 28)
			text.TextSize = 16 * textScale
			box(text, 40, 0, w - 47, h - 8)
		else
			local iconSize = math.min(82, h * 0.68)
			box(icon, 22, (h - iconSize) / 2 - 4, iconSize, iconSize)
			text.TextSize = math.clamp(w * 0.128, 22, if index == 1 or index == 3 then 64 else 46) * textScale
			local textX = iconSize + 37
			local available = w - textX - 18
			local needed = measure(text, available)
			box(text, textX, 0, available, math.max(h - 8, needed))
		end
		shadow.TextSize = text.TextSize
		shadow.Size = text.Size
		shadow.Position = text.Position + UDim2.fromOffset(0, 3)
	end
	return function()
		if not stage.Parent or not canvas.Parent then
			return
		end
		local w, h = stage.AbsoluteSize.X, stage.AbsoluteSize.Y
		if w < 1 or h < 1 then
			return
		end
		(canvas:FindFirstChildOfClass("UIScale") :: UIScale).Scale = 1
		canvas.Position = UDim2.new()
		canvas.Size = UDim2.fromOffset(w, h)
		for object in design do
			if object.Parent == canvas then
				object.Visible = true
			end
		end
		if stage:GetAttribute("PageKind") == "Home" then
			local portraitHome = w < 760
			local scaleObject = canvas:FindFirstChildOfClass("UIScale") :: UIScale
			local title = get("HeadingPlate")
			title.HeadingMake.Text = '<font color="#3D1B39">BATTLE WITH </font><font color="#E44D05">TRAILS!</font>'
			for _, name in
				{
					"Item_core_ring",
					"Item_trail_dashed",
					"Item_core_default",
					"Item_trail_default",
					"PurchasesUnavailable",
					"MockBadge",
				}
			do
				get(name).Visible = false
			end
			for i = 1, 3 do
				get("HeadingAccent" .. i).Visible = false
			end
			local play = get("Button_ViewItem")
			play.Label.Text, play.TypeShadow.Text = "PLAY NOW", "PLAY NOW"
			local rule = get("CosmeticDisclosure")
			rule.Text = "Steer left or right. Last core standing wins."
			local cw, ch
			if portraitHome then
				cw = 390
				local large = textScale > 1.1
				box(get("LockedWordmark"), 8, 0, 146, 106)
				box(get("BalancePill"), 175, 4, 207, 62)
				box(get("Button_Home"), 160, 72, 146, 54)
				box(get("Button_ProfileTop"), 320, 72, 62, 54)
				local titleHeight = if large then 130 else 65
				box(title, 8, 131, 374, titleHeight)
				title.HeadingMake.TextSize = 30 * textScale
				local y = 131 + titleHeight + 8
				box(preview, 12, y, 366, 184)
				previewScale.Scale = 1
				for _, child in preview:GetChildren() do
					if child:IsA("ImageLabel") and (child.Name == "SelectedCore" or child.Name == "OpponentCore") then
						child.Size = UDim2.fromOffset(32, 32)
					end
				end
				preview.YouBadge.Size = UDim2.fromOffset(72, 34)
				preview.YouBadge.Label.TextSize = 18
				preview.YouBadge.TypeShadow.TextSize = 18
				y += 194
				local playHeight = if large then 76 else 68
				box(play, 28, y, 334, playHeight)
				play.Label.TextSize, play.TypeShadow.TextSize = 42 * textScale, 42 * textScale
				y += playHeight + 5
				local ruleHeight = if large then 62 else 40
				box(rule, 12, y, 366, ruleHeight)
				rule.TextSize = 18 * textScale
				y += ruleHeight + 6
				local navHeight = if large then 72 else 64
				for i = 1, 5 do
					local b = get("Button_" .. names[i])
					local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
					box(b, 8 + col * 126, y + row * (navHeight + 5), 122, navHeight)
					b.Icon.Visible = false
					box(b.Label, 6, 0, 110, navHeight - 5)
					b.Label.TextSize = 18 * textScale
					b.TypeShadow.Size = b.Label.Size
					b.TypeShadow.Position = b.Label.Position + UDim2.fromOffset(0, 3)
					b.TypeShadow.TextSize = b.Label.TextSize
				end
				ch = y + navHeight * 2 + 18
			else
				cw, ch = 1672, 941
				box(get("LockedWordmark"), 22, 25, 345, 249)
				box(get("Button_Home"), 374, 10, 221, 83)
				box(get("BalancePill"), 1225, 5, 314, 103)
				box(get("Button_ProfileTop"), 1547, 8, 111, 101)
				box(title, 435, 97, 1120, 126)
				title.HeadingMake.TextSize = 76 * textScale
				box(preview, 420, 240, 1220, 490)
				previewScale.Scale = 1
				for i = 1, 5 do
					navButton(i, 14, 282 + (i - 1) * 122, 360, 116)
				end
				box(play, 650, 790, 760, 132)
				play.Label.TextSize, play.TypeShadow.TextSize = 66 * textScale, 66 * textScale
				box(rule, 440, 738, 1180, 48)
				rule.TextSize = 29 * textScale
			end
			get("ConnectionStatus").Visible = false
			local bal = get("BalancePill")
			bal.Balance.TextSize = (if portraitHome then 23 else 35) * textScale
			get("Button_Home").Label.TextSize = (if portraitHome then 22 else 36) * textScale
			get("Button_Home").TypeShadow.TextSize = get("Button_Home").Label.TextSize
			local scale = math.min(w / cw, h / ch)
			scaleObject.Scale = scale
			canvas.Size = UDim2.fromOffset(cw, ch)
			canvas.Position = UDim2.fromOffset((w - cw * scale) / 2, (h - ch * scale) / 2)
			scroll.CanvasSize = UDim2.new()
			stage:SetAttribute("LayoutMode", if portraitHome then "HomePortraitFit" else "HomeLandscapeFit")
			stage:SetAttribute("GlobalScale", scale)
			return
		end
		if w < 760 then
			local cw = 390
			local large = textScale > 1.1
			for _, n in names do
				get("Button_" .. n).Visible = false
			end
			for i = 1, 3 do
				get("HeadingAccent" .. i).Visible = false
			end
			box(get("LockedWordmark"), 8, 0, 130, 94)
			box(get("BalancePill"), 180, 4, 202, 62)
			get("BalancePill").Balance.TextSize = 22 * textScale
			box(get("Button_Home"), 145, 72, 150, 52)
			get("Button_Home").Label.TextSize = 22 * textScale
			get("Button_Home").TypeShadow.TextSize = 22 * textScale
			box(get("Button_ProfileTop"), 322, 72, 58, 52)
			box(get("HeadingPlate"), 8, 105, 374, if large then 108 else 64)
			get("HeadingPlate").HeadingMake.TextSize = 34 * textScale
			local y = if large then 220 else 178
			box(preview, 8, y, 374, 152)
			previewScale.Scale = 1
			for _, child in preview:GetChildren() do
				if child:IsA("ImageLabel") and (child.Name == "SelectedCore" or child.Name == "OpponentCore") then
					child.Size = UDim2.fromOffset(30, 30)
				end
			end
			preview.YouBadge.Size = UDim2.fromOffset(72, 34)
			preview.YouBadge.Label.TextSize = 18
			preview.YouBadge.TypeShadow.TextSize = 18
			y += 160
			box(get("Button_ViewItem"), 50, y, 290, if large then 66 else 56)
			get("Button_ViewItem").Label.TextSize = 32 * textScale
			get("Button_ViewItem").TypeShadow.TextSize = 32 * textScale
			y += if large then 72 else 62
			for _, id in { "core_ring", "trail_dashed" } do
				local item = get("Item_" .. id)
				local height = if large then 98 else 78
				box(item, 8, y, 374, height)
				box(item.Cosmetic, 18, 12, 56, if id == "core_ring" then 56 else 36)
				box(item.ItemName, 88, 2, 270, if large then 43 else 32)
				item.ItemName.TextSize = 22 * textScale
				local pill = item.PricePill
				box(pill, 84, if large then 44 else 34, 280, if large then 48 else 38)
				box(pill.Price, 42, 0, 225, if large then 42 else 33)
				pill.Price.TextSize = 18 * textScale
				local coin = pill:FindFirstChild("Coin")
				if coin then
					box(coin, 12, 7, 26, 26)
				end
				y += height + 7
			end
			for i, id in { "core_default", "trail_default" } do
				local item = get("Item_" .. id)
				local rowH = if large then 86 else 70
				box(item, if i == 1 then 8 else 200, y, 182, rowH)
				box(item.ItemIcon, 12, 10, 30, if i == 1 then 30 else 15)
				box(item.ItemName, 46, 1, 124, if large then 56 else 42)
				item.ItemName.TextSize = 16 * textScale
				box(item.OwnedBadge, 75, if large then 57 else 43, 96, 29)
				item.OwnedBadge.Owned.TextSize = 12 * textScale
			end
			y += if large then 92 else 76
			box(get("PurchasesUnavailable"), 8, y, 374, if large then 52 else 38)
			get("PurchasesUnavailable").DisabledPaidLabel.TextSize = 17 * textScale
			y += if large then 58 else 44
			box(get("CosmeticDisclosure"), 8, y, 374, 34)
			get("CosmeticDisclosure").TextSize = 16 * textScale
			y += if large then 48 else 38
			box(get("MockBadge"), 8, y, 374, 36)
			get("MockBadge").MockDisclosure.TextSize = 13 * textScale
			y += 42
			get("ConnectionStatus").Visible = false
			local retry = get("Button_ReconcileProfile")
			if retry then
				box(retry, 8, y, 374, 64)
				y += 70
			end
			local scale = math.min(w / cw, h / y)
			local scaleObject = canvas:FindFirstChildOfClass("UIScale") :: UIScale
			scaleObject.Scale = scale
			canvas.Size = UDim2.fromOffset(cw, y)
			canvas.Position = UDim2.fromOffset((w - cw * scale) / 2, (h - y * scale) / 2)
			scroll.CanvasSize = UDim2.new()
			stage:SetAttribute("LayoutMode", "CompactPortraitFit")
			stage:SetAttribute("GlobalScale", scale)
			return
		end
		local portrait = false
		local wide = true
		stage:SetAttribute("LayoutMode", if portrait then "Phone" elseif wide then "Desktop" else "Tablet")
		stage:SetAttribute("GlobalScale", 1)
		local pad = if portrait then 12 else 16
		local logo, home, balance, profile =
			get("LockedWordmark"), get("Button_Home"), get("BalancePill"), get("Button_ProfileTop")
		local title, view, paid = get("HeadingPlate"), get("Button_ViewItem"), get("PurchasesUnavailable")
		local titleLabel = title.HeadingMake
		local ring, trail = get("Item_core_ring"), get("Item_trail_dashed")
		local core, starterTrail = get("Item_core_default"), get("Item_trail_default")
		local footer = get("CosmeticDisclosure")
		local badge, status, retry = get("MockBadge"), get("ConnectionStatus"), get("Button_ReconcileProfile")
		local bottom = 0
		if wide then
			local rail = math.clamp(w * 0.215, 210, 360)
			local mainX = rail + 14
			local mainW = w - mainX - pad
			local itemW = math.clamp(mainW * 0.4, 280, 512)
			local rightX = mainX + itemW + 18
			local rightW = w - rightX - pad
			local headerH = math.clamp(h * 0.257, 142, 242)
			box(logo, 22, 16, rail - 12, (rail - 12) * 249 / 345)
			box(home, mainX, 10, math.min(221, itemW * 0.5), 76)
			box(balance, w - 445, 5, 314, 88)
			box(profile, w - 120, 8, 104, 88)
			box(title, mainX, 97, math.min(itemW + 108, mainW * 0.54), math.max(82, headerH - 116))
			titleLabel.TextSize = math.clamp(itemW * 0.14, 34, 77) * textScale
			local titleH = if textScale > 1.1 then titleLabel.TextSize * 3 else math.max(82, headerH - 116)
			title.Size = UDim2.fromOffset(title.Size.X.Offset, titleH)
			local y = math.max(headerH, 97 + titleH + 16)
			local ringH = card("Item_core_ring", itemW, math.clamp(h * 0.208, 120, 196))
			local trailH = card("Item_trail_dashed", itemW, math.clamp(h * 0.187, 120, 176))
			box(ring, mainX, y, itemW, ringH)
			y += ringH + 12
			box(trail, mainX, y, itemW, trailH)
			y += trailH + 14
			local paidH = math.max(48, 30 * textScale + 20)
			box(paid, mainX + itemW * 0.05, y, itemW * 0.9, paidH)
			paid.DisabledPaidLabel.TextSize = math.clamp(itemW * 0.047, 16, 24) * textScale
			y += paidH + 12
			local coreH, trailRowH = starter("Item_core_default", itemW), starter("Item_trail_default", itemW)
			box(core, mainX, y, itemW, coreH)
			y += coreH + 8
			box(starterTrail, mainX, y, itemW, trailRowH)
			bottom = y + trailRowH + 12
			local previewY = math.max(108, headerH * 0.595)
			local previewH = math.min(rightW * 560 / 752, math.max(240, h - previewY - 170))
			local artScale = previewH / 560
			local artW = 752 * artScale
			box(preview, rightX + (rightW - artW) / 2, previewY, 752, 560)
			previewScale.Scale = artScale
			local actionY = previewY + previewH + 12
			box(view, rightX + rightW * 0.08, actionY, rightW * 0.84, math.clamp(h * 0.14, 64, 132))
			view.Label.TextSize = math.clamp(rightW * 0.085, 28, 66) * textScale
			view.TypeShadow.TextSize = view.Label.TextSize
			local footerY = actionY + view.Size.Y.Offset + 10
			box(footer, rightX, footerY, rightW, 48 * textScale)
			footer.TextSize = math.clamp(rightW * 0.038, 18, 29) * textScale
			local badgeH = math.max(56, 19 * textScale * 2.5 + 12)
			box(badge, rightX + rightW * 0.2, footerY + 50 * textScale, rightW * 0.6, badgeH)
			bottom = math.max(bottom, footerY + 50 * textScale + badgeH + 8)
			local navY = math.max(logo.Position.Y.Offset + logo.Size.Y.Offset + 12, headerH + 22)
			local navH = math.clamp((h - navY - 24) / 5 - 8, 64, 128)
			for i = 1, 5 do
				navButton(i, 14, navY + (i - 1) * (navH + 7), rail, navH)
			end
			bottom = math.max(bottom, navY + 5 * (navH + 7))
		else
			local logoW = math.clamp(w * 0.36, 120, 215)
			box(logo, pad, 8, logoW, logoW * 249 / 345)
			box(balance, w - math.min(270, w * 0.53) - pad, 8, math.min(270, w * 0.53), 64)
			box(home, w - 216, 76, 140, 54)
			box(profile, w - 70, 76, 58, 54)
			local headerY = math.max(logoW * 249 / 345 + 24, 140)
			local titleH = if textScale > 1.1 then 150 else 94
			box(title, pad + 8, headerY, w - 2 * pad - 16, titleH)
			titleLabel.TextSize = math.clamp(w / 13, 25, 54) * textScale
			local y = headerY + titleH + 18
			local contentW = w - pad * 2
			local artW = math.min(contentW, 700)
			box(preview, (w - artW) / 2, y, 752, 560)
			previewScale.Scale = artW / 752
			y += artW * 560 / 752 + 12
			box(view, pad + 6, y, contentW - 12, math.max(64, 50 * textScale))
			view.Label.TextSize = 30 * textScale
			view.TypeShadow.TextSize = view.Label.TextSize
			y += view.Size.Y.Offset + 14
			local ringH = card("Item_core_ring", contentW, 130)
			box(ring, pad, y, contentW, ringH)
			y += ringH + 10
			local trailH = card("Item_trail_dashed", contentW, 130)
			box(trail, pad, y, contentW, trailH)
			y += trailH + 12
			box(paid, pad, y, contentW, if textScale > 1.1 then 90 else 56)
			paid.DisabledPaidLabel.TextSize = 18 * textScale
			y += paid.Size.Y.Offset + 10
			local coreH, trailH2 = starter("Item_core_default", contentW), starter("Item_trail_default", contentW)
			box(core, pad, y, contentW, coreH)
			y += coreH + 8
			box(starterTrail, pad, y, contentW, trailH2)
			y += trailH2 + 12
			box(footer, pad, y, contentW, 52 * textScale)
			footer.TextSize = 17 * textScale
			y += 52 * textScale + 8
			box(badge, pad, y, contentW, 58)
			y += 70
			local navHeight = math.max(64, 48 * textScale)
			for i = 1, 5 do
				local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
				navButton(
					i,
					pad + col * (contentW / 2 + 3),
					y + row * (navHeight + 6),
					contentW / 2 - 3,
					navHeight,
					true
				)
			end
			bottom = y + 3 * (navHeight + 6)
		end
		balance.Coin.Position = UDim2.fromOffset(12, 10)
		balance.Coin.Size = UDim2.fromOffset(42, 42)
		balance.Balance.Position = UDim2.fromOffset(60, 0)
		balance.Balance.Size = UDim2.new(1, -70, 1, -10)
		balance.Balance.TextSize = math.clamp(balance.Size.X.Offset / 10, 17, 30) * textScale
		home.Label.TextSize = if wide then 32 * textScale else 19 * textScale
		home.TypeShadow.TextSize = home.Label.TextSize
		for i = 1, 3 do
			local ray = get("HeadingAccent" .. i)
			ray.Visible = wide and h > 750
		end
		local badgeText = badge.MockDisclosure
		badgeText.TextSize = (if wide then 19 else 15) * textScale
		box(status, pad, bottom + 4, w - 2 * pad, 52 * textScale)
		status.TextSize = 16 * textScale
		bottom += 60 * textScale
		if retry then
			box(retry, pad, bottom, w - 2 * pad, 64 * textScale)
			bottom += 70 * textScale
		end
		local canvasHeight = math.max(h, bottom + 12)
		local fit = math.min(1, h / canvasHeight)
		local scaleObject = canvas:FindFirstChildOfClass("UIScale") :: UIScale
		scaleObject.Scale = fit
		canvas.Size = UDim2.fromOffset(w, canvasHeight)
		canvas.Position = UDim2.fromOffset((w - w * fit) / 2, 0)
		scroll.CanvasSize = UDim2.new()
		stage:SetAttribute("GlobalScale", fit)
	end
end
return Responsive
