--!strict
local started = os.clock()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local Shared = ReplicatedStorage:WaitForChild("TrailWars")
local Catalog = require(Shared.Catalog)
local Config = require(Shared.Config)
local W = require(script.Parent.Widgets)
local player = Players.LocalPlayer
local screen = Instance.new("ScreenGui")
screen.Name = "TrailWarsWireframe"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
screen.Parent = player:WaitForChild("PlayerGui")
local root = Instance.new("Frame")
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.new(1, -24, 1, -24)
root.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
root.BorderSizePixel = 0
root.Parent = screen
local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize = Vector2.new(1000, 1400)
constraint.Parent = root
local padding = Instance.new("UIPadding")
padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
padding.PaddingTop, padding.PaddingBottom = UDim.new(0, 12), UDim.new(0, 12)
padding.Parent = root

local route = "Home"
local history: { string } = {}
local profile: any = nil
local mock = RunService:IsStudio() and Config.EnableStudioMock
local message = "Loading profile…"
local pending = false
local requestId = 0
local needsReconciliation = false
local unresolvedWrites = 0
local modal: any = nil
local modalOpener: string? = nil
local generation = 0
local phase = "Queue"
local telemetry = { initializationMs = 0, navigations = 0, lastNavigationMs = 0, maxNavigationMs = 0 }
local render: () -> ()
local navigate: (string, boolean?) -> ()
local request: (any, ((boolean, string) -> ())?) -> ()
local back: () -> ()
local body: ScrollingFrame
local steering: TextLabel? = nil
local steeringKeys: { [Enum.KeyCode]: boolean } = {}
local pointerSteering: { [InputObject]: string } = {}
local selectionPulse: { [string]: boolean } = {}
local persistent: { RBXScriptConnection } = {}

local function header(title: string)
	W.text(body, title, 56, 26)
end
local function button(text: string, callback: () -> (), disabled: boolean?)
	return W.button(body, text, callback, disabled)
end
local function statusText(): string
	if profile then return string.format("%d earned coins · %d XP · %d rounds · %d wins", profile.coins, profile.xp, profile.stats.rounds, profile.stats.wins) end
	return "Profile unavailable. No balance or progress is assumed."
end
local function itemDetails(item: any, opener: GuiButton?)
	modalOpener = if opener then opener.Name else nil
	modal = { kind = "item", item = item }
	render()
end
local function updateSteering()
	if not steering then return end
	local left = steeringKeys[Enum.KeyCode.A] or steeringKeys[Enum.KeyCode.Left] or steeringKeys[Enum.KeyCode.DPadLeft]
	local right = steeringKeys[Enum.KeyCode.D] or steeringKeys[Enum.KeyCode.Right] or steeringKeys[Enum.KeyCode.DPadRight]
	left = left or selectionPulse.LEFT
	right = right or selectionPulse.RIGHT
	for _, side in pointerSteering do
		if side == "LEFT" then left = true else right = true end
	end
	steering.Text = if left and right then "Both held · neutral" elseif left then "Steer LEFT" elseif right then "Steer RIGHT" else "Try steering left or right"
end
local function showControls()
	W.text(body, "Steer left or right. Your trail becomes a wall. Don't crash. Last survivor wins.", 84, 19)
	W.text(body, "Keyboard: A / D or ← / →. Controller: D-pad left / right. Touch: hold either button below.", 74)
	steering = W.text(body, "Try steering left or right", 48, 20)
	local row = W.frame(body, "TouchSteering", 66)
	for index, side in { "LEFT", "RIGHT" } do
		local control = W.button(row, side, function()
			local last = UserInputService:GetLastInputType()
			if last == Enum.UserInputType.Touch or last == Enum.UserInputType.MouseButton1 then return end
			selectionPulse[side] = true; updateSteering()
			local token = generation
			task.delay(0.25, function()
				if token ~= generation then return end
				selectionPulse[side] = nil; updateSteering()
			end)
		end)
		control.Size = UDim2.new(0.5, -6, 1, 0)
		control.Position = UDim2.new((index - 1) * 0.5, if index == 1 then 0 else 6, 0, 0)
		W.connect(control.InputBegan, function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				pointerSteering[input] = side; updateSteering()
			end
		end)
		W.connect(control.InputEnded, function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				pointerSteering[input] = nil; updateSteering()
			end
		end)
	end
	W.text(body, "Input demonstration only. No core moves and no collision simulation runs.", 60)
end
local function renderHome()
	header("TRAIL WARS · interaction prototype")
	W.text(body, "One mode. Left/right steering. Short rounds and a quick return to play are proposed for the future game.", 76)
	button("Play · controls and mock flow", function() navigate("Tutorial") end)
	button("Customize your core and trail", function() navigate("Customize") end)
	W.text(body, statusText(), 74)
	button("Profile and progress", function() navigate("Profile") end)
	button("Retry profile connection", function() request({ action = "Snapshot" }) end, pending)
