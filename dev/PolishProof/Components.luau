--!strict
-- Development-only native UI proof. No production routing or economy changes.
local TweenService = game:GetService("TweenService")
local Kit = {}
Kit.colors = {
	ink = Color3.fromRGB(25, 42, 70),
	paper = Color3.fromRGB(255, 252, 243),
	mint = Color3.fromRGB(223, 244, 232),
	coral = Color3.fromRGB(255, 105, 87),
	blue = Color3.fromRGB(88, 119, 232),
	yellow = Color3.fromRGB(244, 206, 84),
}
function Kit.box(object: GuiObject, r: { number })
	object.Position = UDim2.fromOffset(math.round(r[1]), math.round(r[2]))
	object.Size = UDim2.fromOffset(math.round(r[3]), math.round(r[4]))
end
function Kit.frame(parent: Instance, name: string, color: Color3?): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.BorderSizePixel = 0
	f.BackgroundTransparency = if color then 0 else 1
	if color then
		f.BackgroundColor3 = color
	end
	f.Parent = parent
	return f
end
function Kit.round(parent: Instance, radius: number)
	local c = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end
function Kit.outline(parent: Instance, color: Color3?, width: number?): UIStroke
	local s = Instance.new("UIStroke")
	s.Color = color or Kit.colors.ink
	s.Thickness = width or 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end
function Kit.text(parent: Instance, name: string, value: string, size: number, color: Color3?): TextLabel
	local t = Instance.new("TextLabel")
	t.Name = name
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.Text = value
	t.TextSize = size
	t.TextColor3 = color or Kit.colors.ink
	t.TextWrapped = true
	t.Size = UDim2.fromScale(1, 1)
	t.Parent = parent
	return t
end
function Kit.new(reducedMotion: boolean?)
	local scope: any = { connections = {}, tweens = {}, reducedMotion = reducedMotion == true, controls = {} }
	function scope:connect(signal: RBXScriptSignal, fn: (...any) -> ())
		local c = signal:Connect(fn)
		table.insert(self.connections, c)
		return c
	end
	function scope:move(face: GuiObject, y: number)
		if self.tweens[face] then
			self.tweens[face]:Cancel()
			self.tweens[face] = nil
		end
		local target = UDim2.fromOffset(0, y)
		if self.reducedMotion then
			face.Position = target
			return
		end
		local tween = TweenService:Create(
			face,
			TweenInfo.new(if y == 0 then 0.12 else 0.045, Enum.EasingStyle.Quad),
			{ Position = target }
		)
		self.tweens[face] = tween
		tween:Play()
	end
	function scope:button(parent: Instance, name: string, label: string, primary: boolean?, callback: () -> ())
		local root = Instance.new("TextButton")
		root.Name = name
		root.Text = ""
		root.BackgroundTransparency = 1
		root.AutoButtonColor = false
		root.Selectable = true
		root.Parent = parent
		local base = Kit.frame(root, "Shadow", Kit.colors.ink)
		base.Position = UDim2.fromOffset(0, 5)
		base.Size = UDim2.new(1, 0, 1, -5)
		Kit.round(base, 16)
		local face = Kit.frame(root, "Face", if primary then Kit.colors.coral else Kit.colors.paper)
		face.Size = UDim2.new(1, 0, 1, -7)
		Kit.round(face, 16)
		Kit.outline(face)
		local text = Kit.text(
			face,
			"Label",
			label,
			if primary then 36 else 18,
			if primary then Kit.colors.paper else Kit.colors.ink
		)
		text.Position = UDim2.fromOffset(8, 0)
		text.Size = UDim2.new(1, -16, 1, 0)
		local focus = Kit.outline(root, Kit.colors.blue, 4)
		focus.Enabled = false
		local state = "Default"
		local control: any = { root = root, face = face, label = text }
		function control.setState(_control: any, nextState: string)
			state = nextState
			root:SetAttribute("State", state)
			local disabled = state == "Disabled" or state == "Loading"
			root.Active = not disabled
			root.Selectable = not disabled
			text.Text = if state == "Loading" then "PLEASE WAIT…" else label
			text.TextTransparency = if disabled then 0.4 else 0
			face.BackgroundColor3 = if state == "Selected"
				then Color3.fromRGB(222, 230, 255)
				elseif primary then Kit.colors.coral
				else Kit.colors.paper
			scope:move(face, 0)
		end
		function control.activate(_control: any)
			if state ~= "Disabled" and state ~= "Loading" then
				callback()
			end
		end
		scope:connect(root.Activated, function()
			control:activate()
		end)
		scope:connect(root.InputBegan, function(input: InputObject)
			if
				state ~= "Disabled"
				and state ~= "Loading"
				and (
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
					or input.KeyCode == Enum.KeyCode.ButtonA
				)
			then
				scope:move(face, 4)
			end
		end)
		scope:connect(root.InputEnded, function()
			scope:move(face, 0)
		end)
		scope:connect(root.MouseLeave, function()
			scope:move(face, 0)
		end)
		scope:connect(root.SelectionGained, function()
			focus.Enabled = true
		end)
		scope:connect(root.SelectionLost, function()
			focus.Enabled = false
			scope:move(face, 0)
		end)
		scope:connect(root.MouseEnter, function()
			if state == "Default" then
				face.BackgroundColor3 = if primary then Color3.fromRGB(255, 119, 98) else Kit.colors.mint
			end
		end)
		scope:connect(root.MouseLeave, function()
			if state == "Default" then
				face.BackgroundColor3 = if primary then Kit.colors.coral else Kit.colors.paper
			end
		end)
		control:setState("Default")
		table.insert(scope.controls, control)
		return control
	end
	function scope:destroy()
		for _, tween in self.tweens do
			tween:Cancel()
		end
		for _, c in self.connections do
			c:Disconnect()
		end
		table.clear(self.connections)
		table.clear(self.tweens)
		table.clear(self.controls)
	end
	return scope
end
function Kit.panel(parent: Instance, name: string): Frame
	local f = Kit.frame(parent, name, Kit.colors.paper)
	Kit.round(f, 18)
	Kit.outline(f)
	return f
end
function Kit.currency(parent: Instance, coins: number): Frame
	local f = Kit.panel(parent, "Currency")
	local coin = Kit.frame(f, "Coin", Kit.colors.yellow)
	coin.AnchorPoint = Vector2.new(0, 0.5)
	coin.Position = UDim2.new(0, 10, 0.5, 0)
	coin.Size = UDim2.fromOffset(28, 28)
	Kit.round(coin, 99)
	Kit.outline(coin)
	local t = Kit.text(f, "Balance", tostring(coins) .. " COINS", 20)
	t.Position = UDim2.fromOffset(44, 0)
	t.Size = UDim2.new(1, -52, 1, 0)
	return f
end
return Kit
