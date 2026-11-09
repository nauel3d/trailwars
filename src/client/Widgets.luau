--!strict
-- Scoped native components shared by the live app and UI Labs stories.
local Theme = require(script.Parent.Theme)
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
		result.Font = Enum.Font.GothamMedium
		result.TextSize = 15 * W.scale
		result.TextWrapped = true
		if parent:IsA("ScrollingFrame") then
			result.AutomaticSize = Enum.AutomaticSize.Y
		end
		result.Name = "Button_" .. string.sub(string.gsub(content, "[^%w]", "_"), 1, 80)
		result.TextColor3 = Theme.Text
		result.BackgroundColor3 = if disabled then Theme.Surface else Theme.Surface
		result.TextTransparency = if disabled then 0.4 else 0
		result.AutoButtonColor = false
		result.Active = not disabled
		result.Selectable = not disabled
		result.Text = content
		result.Parent = parent
		local stroke = Instance.new("UIStroke")
		stroke.Color = Theme.Border
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = result
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
				local color = if result:GetAttribute("Primary")
					then Theme.Accent
					elseif active then Theme.Raised
					else Theme.Surface
				if W.reducedMotion then
					result.BackgroundColor3 = color
				else
					local tween = TweenService:Create(result, TweenInfo.new(0.12), { BackgroundColor3 = color })
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
			end)
			W.connect(result.MouseButton1Up, function()
				result.TextTransparency = 0
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
		local frame = W.frame(parent, "CosmeticPreview", 110)
		frame.BackgroundTransparency = 0
		frame.BackgroundColor3 = Theme.Background
		local trail = Instance.new("Frame")
		trail.Position = UDim2.new(0.15, 0, 0.5, -3)
		trail.Size = UDim2.new(0.65, 0, 0, 6)
		trail.BackgroundColor3 = Theme.Trail
		trail.BorderSizePixel = 0
		trail.Parent = frame
		if item.id == "trail_dashed" then
			-- Keep a continuous visible boundary under the cosmetic dash pattern.
			trail.BackgroundColor3 = Theme.Muted
			for index = 0, 7 do
				local dash = Instance.new("Frame")
				dash.Position = UDim2.fromScale(index / 8, 0)
				dash.Size = UDim2.fromScale(0.08, 1)
				dash.BackgroundColor3 = Theme.Trail
				dash.BorderSizePixel = 0
				dash.Parent = trail
			end
		end
		local core = Instance.new("Frame")
		core.AnchorPoint = Vector2.new(0.5, 0.5)
		core.Position = UDim2.fromScale(0.8, 0.5)
		core.Size = UDim2.fromOffset(28, 28)
		core.BackgroundColor3 = Theme.Accent
		core.BorderSizePixel = 0
		core.Parent = frame
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = core
		if item.id == "core_ring" then
			core.BackgroundTransparency = 1
			local stroke = Instance.new("UIStroke")
			stroke.Color = Theme.Accent
			stroke.Thickness = 4
			stroke.Parent = core
		end
		return frame
	end
	function W.primary(control: TextButton)
		control:SetAttribute("Primary", true)
		control.BackgroundColor3 = Theme.Accent
		control.TextColor3 = Theme.Ink
		control.Font = Enum.Font.GothamBold
		control.TextSize = 21 * W.scale
		control.Size = UDim2.new(1, 0, 0, 64)
	end
	function W.selected(control: TextButton)
		control.BackgroundColor3 = Theme.Raised
		control.TextColor3 = Theme.Accent
	end
	function W.label(parent: Instance, content: string, size: number, color: Color3?): TextLabel
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Text = content
		label.TextColor3 = color or Theme.Text
		label.Font = Enum.Font.GothamBold
		label.TextSize = size
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.Parent = parent
		return label
	end
	function W.hero(parent: Instance)
		local hero = W.frame(parent, "HomeHero", 310)
		local title = W.label(hero, "MAKE YOUR\nOWN WAY.", 60, Theme.Text)
		title.TextYAlignment = Enum.TextYAlignment.Top
		local marker = W.label(hero, "01 / SURVIVAL ARCADE", 13, Theme.Accent)
		local preview = W.preview(hero, { id = "core_ring" })
		local caption = W.label(hero, "A core. A trail.\nA way out.", 18, Theme.Muted)
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
		local label = W.label(card, item.name, 18 * W.scale, Theme.Text)
		label.Position = UDim2.fromScale(0, 0.62)
		label.Size = UDim2.fromScale(1, 0.18)
		local status =
			W.label(card, state .. "  ↗", 12 * W.scale, if state == "EQUIPPED" then Theme.Accent else Theme.Muted)
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
		local label = W.label(arena, "TOP-DOWN ARENA / MOCK VIEW", 12, Theme.Muted)
		label.Position = UDim2.fromOffset(16, 12)
		label.Size = UDim2.new(1, -32, 0, 28)
		return arena
	end
	return W
end
return Widgets
