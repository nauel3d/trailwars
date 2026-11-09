--!strict
-- Temporary neutral wireframe tokens. These are not the approved brand system.
local W = {}
local TextService = game:GetService("TextService")
W.connections = {} :: { RBXScriptConnection }
W.scale = 1
W.firstButton = nil :: GuiButton?
W.buttons = {} :: { TextButton }
W.callbacks = {} :: { [GuiButton]: () -> () }
function W.clear()
	for _, connection in W.connections do connection:Disconnect() end
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
	result.TextColor3 = Color3.fromRGB(235, 235, 235)
	result.TextSize = (size or 16) * W.scale
	result.TextWrapped = true
	result.TextXAlignment = Enum.TextXAlignment.Left
	result.TextYAlignment = Enum.TextYAlignment.Center
	result.Text = content
	result.Parent = parent
	-- Explicit width-aware measurement also handles wrapped large text in
	-- ScrollingFrames where automatic sizing can report only the clipped line.
	local function measure()
		if not result.Parent then return end
		local width = math.max(result.AbsoluteSize.X - 4, 1)
		local bounds = TextService:GetTextSize(content, result.TextSize, result.Font, Vector2.new(width, 10000))
		local desired = math.max(height or 44, bounds.Y + 12)
		if result.Size.Y.Offset ~= desired then result.Size = UDim2.new(1, 0, 0, desired) end
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
	if parent:IsA("ScrollingFrame") then result.AutomaticSize = Enum.AutomaticSize.Y end
	result.Name = "Button_" .. string.sub(string.gsub(content, "[^%w]", "_"), 1, 80)
	result.TextColor3 = Color3.fromRGB(245, 245, 245)
	result.BackgroundColor3 = if disabled then Color3.fromRGB(42, 42, 42) else Color3.fromRGB(66, 66, 66)
	result.TextTransparency = if disabled then 0.4 else 0
	result.AutoButtonColor = not disabled
	result.Active = not disabled
	result.Selectable = not disabled
	result.Text = content
	result.Parent = parent
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(120, 120, 120)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = result
	if not disabled then
		if not W.firstButton then W.firstButton = result end
		table.insert(W.buttons, result)
		W.callbacks[result] = callback
		W.connect(result.Activated, callback)
	end
	return result
end
function W.preview(parent: Instance, item: any)
	local frame = W.frame(parent, "CosmeticPreview", 110)
	frame.BackgroundTransparency = 0
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	local trail = Instance.new("Frame")
	trail.Position = UDim2.new(0.15, 0, 0.5, -3)
	trail.Size = UDim2.new(0.65, 0, 0, 6)
	trail.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
	trail.BorderSizePixel = 0
	trail.Parent = frame
	if item.id == "trail_dashed" then
		trail.BackgroundTransparency = 1
		for index = 0, 7 do
			local dash = Instance.new("Frame")
			dash.Position = UDim2.fromScale(index / 8, 0)
			dash.Size = UDim2.new(0.08, 0, 1, 0)
			dash.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
			dash.BorderSizePixel = 0
			dash.Parent = trail
		end
	end
	local core = Instance.new("Frame")
	core.AnchorPoint = Vector2.new(0.5, 0.5)
	core.Position = UDim2.fromScale(0.8, 0.5)
	core.Size = UDim2.fromOffset(28, 28)
	core.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	core.BorderSizePixel = 0
	core.Parent = frame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = core
	if item.id == "core_ring" then
		core.BackgroundTransparency = 1
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(240, 240, 240)
		stroke.Thickness = 4
		stroke.Parent = core
	end
	return frame
end
return W
