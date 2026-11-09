--!strict
local UIS = game:GetService("UserInputService")
local Input = {}
function Input.new(left: GuiButton, right: GuiButton)
	local controller: any = { enabled = false, held = {}, connections = {}, axis = 0 }
	local function connect(signal: any, fn: any)
		table.insert(controller.connections, signal:Connect(fn))
	end
	function controller:clear()
		table.clear(controller.held)
		controller.axis = 0
	end
	local function direction(key: Enum.KeyCode)
		if key == Enum.KeyCode.A or key == Enum.KeyCode.Left or key == Enum.KeyCode.DPadLeft then
			return -1
		end
		if key == Enum.KeyCode.D or key == Enum.KeyCode.Right or key == Enum.KeyCode.DPadRight then
			return 1
		end
		return nil
	end
	connect(UIS.InputBegan, function(i, processed)
		local turn = direction(i.KeyCode)
		if not processed and controller.enabled and turn then
			controller.held[i.KeyCode] = turn
		end
	end)
	connect(UIS.InputEnded, function(i)
		controller.held[i.KeyCode] = nil
		controller.held[i] = nil
	end)
	connect(UIS.InputChanged, function(i)
		if i.KeyCode == Enum.KeyCode.Thumbstick1 then
			controller.axis = if math.abs(i.Position.X) > 0.35 then math.sign(i.Position.X) else 0
		end
	end)
	for _, pair in { { left, -1 }, { right, 1 } } do
		connect(pair[1].InputBegan, function(i)
			if
				controller.enabled
				and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1)
			then
				controller.held[i] = pair[2]
			end
		end)
	end
	connect(UIS.WindowFocusReleased, function()
		controller:clear()
	end)
	connect(UIS.TextBoxFocused, function()
		controller:clear()
	end)
	connect(game:GetService("GuiService").MenuOpened, function()
		controller:clear()
		controller.suspended = true
	end)
	connect(game:GetService("GuiService").MenuClosed, function()
		controller.suspended = false
	end)
	function controller:value()
		if not controller.enabled or controller.suspended then
			return 0
		end
		local l, r = controller.axis < 0, controller.axis > 0
		for _, v in controller.held do
			if v < 0 then
				l = true
			else
				r = true
			end
		end
		return if l == r then 0 elseif l then -1 else 1
	end
	function controller:destroy()
		controller:clear()
		for _, c in controller.connections do
			c:Disconnect()
		end
	end
	return controller
end
return Input
