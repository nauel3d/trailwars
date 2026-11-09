--!strict
local App = {}
function App.mount(target: Instance, options: any?)
	options = options or {}
	local started = os.clock()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local GuiService = game:GetService("GuiService")
	local ContextActionService = game:GetService("ContextActionService")
	local Shared = ReplicatedStorage:WaitForChild("TrailWars")
	local Catalog = require(Shared.Catalog)
	local Config = require(Shared.Config)
	local Theme = require(script.Parent.Theme)
	local W = require(script.Parent.Widgets).new()
	local screen: any
	if target:IsA("PlayerGui") then
		screen = Instance.new("ScreenGui")
		screen.ResetOnSpawn = false
		screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screen.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	else
		screen = Instance.new("Frame")
		screen.Size = UDim2.fromScale(1, 1)
		screen.BorderSizePixel = 0
		screen.BackgroundColor3 = Theme.Background
	end
	screen.Name = "TrailWarsUI"
	screen.Parent = target
	local backdrop = Instance.new("Frame")
	backdrop.Name = "ArcadeBackdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Theme.Background
	backdrop.BorderSizePixel = 0
	backdrop.Parent = screen
	local root = Instance.new("Frame")
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.new(1, -24, 1, -24)
	root.BackgroundColor3 = Theme.Background
	root.BorderSizePixel = 0
	root.Parent = screen
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(1200, 1800)
	constraint.Parent = root
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
	padding.PaddingTop, padding.PaddingBottom = UDim.new(0, 12), UDim.new(0, 12)
	padding.Parent = root

	local route = options.initialRoute or "Home"
	local history: { string } = {}
	local profile: any = options.profile
	local mock = options.preview == true or (RunService:IsStudio() and Config.EnableStudioMock)
	local message = if options.profile
		then "Preview data · changes stay in this story"
		else "Connecting your profile…"
	local pending = false
	local requestId = 0
	local needsReconciliation = false
	local unresolvedWrites = 0
	local modal: any = if options.initialItem
		then { kind = if options.confirmPurchase then "confirm" else "item", item = Catalog.ById[options.initialItem] }
		else nil
	local modalOpener: string? = nil
	local generation = 0
	local phase = options.initialPhase or "Queue"
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
		if profile then
			return string.format(
				"%d earned coins · %d XP · %d rounds · %d wins",
				profile.coins,
				profile.xp,
				profile.stats.rounds,
				profile.stats.wins
			)
		end
		return "Profile unavailable. No balance or progress is assumed."
	end
	local function itemDetails(item: any, opener: GuiButton?)
		modalOpener = if opener then opener.Name else nil
		modal = { kind = "item", item = item }
		render()
	end
	local function updateSteering()
		if not steering then
			return
		end
		local left = steeringKeys[Enum.KeyCode.A]
			or steeringKeys[Enum.KeyCode.Left]
			or steeringKeys[Enum.KeyCode.DPadLeft]
		local right = steeringKeys[Enum.KeyCode.D]
			or steeringKeys[Enum.KeyCode.Right]
			or steeringKeys[Enum.KeyCode.DPadRight]
		left = left or selectionPulse.LEFT
		right = right or selectionPulse.RIGHT
		for _, side in pointerSteering do
			if side == "LEFT" then
				left = true
			else
				right = true
			end
		end
		steering.Text = if left and right
			then "Both held · neutral"
			elseif left then "Steer LEFT"
			elseif right then "Steer RIGHT"
			else "Try steering left or right"
	end
	local function showControls()
		W.text(body, "Steer left or right. Your trail becomes a wall. Last survivor wins.", 84, 19)
		W.text(body, "A / D or ← / → on keyboard. D-pad on controller. Hold a side on touch.", 74)
		steering = W.text(body, "Try steering left or right", 48, 20)
		local row = W.frame(body, "TouchSteering", 66)
		for index, side in { "LEFT", "RIGHT" } do
			local control = W.button(row, side, function()
				local last = UserInputService:GetLastInputType()
				if last == Enum.UserInputType.Touch or last == Enum.UserInputType.MouseButton1 then
					return
				end
				selectionPulse[side] = true
				updateSteering()
				local token = generation
				task.delay(0.25, function()
					if token ~= generation then
						return
					end
					selectionPulse[side] = nil
					updateSteering()
				end)
			end)
			control.Size = UDim2.new(0.5, -6, 1, 0)
			control.Position = UDim2.new((index - 1) * 0.5, if index == 1 then 0 else 6, 0, 0)
			W.connect(control.InputBegan, function(input: InputObject)
				if
					input.UserInputType == Enum.UserInputType.Touch
					or input.UserInputType == Enum.UserInputType.MouseButton1
				then
					pointerSteering[input] = side
					updateSteering()
				end
			end)
			W.connect(control.InputEnded, function(input: InputObject)
				if
					input.UserInputType == Enum.UserInputType.Touch
					or input.UserInputType == Enum.UserInputType.MouseButton1
				then
					pointerSteering[input] = nil
					updateSteering()
				end
			end)
		end
		W.text(body, "Input preview · try both buttons. Gameplay is still in development.", 60)
	end
	local function renderHome()
		W.hero(body)
		local play = button("PLAY  →", function()
			navigate("Tutorial")
		end)
		W.primary(play)
		W.text(body, "Steer left or right. Your trail becomes a wall. Don't crash.", 54, 18)
		local row = W.frame(body, "HomeLinks", 54)
		for index, entry in { { "YOUR LOOK", "Customize" }, { "YOUR PROGRESS", "Profile" } } do
			local b = W.button(row, entry[1], function()
				navigate(entry[2])
			end)
			b.Size = UDim2.new(0.5, -5, 1, 0)
			b.Position = UDim2.new((index - 1) * 0.5, if index == 1 then 0 else 5, 0, 0)
		end
	end
	local function renderInventory(shop: boolean)
		header(if shop then "Make it yours." else "Your signature.")
		W.text(
			body,
			if shop
				then "Direct unlocks. All style. Equal footing."
				else "Choose a core and a trail. Your look never changes the rules.",
			58
		)
		local grid = W.frame(body, "CosmeticGrid", 280)
		local layout = Instance.new("UIGridLayout")
		layout.CellPadding = UDim2.fromOffset(14, 14)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = grid
		local function arrange()
			local width = math.max(grid.AbsoluteSize.X, 1)
			local columns = if width >= 820 then 3 elseif width >= 500 then 2 else 1
			layout.CellSize =
				UDim2.fromOffset(math.floor((width - (columns - 1) * 14) / columns), math.floor(230 * W.scale))
			grid.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
		end
		W.connect(grid:GetPropertyChangedSignal("AbsoluteSize"), arrange)
		W.connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), arrange)
		for _, item in Catalog.Items do
			if not shop or item.earnedCost then
				local owned = profile and profile.owned[item.id] == true
				local equipped = profile and profile.equipped[item.slot] == item.id
				local state = if equipped
					then "EQUIPPED"
					elseif owned then "OWNED"
					elseif item.earnedCost then tostring(item.earnedCost) .. " COINS"
					else "LOCKED"
				local card: TextButton? = nil
				card = W.card(grid, item, state, function()
					itemDetails(item, card)
				end)
			end
		end
		task.defer(arrange)
		if shop then
			W.text(body, "Robux collection · coming later", 44, 20)
			W.text(body, "Paid items are not available yet. No purchase prompt will open.", 60)
			button("PAID ITEMS UNAVAILABLE", function() end, true)
		end
	end
	local function renderSettings()
		header("Find your flow.")
		button("Review steering controls", function()
			navigate("Tutorial")
		end)
		if not profile then
			W.text(body, "Connect a profile before saving settings.", 64)
			return
		end
		local settings = profile.settings
		local function setting(name: string, value: any)
			request({ action = "SetSetting", setting = name, value = value })
		end
		button("Music volume: " .. math.floor(settings.music * 100) .. "% · toggle", function()
			setting("music", if settings.music > 0 then 0 else 0.5)
		end, pending)
		button("Sound volume: " .. math.floor(settings.sound * 100) .. "% · toggle", function()
			setting("sound", if settings.sound > 0 then 0 else 0.7)
		end, pending)
		W.text(body, "Audio preferences are saved. Sound assets are still in development.", 64)
		button("Reduced motion: " .. (if settings.reducedMotion then "On" else "Off"), function()
			setting("reducedMotion", not settings.reducedMotion)
		end, pending)
		button("Text size: " .. math.floor(settings.textScale * 100) .. "% · cycle", function()
			setting("textScale", if settings.textScale < 1.25 then 1.25 elseif settings.textScale < 1.5 then 1.5 else 1)
		end, pending)
		W.text(body, "Tab and Enter to navigate. D-pad and A on controller. Escape or B to go back.", 96)
	end
	local function renderDemo()
		header(
			if phase == "Queue"
				then "Finding your next round."
				elseif phase == "Countdown" then "Get ready."
				elseif phase == "HUD" then "Stay in the running."
				elseif phase == "Spectator" then "Still in the action."
				else "One more round?"
		)
		W.text(body, "MOCK ROUND · Preview the flow. No real match or rewards.", 84)
		if phase == "Queue" then
			W.text(body, "A new round starts here. Matchmaking is not connected yet.", 68)
			button("PREVIEW COUNTDOWN →", function()
				phase = "Countdown"
				render()
			end)
		elseif phase == "Countdown" then
			W.text(body, "03", 120, 80)
			W.text(body, "Find your space. The round starts next.", 54, 20)
			button("PREVIEW MATCH →", function()
				phase = "HUD"
				render()
			end)
		elseif phase == "HUD" then
			W.text(body, "ROUND PREVIEW · timer --:-- · survivors -- · no live data", 70, 20)
			W.arena(body)
			showControls()
			button("Simulate elimination → spectator", function()
				phase = "Spectator"
				render()
			end)
			button("Simulate round end → results", function()
				phase = "Results"
				render()
			end)
		elseif phase == "Spectator" then
			W.arena(body)
			W.text(body, "Elimination preview. You would now follow surviving players. No real match is active.", 84)
			button("VIEW RESULTS →", function()
				phase = "Results"
				render()
			end)
		elseif phase == "Results" then
			W.text(
				body,
				"ROUND COMPLETE\nWinner —  ·  XP +0  ·  Coins +0\nMock preview: no rewards were granted.",
				90,
				20
			)
			W.primary(button("REMATCH →", function()
				phase = "Queue"
				render()
			end))
		end
		button("LEAVE ROUND", function()
			navigate("Home")
		end)
	end
	local function renderModal()
		local data = modal
		if not data then
			return
		end
		header(if data.kind == "confirm" then "Your next signature." else "A closer look.")
		local item = data.item
		W.text(body, item.name, 56, 23)
		W.preview(body, item)
		W.text(body, "Cosmetic only. Same speed. Same collision boundary.", 64)
		if data.kind == "confirm" then
			W.text(body, "Spend " .. tostring(item.earnedCost) .. " earned coins?", 56)
			button(if pending then "Purchase pending…" else "Confirm purchase", function()
				request({ action = "BuyEarned", itemId = item.id }, function(ok: boolean, code: string)
					message = if ok
						then "Purchased. You can now equip this cosmetic."
						else "Purchase was not completed: " .. code
					modal = { kind = "item", item = item }
				end)
			end, pending or profile == nil)
			button("Cancel · return to item", function()
				modal = { kind = "item", item = item }
				render()
			end, pending)
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
			W.text(
				body,
				tostring(item.earnedCost)
					.. " earned coins · "
					.. (
						if not profile
							then "profile unavailable"
							elseif enough then "available"
							else "insufficient funds"
					),
				66
			)
			button("UNLOCK WITH COINS →", function()
				modal = { kind = "confirm", item = item }
				render()
			end, not enough or pending)
		else
			button("Item unavailable", function() end, true)
		end
		button("Close details", function()
			modal = nil
			render()
		end, pending)
	end
	render = function()
		local before = os.clock()
		local selectedBefore = GuiService.SelectedObject
		if selectedBefore and not selectedBefore:IsDescendantOf(screen) then
			selectedBefore = nil
		end
		local focusName = if selectedBefore then selectedBefore.Name else nil
		if not modal and modalOpener then
			focusName = modalOpener
			modalOpener = nil
		end
		generation += 1
		W.clear()
		steering = nil
		table.clear(steeringKeys)
		table.clear(pointerSteering)
		table.clear(selectionPulse)
		for _, child in root:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		W.scale = if profile then profile.settings.textScale else 1
		W.reducedMotion = profile and profile.settings.reducedMotion == true
		local wordmark = W.label(root, "TRAIL / WARS", 22, Theme.Text)
		wordmark.Size = UDim2.new(0.6, 0, 0, 48)
		local profileLink = W.button(root, "PROFILE ↗", function()
			navigate("Profile")
		end, modal ~= nil)
		profileLink.Size = UDim2.new(0.35, 0, 0, 48)
		profileLink.TextSize = 12 * W.scale
		profileLink.Position = UDim2.fromScale(0.65, 0)
		local nav = W.frame(root, "Navigation", 52)
		nav.Position = UDim2.new(0, 0, 1, -56)
		for index, destination in { "Home", "Customize", "Shop", "Settings" } do
			local navButton = W.button(nav, destination, function()
				navigate(destination)
			end, modal ~= nil)
			navButton.Size = UDim2.new(0.25, -6, 1, 0)
			navButton.Position = UDim2.fromScale((index - 1) * 0.25, 0)
			navButton.TextSize = 13 * W.scale
			local navPadding = navButton:FindFirstChildOfClass("UIPadding")
			if navPadding then
				navPadding.PaddingLeft = UDim.new(0, 4)
				navPadding.PaddingRight = UDim.new(0, 4)
			end
			if destination == route then
				W.selected(navButton)
			end
		end
		local backButton = W.button(
			root,
			if modal
				then "← CLOSE DETAILS"
				elseif route == "Home" then (if mock then "MOCK SESSION · PROFILE DATA" else "SESSION STATUS")
				else "← BACK",
			back
		)
		backButton.Position = UDim2.fromOffset(0, 54)
		backButton.Size = UDim2.new(1, 0, 0, 48)
		body = Instance.new("ScrollingFrame")
		body.Name = "ScreenContent"
		body.Position = UDim2.fromOffset(0, 114)
		body.Size = UDim2.new(1, 0, 1, -182)
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
		W.text(body, (if mock then "MOCK · " else "") .. message, 38, 13)
		if not profile and not needsReconciliation then
			button("RETRY PROFILE CONNECTION", function()
				request({ action = "Snapshot" })
			end, pending)
		end
		if route ~= "Home" and not modal then
			W.text(body, statusText(), 44, 13)
		end
		if needsReconciliation then
			button("Refresh profile to reconcile pending action", function()
				request({ action = "Snapshot" })
			end, pending)
		end
		if modal then
			renderModal()
		elseif route == "Home" then
			renderHome()
		elseif route == "Customize" then
			renderInventory(false)
		elseif route == "Shop" then
			renderInventory(true)
		elseif route == "Settings" then
			renderSettings()
		elseif route == "Tutorial" then
			header("Two directions.\nEndless possibilities.")
			showControls()
			button("FIND A ROUND · MOCK →", function()
				phase = "Queue"
				navigate("Demo")
			end)
		elseif route == "Demo" then
			renderDemo()
		elseif route == "Profile" then
			header("Your trail so far.")
			W.text(body, statusText(), 100, 20)
			W.text(
				body,
				"Your confirmed progress lives here. New rounds will add rewards when gameplay is connected.",
				124
			)
		end
		if not options.preview then
			local restored = false
			if focusName then
				for _, candidate in W.buttons do
					if candidate.Name == focusName then
						GuiService.SelectedObject = candidate
						restored = true
						break
					end
				end
			end
			if not restored and modal then
				GuiService.SelectedObject = W.buttons[2] or W.firstButton
			elseif not restored and UserInputService.GamepadEnabled then
				GuiService.SelectedObject = W.firstButton
			end
		end
		local elapsed = (os.clock() - before) * 1000
		telemetry.lastNavigationMs = elapsed
		telemetry.maxNavigationMs = math.max(telemetry.maxNavigationMs, elapsed)
		screen:SetAttribute("LastNavigationMs", elapsed)
		screen:SetAttribute("MaxNavigationMs", telemetry.maxNavigationMs)
		screen:SetAttribute("CurrentRoute", if modal then "Details" else route)
	end
	navigate = function(destination: string, replace: boolean?)
		if pending then
			message = "Wait for the current request to finish."
			render()
			return
		end
		modal = nil
		if destination ~= route then
			if not replace then
				table.insert(history, route)
			end
			if #history > 20 then
				table.remove(history, 1)
			end
			route = destination
			telemetry.navigations += 1
		end
		render()
	end
	back = function()
		if pending then
			message = "Request pending. Wait for server confirmation."
			render()
			return
		end
		if modal then
			modal = nil
			render()
			return
		end
		route = table.remove(history) or "Home"
		render()
	end
	request = function(payload: any, callback: ((boolean, string) -> ())?)
		if pending then
			return
		end
		if needsReconciliation and payload.action ~= "Snapshot" then
			message = "Refresh the profile first; the previous request outcome is unknown."
			render()
			return
		end
		requestId += 1
		local thisRequest = requestId
		local isWrite = payload.action ~= "Snapshot"
		if isWrite then
			unresolvedWrites += 1
		end
		pending = true
		message = "Waiting for server…"
		render()
		task.delay(15, function()
			if thisRequest ~= requestId or not pending or not screen.Parent then
				return
			end
			requestId += 1 -- A late response must not overwrite a later confirmed state.
			pending = false
			needsReconciliation = true
			message = "Server confirmation timed out. Outcome unknown; refresh your profile before another action."
			render()
		end)
		task.spawn(function()
			local success, response = pcall(function()
				if options.transport then
					return options.transport(payload)
				end
				if options.preview then
					error("Preview transport missing")
				end
				local remote = Shared:WaitForChild("TrailWarsRequest", 10)
				if not remote or not remote:IsA("RemoteFunction") then
					error("Remote unavailable")
				end
				return remote:InvokeServer(payload)
			end)
			if isWrite then
				unresolvedWrites -= 1
			end
			if not screen.Parent then
				return
			end
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
				if response.profile then
					profile = response.profile
				end
				mock = response.isMock == true
				if ok and payload.action == "Snapshot" and unresolvedWrites == 0 then
					needsReconciliation = false
				end
			end
			if not success then
				needsReconciliation = true
			end
			message = if ok
				then (if code == "OK" then "Profile connected." else code)
				else "Action unavailable: " .. code
			if ok and payload.action == "Snapshot" and unresolvedWrites > 0 then
				message =
					"Profile refreshed, but a previous write is still pending. Wait for completion, then refresh again."
			end
			if callback then
				callback(ok, code)
			end
			render()
		end)
	end

	if not options.preview then
		table.insert(
			persistent,
			UserInputService.InputBegan:Connect(function(input: InputObject, consumed: boolean)
				if consumed then
					return
				end
				if input.KeyCode == Enum.KeyCode.Tab then
					local index = table.find(W.buttons, GuiService.SelectedObject) or 0
					local direction = if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
							or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
						then -1
						else 1
					if #W.buttons > 0 then
						GuiService.SelectedObject = W.buttons[(index - 1 + direction) % #W.buttons + 1]
					end
					return
				elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
					local selected = GuiService.SelectedObject
					if selected and W.callbacks[selected] then
						W.callbacks[selected]()
						return
					end
				end
				steeringKeys[input.KeyCode] = true
				updateSteering()
			end)
		)
		table.insert(
			persistent,
			UserInputService.InputEnded:Connect(function(input: InputObject)
				steeringKeys[input.KeyCode] = nil
				pointerSteering[input] = nil
				updateSteering()
			end)
		)
		table.insert(
			persistent,
			UserInputService.WindowFocusReleased:Connect(function()
				table.clear(steeringKeys)
				table.clear(pointerSteering)
				table.clear(selectionPulse)
				updateSteering()
			end)
		)
		ContextActionService:BindAction("TrailWarsBack", function(_, state)
			if state == Enum.UserInputState.Begin then
				back()
			end
			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.Escape, Enum.KeyCode.ButtonB)
	end
	table.insert(
		persistent,
		screen.Destroying:Connect(function()
			W.clear()
			if not options.preview then
				ContextActionService:UnbindAction("TrailWarsBack")
			end
			for _, connection in persistent do
				connection:Disconnect()
			end
		end)
	)
	render()
	telemetry.initializationMs = (os.clock() - started) * 1000
	screen:SetAttribute("InitializationMs", telemetry.initializationMs)
	screen:SetAttribute("MetricsScope", "Client GUI construction CPU time only; excludes profile network and rendering")

	request({ action = "Snapshot" })

	return function()
		screen:Destroy()
	end
end
return App