end
local function renderInventory(shop: boolean)
	header(if shop then "Shop · earned cosmetics" else "Customize")
	W.text(body, statusText(), 66)
	if shop then W.text(body, "Preview original geometric cosmetics. Costs are provisional earned-coin hypotheses. No real-money products are configured.", 88) end
	for _, item in Catalog.Items do
		if not shop or item.earnedCost then
			local owned = profile and profile.owned[item.id] == true
			local equipped = profile and profile.equipped[item.slot] == item.id
			local state = if equipped then "Equipped" elseif owned then "Owned" elseif item.earnedCost then tostring(item.earnedCost) .. " earned coins" else "Locked"
			local card: TextButton? = nil
			card = button(item.name .. " · " .. state, function() itemDetails(item, card) end)
			card.Name = "Item_" .. item.id
		end
	end
	if shop then
		button("Robux purchases unavailable · no configured products", function() end, true)
		W.text(body, "No paid random items, combat advantages, paid powers, timers or subscription are included.", 70)
	end
end
local function renderSettings()
	header("Settings and controls")
	button("Review steering controls", function() navigate("Tutorial") end)
	if not profile then W.text(body, "Connect a profile before saving settings.", 64); return end
	local settings = profile.settings
	local function setting(name: string, value: any)
		request({ action = "SetSetting", setting = name, value = value })
	end
	button("Music volume: " .. math.floor(settings.music * 100) .. "% · toggle", function() setting("music", if settings.music > 0 then 0 else 0.5) end, pending)
	button("Sound volume: " .. math.floor(settings.sound * 100) .. "% · toggle", function() setting("sound", if settings.sound > 0 then 0 else 0.7) end, pending)
	W.text(body, "Audio preferences persist; this wireframe contains no music or sound assets.", 64)
	button("Reduced motion: " .. (if settings.reducedMotion then "On" else "Off"), function() setting("reducedMotion", not settings.reducedMotion) end, pending)
	button("Text size: " .. math.floor(settings.textScale * 100) .. "% · cycle", function()
		setting("textScale", if settings.textScale < 1.25 then 1.25 elseif settings.textScale < 1.5 then 1.5 else 1)
	end, pending)
	W.text(body, "Navigation uses instant transitions. Keyboard: Tab / Shift+Tab and Enter; gamepad: D-pad and A; Escape / B returns or closes details.", 96)
end
local function renderDemo()
	header("Mock match flow · " .. phase)
	W.text(body, "LOCAL UI DEMONSTRATION · no opponents, matchmaking, trail collisions, statistics or rewards are created.", 84)
	if phase == "Queue" then
		W.text(body, "Queue state preview. A real queue service is not connected.", 68)
		button("Advance demo → countdown", function() phase = "Countdown"; render() end)
	elseif phase == "Countdown" then
		W.text(body, "3 · 2 · 1 — countdown layout preview, controlled by you.", 72, 22)
		button("Advance demo → match HUD", function() phase = "HUD"; render() end)
	elseif phase == "HUD" then
		W.text(body, "ROUND PREVIEW · timer --:-- · survivors -- · no live data", 70, 20)
		showControls()
		button("Simulate elimination → spectator", function() phase = "Spectator"; render() end)
		button("Simulate round end → results", function() phase = "Results"; render() end)
	elseif phase == "Spectator" then
		W.text(body, "Elimination preview. You would now follow surviving players. No real match is active.", 84)
		button("Advance demo → results", function() phase = "Results"; render() end)
	elseif phase == "Results" then
		W.text(body, "Round complete preview. Winner: —. No XP, coins or wins were awarded by this demonstration.", 90, 20)
		button("Rematch · restart mock queue", function() phase = "Queue"; render() end)
	end
	button("Leave mock flow → Home", function() navigate("Home") end)
