--!strict
-- Scoped native components shared by the live app and UI Labs stories.
local Theme = require(script.Parent.Theme)
local Assets = require(script.Parent.PeachAssets)
local TweenService = game:GetService("TweenService")
local Widgets = {}
function Widgets.new()
	local W = {}
	local TextService = game:GetService("TextService")
	W.connections = {} :: { RBXScriptConnection }
	W.scale = 1
	W.reducedMotion = false
	W.tweens = {}
	W.firstButton = nil :: GuiButton?
	W.buttons = {} :: { TextButton }
	W.callbacks = {} :: { [GuiButton]: () -> () }
	function W.clear()
		for _, tween in W.tweens do
			tween:Cancel()
		end
		table.clear(W.tweens)
		for _, connection in W.connections do
			connection:Disconnect()
		end
		table.clear(W.connections)
		W.firstButton = nil
		table.clear(W.buttons)
		table.clear(W.callbacks)
	end
	function W.connect(signal: RBXScriptSignal, callback: (...any) -> ())
		local connection = signal:Connect(callback)
		table.insert(W.connections, connection)
		return connection
	end
	function W.frame(parent: Instance, name: string, height: number): Frame
		local result = Instance.new("Frame")
		result.Name = name
		result.Size = UDim2.new(1, 0, 0, height)
		result.BackgroundTransparency = 1
		result.Parent = parent
		return result
	end
	function W.list(parent: Instance, gap: number?)
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, gap or 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = parent
		return layout
	end
	function W.text(parent: Instance, content: string, height: number?, size: number?): TextLabel
		local result = Instance.new("TextLabel")
		result.Size = UDim2.new(1, 0, 0, height or 44)
		result.BackgroundTransparency = 1
		result.Font = Enum.Font.Gotham
		result.TextColor3 = Theme.Text
		result.TextSize = (size or 16) * W.scale
		result.TextWrapped = true
		result.TextXAlignment = Enum.TextXAlignment.Left
		result.TextYAlignment = Enum.TextYAlignment.Center
		result.Text = content
		result.Parent = parent
		-- Explicit width-aware measurement also handles wrapped large text in
		-- ScrollingFrames where automatic sizing can report only the clipped line.
		local function measure()
			if not result.Parent then
				return
			end
			local width = math.max(result.AbsoluteSize.X - 4, 1)
			local bounds = TextService:GetTextSize(content, result.TextSize, result.Font, Vector2.new(width, 10000))
			local desired = math.max(height or 44, bounds.Y + 12)
			if result.Size.Y.Offset ~= desired then
				result.Size = UDim2.new(1, 0, 0, desired)
			end
		end
		W.connect(result:GetPropertyChangedSignal("AbsoluteSize"), measure)
		task.defer(measure)
		return result
	end
	function W.button(parent: Instance, content: string, callback: () -> (), disabled: boolean?): TextButton
		local result = Instance.new("TextButton")
		result.Size = UDim2.new(1, 0, 0, 54)
		result.Font = Enum.Font.FredokaOne
		result.TextSize = 15 * W.scale
		result.TextWrapped = true
		if parent:IsA("ScrollingFrame") then
			result.AutomaticSize = Enum.AutomaticSize.Y
		end
		result.Name = "Button_" .. string.sub(string.gsub(content, "[^%w]", "_"), 1, 80)
		result.TextColor3 = Theme.Ink
		result.BackgroundColor3 = if disabled then Theme.Surface else Theme.Surface
		result.TextTransparency = if disabled then 0.4 else 0
		result.AutoButtonColor = false
		result.Active = not disabled
		result.Selectable = not disabled
		result.Text = content
		result.Parent = parent
		result.BackgroundTransparency = 1
		local skin = Instance.new("ImageLabel")
		skin.Name = "GlossySkin"
		skin.Image = Assets.button_plum.image
		skin.ScaleType = Enum.ScaleType.Slice
		skin.SliceCenter = Rect.new(table.unpack(Assets.button_plum.slice))
		skin.SliceScale = Assets.button_plum.sliceScale
		skin.BackgroundTransparency = 1
		skin.Size = UDim2.new(1, 12, 1, 8)
		skin.Position = UDim2.fromOffset(-6, -2)
		skin.Parent = result
		local face = Instance.new("TextLabel")
		face.Name = "ButtonFace"
		face.BackgroundTransparency = 1
		face.Size = UDim2.new(1, -12, 1, 0)
		face.Position = UDim2.fromOffset(6, 0)
		face.Text = content
		face.TextWrapped = true
		face.Font = result.Font
		face.TextSize = result.TextSize
		face.TextColor3 = Theme.Ink
		face.TextTransparency = if disabled then 0.45 else 0
		face.Parent = result
		W.connect(result:GetPropertyChangedSignal("TextSize"), function()
			face.TextSize = result.TextSize
		end)
		W.connect(result:GetPropertyChangedSignal("TextColor3"), function()
			face.TextColor3 = result.TextColor3
		end)
		W.connect(result:GetPropertyChangedSignal("Text"), function()
			face.Text = result.Text
		end)
		local stroke = Instance.new("UIStroke")
		stroke.Color = Theme.Border
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = result
		stroke.Transparency = 1
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = result
		result.BorderSizePixel = 0
		local inset = Instance.new("UIPadding")
		inset.PaddingLeft, inset.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
		inset.Parent = result
		if not disabled then
			local function feedback(active: boolean)
				if not result.Parent then
					return
				end
				result.TextTransparency = 0
				local color = if active then Color3.fromRGB(238, 248, 245) else Color3.new(1, 1, 1)
				if W.reducedMotion then
					skin.ImageColor3 = color
				else
					local tween = TweenService:Create(skin, TweenInfo.new(0.12), { ImageColor3 = color })
					if W.tweens[result] then
						W.tweens[result]:Cancel()
					end
					W.tweens[result] = tween
					tween:Play()
				end
				stroke.Color = if active then Theme.Accent else Theme.Border
				stroke.Thickness = if active then 2 else 1
			end
			W.connect(result.MouseEnter, function()
				feedback(true)
			end)
			W.connect(result.MouseLeave, function()
				feedback(false)
			end)
			W.connect(result.SelectionGained, function()
				feedback(true)
			end)
			W.connect(result.SelectionLost, function()
				feedback(false)
			end)
			W.connect(result.MouseButton1Down, function()
				result.TextTransparency = 0.25
				skin.Position = UDim2.fromOffset(-6, 1)
			end)
			W.connect(result.MouseButton1Up, function()
				result.TextTransparency = 0
				skin.Position = UDim2.fromOffset(-6, -2)
			end)
		end
		if not disabled then
			if not W.firstButton then
				W.firstButton = result
			end
			table.insert(W.buttons, result)
			W.callbacks[result] = callback
			W.connect(result.Activated, callback)
		end
		return result
	end
	function W.preview(parent: Instance, item: any)
		local frame = W.frame(parent, "CosmeticPreview", 160)
		local field = Instance.new("ImageLabel")
		field.Name = "PlumPreviewField"
		field.Image = Assets.plum_texture.image
		field.BackgroundTransparency = 1
		field.Position = UDim2.fromOffset(10, 10)
		field.Size = UDim2.new(1, -20, 1, -20)
		field.ScaleType = Enum.ScaleType.Tile
		field.TileSize = UDim2.fromOffset(128, 128)
		field.Parent = frame
		local clip = Instance.new("UICorner")
		clip.CornerRadius = UDim.new(0, 24)
		clip.Parent = field
		local trail = Instance.new("ImageLabel")
		trail.Name = "CosmeticTrail"
		trail.BackgroundTransparency = 1
		trail.Image = if item.id == "trail_dashed" then Assets.dashed_icon.image else Assets.route_teal.image
		trail.ImageColor3 = if item.id == "trail_dashed" then Color3.new(1, 1, 1) else Theme.Trail
		trail.Position = UDim2.fromScale(0.08, 0.12)
		trail.Size = UDim2.fromScale(0.82, 0.76)
		trail.ScaleType = Enum.ScaleType.Fit
		trail.Parent = frame
		local core = Instance.new("ImageLabel")
		core.Name = "CosmeticCore"
		core.BackgroundTransparency = 1
		core.Image = if item.id == "core_ring" then Assets.ring.image else Assets.core.image
		core.AnchorPoint = Vector2.new(0.5, 0.5)
		core.Position = UDim2.fromScale(0.72, 0.54)
		core.Size = UDim2.fromOffset(46, 46)
		core.Parent = frame
		local rim = Instance.new("ImageLabel")
		rim.Name = "CreamPreviewRim"
		rim.BackgroundTransparency = 1
		rim.Image = Assets.frame_cream.image
		rim.ScaleType = Enum.ScaleType.Slice
		rim.SliceCenter = Rect.new(table.unpack(Assets.frame_cream.slice))
		rim.SliceScale = 0.32
		rim.Size = UDim2.fromScale(1, 1)
		rim.Parent = frame
		return frame
	end
	function W.primary(control: TextButton)
		control:SetAttribute("Primary", true)
		control.BackgroundColor3 = Theme.Accent
		control.TextColor3 = Theme.Ink
		control.Font = Enum.Font.FredokaOne
		local skin = control:FindFirstChild("GlossySkin") :: ImageLabel?
		if skin then
			skin.Image = Assets.button_orange.image
			skin.SliceCenter = Rect.new(table.unpack(Assets.button_orange.slice))
		end
		control.TextSize = 21 * W.scale
		control.Size = UDim2.new(1, 0, 0, 64)
	end
	function W.selected(control: TextButton)
		control.BackgroundColor3 = Theme.Raised
		control.TextColor3 = Theme.Ink
		local skin = control:FindFirstChild("GlossySkin") :: ImageLabel?
		if skin then
			skin.Image = Assets.button_orange.image
			skin.SliceCenter = Rect.new(table.unpack(Assets.button_orange.slice))
		end
	end
	function W.label(parent: Instance, content: string, size: number, color: Color3?): TextLabel
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Text = content
		label.TextColor3 = color or Theme.Text
		label.Font = Enum.Font.FredokaOne
		label.TextSize = size
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.Parent = parent
		return label
	end
	function W.hero(parent: Instance)
		local hero = W.frame(parent, "HomeHero", 310)
		local title = W.label(hero, "BATTLE WITH\nTRAILS!", 60, Theme.Text)
		title.TextYAlignment = Enum.TextYAlignment.Top
		local marker = W.label(hero, "LAST CORE STANDING", 14, Theme.Text)
		local preview = W.preview(hero, { id = "core_ring" })
		local caption = W.label(hero, "A core. A trail.\nA way out.", 18, Theme.Ink)
		local function arrange()
			if not hero.Parent then
				return
			end
			local narrow = hero.AbsoluteSize.X < 650
			local titleSize = math.min((if narrow then 40 else 60) * W.scale, 72)
			title.TextSize = titleSize
			local titleWidth = math.max(hero.AbsoluteSize.X * (if narrow then 1 else 0.53) - 8, 1)
			local titleHeight = TextService:GetTextSize(
				title.Text,
				titleSize,
				title.Font,
				Vector2.new(titleWidth, 10000)
			).Y + 12
			marker.Size = UDim2.new(1, 0, 0, 28)
			title.Position = UDim2.fromOffset(0, 34)
			title.Size = UDim2.new(if narrow then 1 else 0.53, -8, 0, titleHeight)
			if narrow then
				preview.Position = UDim2.fromOffset(0, 44 + titleHeight)
				preview.Size = UDim2.new(1, 0, 0, 160)
				caption.Position = UDim2.fromOffset(16, 48 + titleHeight)
				caption.Size = UDim2.new(0.65, 0, 0, 60)
				hero.Size = UDim2.new(1, 0, 0, 220 + titleHeight)
			else
				preview.Position = UDim2.fromScale(0.55, 0.15)
				preview.Size = UDim2.new(0.45, 0, 1, -48)
				caption.Position = UDim2.new(0.58, 0, 0, 56)
				caption.Size = UDim2.new(0.4, 0, 0, 70)
				hero.Size = UDim2.new(1, 0, 0, math.max(280, titleHeight + 70))
			end
		end
		W.connect(hero:GetPropertyChangedSignal("AbsoluteSize"), arrange)
		task.defer(arrange)
		return hero
	end
	function W.card(parent: Instance, item: any, state: string, callback: () -> ())
		local card = W.button(parent, "", callback)
		card.Name = "Item_" .. item.id
		local preview = W.preview(card, item)
		preview.Position = UDim2.fromOffset(2, 12)
		preview.Size = UDim2.new(1, -4, 0.55, 0)
		local label = W.label(card, item.name, 18 * W.scale, Theme.Ink)
		label.Position = UDim2.fromScale(0, 0.62)
		label.Size = UDim2.fromScale(1, 0.18)
		local status =
			W.label(card, state .. "  ↗", 12 * W.scale, if state == "EQUIPPED" then Theme.Accent else Theme.Ink)
		status.Position = UDim2.fromScale(0, 0.83)
		status.Size = UDim2.fromScale(1, 0.14)
		return card
	end
	function W.arena(parent: Instance)
		local arena = W.frame(parent, "MockArena", 260)
		arena.BackgroundTransparency = 0
		arena.BackgroundColor3 = Theme.Surface
		local border = Instance.new("UIStroke")
		border.Color = Theme.Border
		border.Parent = arena
		local preview = W.preview(arena, { id = "trail_dashed" })
		preview.Position = UDim2.fromScale(0.08, 0.23)
		preview.Size = UDim2.fromScale(0.84, 0.6)
		local label = W.label(arena, "TOP-DOWN ARENA / MOCK VIEW", 12, Theme.Ink)
		label.Position = UDim2.fromOffset(16, 12)
		label.Size = UDim2.new(1, -32, 0, 28)
		return arena
	end
	return W
end
return Widgets