end
local function renderModal()
	local data = modal
	if not data then return end
	header(if data.kind == "confirm" then "Confirm earned purchase" else "Cosmetic details")
	local item = data.item
	W.text(body, item.name, 56, 23)
	W.preview(body, item)
	W.text(body, "Static 2D preview · cosmetic appearance only. No gameplay statistics change.", 64)
	if data.kind == "confirm" then
		W.text(body, "Spend " .. tostring(item.earnedCost) .. " earned coins?", 56)
		button(if pending then "Purchase pending…" else "Confirm purchase", function()
			request({ action = "BuyEarned", itemId = item.id }, function(ok: boolean, code: string)
				message = if ok then "Purchased. You can now equip this cosmetic." else "Purchase was not completed: " .. code
				modal = { kind = "item", item = item }
			end)
		end, pending or profile == nil)
		button("Cancel · return to item", function() modal = { kind = "item", item = item }; render() end, pending)
		return
	end
	local owned = profile and profile.owned[item.id] == true
	local equipped = profile and profile.equipped[item.slot] == item.id
	if owned then
		button(if equipped then "Currently equipped" else "Equip " .. item.name, function()
			request({ action = "Equip", itemId = item.id })
		end, equipped or pending)
	elseif item.earnedCost then
		local enough = profile and profile.coins >= item.earnedCost
		W.text(body, tostring(item.earnedCost) .. " earned coins · " .. (if not profile then "profile unavailable" elseif enough then "available" else "insufficient funds"), 66)
		button("Review purchase", function() modal = { kind = "confirm", item = item }; render() end, not enough or pending)
	else
		button("Item unavailable", function() end, true)
	end
	button("Close details", function() modal = nil; render() end, pending)
end
render = function()
	local before = os.clock()
	local selectedBefore = GuiService.SelectedObject
	local focusName = if selectedBefore then selectedBefore.Name else nil
	if not modal and modalOpener then focusName = modalOpener; modalOpener = nil end
	generation += 1
	W.clear()
	steering = nil
	table.clear(steeringKeys)
	table.clear(pointerSteering)
	table.clear(selectionPulse)
	for _, child in root:GetChildren() do if child:IsA("GuiObject") then child:Destroy() end end
	W.scale = if profile then profile.settings.textScale else 1
	local notice = W.text(root, "PROVISIONAL WIREFRAME · " .. (if mock then "STUDIO MOCK DATA" else "NO LIVE GAMEPLAY"), 48, 12)
	notice.Position = UDim2.fromOffset(0, 0)
	local nav = W.frame(root, "Navigation", 54)
	nav.Position = UDim2.fromOffset(0, 48)
	for index, destination in { "Home", "Customize", "Shop", "Settings" } do
		local navButton = W.button(nav, destination, function() navigate(destination) end, modal ~= nil)
		navButton.Size = UDim2.new(0.25, -6, 1, 0)
		navButton.Position = UDim2.new((index - 1) * 0.25, 0, 0, 0)
	end
	local backButton = W.button(root, "← Back / close", back)
	backButton.Position = UDim2.fromOffset(0, 114)
	backButton.Size = UDim2.new(1, 0, 0, 48)
	body = Instance.new("ScrollingFrame")
	body.Name = "ScreenContent"
	body.Position = UDim2.fromOffset(0, 174)
	body.Size = UDim2.new(1, 0, 1, -186)
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.ScrollBarThickness = 6
	body.AutomaticCanvasSize = Enum.AutomaticSize.Y
	body.CanvasSize = UDim2.new()
	body.ScrollingDirection = Enum.ScrollingDirection.Y
	body.Parent = root
	local bodyPadding = Instance.new("UIPadding")
	bodyPadding.PaddingRight = UDim.new(0, 12)
	bodyPadding.PaddingBottom = UDim.new(0, 16)
	bodyPadding.Parent = body
	W.list(body, 12)
	W.text(body, message, 64, 14)
	if needsReconciliation then button("Refresh profile to reconcile pending action", function() request({ action = "Snapshot" }) end, pending) end
	if modal then renderModal()
	elseif route == "Home" then renderHome()
	elseif route == "Customize" then renderInventory(false)
	elseif route == "Shop" then renderInventory(true)
	elseif route == "Settings" then renderSettings()
	elseif route == "Tutorial" then
		header("Two directions. Keep moving.")
		showControls()
		button("Start interactive mock flow", function() phase = "Queue"; navigate("Demo") end)
	elseif route == "Demo" then renderDemo()
	elseif route == "Profile" then
		header("Profile and progression")
		W.text(body, statusText(), 100, 20)
		W.text(body, "Only confirmed server profile data appears here. Match rewards are unavailable until authoritative gameplay exists. No battle pass, daily pressure or ranked system is configured.", 124)
	end
	local restored = false
	if focusName then
		for _, candidate in W.buttons do
			if candidate.Name == focusName then GuiService.SelectedObject = candidate; restored = true; break end
		end
	end
	if not restored and modal then
		GuiService.SelectedObject = W.buttons[2] or W.firstButton
	elseif not restored and UserInputService.GamepadEnabled then GuiService.SelectedObject = W.firstButton end
	local elapsed = (os.clock() - before) * 1000
	telemetry.lastNavigationMs = elapsed
	telemetry.maxNavigationMs = math.max(telemetry.maxNavigationMs, elapsed)
	screen:SetAttribute("LastNavigationMs", elapsed)
	screen:SetAttribute("MaxNavigationMs", telemetry.maxNavigationMs)
	screen:SetAttribute("CurrentRoute", if modal then "Details" else route)
end
navigate = function(destination: string, replace: boolean?)
	if pending then message = "Wait for the current request to finish."; render(); return end
	modal = nil
	if destination ~= route then
		if not replace then table.insert(history, route) end
		if #history > 20 then table.remove(history, 1) end
		route = destination
		telemetry.navigations += 1
	end
	render()
end
back = function()
	if pending then message = "Request pending. Wait for server confirmation."; render(); return end
	if modal then modal = nil; render(); return end
	route = table.remove(history) or "Home"
	render()
end
request = function(payload: any, callback: ((boolean, string) -> ())?)
	if pending then return end
	if needsReconciliation and payload.action ~= "Snapshot" then
		message = "Refresh the profile first; the previous request outcome is unknown."; render(); return
	end
	requestId += 1
	local thisRequest = requestId
	local isWrite = payload.action ~= "Snapshot"
	if isWrite then unresolvedWrites += 1 end
	pending = true
	message = "Waiting for server…"
	render()
	task.delay(15, function()
		if thisRequest ~= requestId or not pending or not screen.Parent then return end
		requestId += 1 -- A late response must not overwrite a later confirmed state.
		pending = false
		needsReconciliation = true
		message = "Server confirmation timed out. Outcome unknown; refresh your profile before another action."
		render()
	end)
	task.spawn(function()
		local remote = Shared:WaitForChild("TrailWarsRequest", 10)
		local success, response = pcall(function()
			if not remote or not remote:IsA("RemoteFunction") then error("Remote unavailable") end
			return remote:InvokeServer(payload)
		end)
		if isWrite then unresolvedWrites -= 1 end
		if not screen.Parent then return end
		if thisRequest ~= requestId then
			if isWrite and needsReconciliation then
				message = "A late server request finished. Refresh your profile to confirm the outcome."
				render()
			end
			return
		end
		pending = false
		local ok = success and type(response) == "table" and response.ok == true
		local code = if success and type(response) == "table" then tostring(response.code) else "CONNECTION_FAILED"
		if success and type(response) == "table" then
			if response.profile then profile = response.profile end
			mock = response.isMock == true
			if ok and payload.action == "Snapshot" and unresolvedWrites == 0 then needsReconciliation = false end
		end
		if not success then needsReconciliation = true end
		message = if ok then (if code == "OK" then "Profile connected." else code) else "Action unavailable: " .. code
		if ok and payload.action == "Snapshot" and unresolvedWrites > 0 then
			message = "Profile refreshed, but a previous write is still pending. Wait for completion, then refresh again."
		end
		if callback then callback(ok, code) end
		render()
	end)
end

table.insert(persistent, UserInputService.InputBegan:Connect(function(input: InputObject, consumed: boolean)
	if consumed then return end
	if input.KeyCode == Enum.KeyCode.Tab then
		local index = table.find(W.buttons, GuiService.SelectedObject) or 0
		local direction = if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then -1 else 1
		if #W.buttons > 0 then GuiService.SelectedObject = W.buttons[(index - 1 + direction) % #W.buttons + 1] end
		return
	elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
		local selected = GuiService.SelectedObject
		if selected and W.callbacks[selected] then W.callbacks[selected](); return end
	end
	steeringKeys[input.KeyCode] = true
	updateSteering()
end))
table.insert(persistent, UserInputService.InputEnded:Connect(function(input: InputObject)
	steeringKeys[input.KeyCode] = nil
	pointerSteering[input] = nil
	updateSteering()
end))
table.insert(persistent, UserInputService.WindowFocusReleased:Connect(function()
	table.clear(steeringKeys); table.clear(pointerSteering); table.clear(selectionPulse); updateSteering()
end))
ContextActionService:BindAction("TrailWarsBack", function(_, state)
	if state == Enum.UserInputState.Begin then back() end
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.Escape, Enum.KeyCode.ButtonB)
table.insert(persistent, screen.Destroying:Connect(function()
	W.clear()
	ContextActionService:UnbindAction("TrailWarsBack")
	for _, connection in persistent do connection:Disconnect() end
end))
render()
telemetry.initializationMs = (os.clock() - started) * 1000
screen:SetAttribute("InitializationMs", telemetry.initializationMs)
screen:SetAttribute("MetricsScope", "Client GUI construction CPU time only; excludes profile network and rendering")
print(string.format("[TrailWars] GUI constructed in %.2fms; provisional wireframe, gameplay mock only", telemetry.initializationMs))
request({ action = "Snapshot" })
