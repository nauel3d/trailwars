--!strict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Input = game:GetService("UserInputService")
local Tokens = require(script.Parent.MotionTokens)
local Motion = {}
function Motion.visible(root: Instance): boolean
	local node: Instance? = root
	if not root.Parent then
		return false
	end
	while node do
		if node:IsA("GuiObject") and not node.Visible then
			return false
		end
		if node:IsA("ScreenGui") and not node.Enabled then
			return false
		end
		node = node.Parent
	end
	return true
end
function Motion.new(root: Instance, options: any?)
	local opts = options or {}
	local scope: any = {
		reducedMotion = opts.reducedMotion == true,
		destroyed = false,
		active = true,
		focused = true,
		clock = 0,
		connections = {},
		tweens = {},
		timers = {},
		loops = {},
		nextId = 0,
	}
	function scope:isReduced(): boolean
		if opts.preferences then
			return opts.preferences.reducedMotion == true
		end
		return self.reducedMotion
	end
	function scope:connect(signal: RBXScriptSignal, fn: (...any) -> ())
		local c = signal:Connect(fn)
		table.insert(self.connections, c)
		return c
	end
	function scope:cancel(object: Instance?)
		local list = {}
		for tween, entry in self.tweens do
			if not object or entry.object == object then
				table.insert(list, tween)
			end
		end
		for _, tween in list do
			local entry = self.tweens[tween]
			self.tweens[tween] = nil
			entry.connection:Disconnect()
			tween:Cancel()
			-- Settle to the latest semantic target when hidden/canceled; no stale completion.
			if entry.object.Parent and not self.destroyed then
				for key, value in entry.goals do
					(entry.object :: any)[key] = value
				end
			end
			if entry.cleanup then
				entry.cleanup()
			end
		end
	end
	function scope:to(object: Instance, goals: any, token: string?, complete: (() -> ())?, cleanup: (() -> ())?)
		if self.destroyed or not object.Parent then
			return
		end
		local conflicts = {}
		for tween, entry in self.tweens do
			if entry.object == object then
				for key in goals do
					if entry.goals[key] ~= nil then
						table.insert(conflicts, tween)
						break
					end
				end
			end
		end
		for _, tween in conflicts do
			local e = self.tweens[tween]
			self.tweens[tween] = nil
			e.connection:Disconnect()
			tween:Cancel()
			if e.cleanup then
				e.cleanup()
			end
		end
		if self:isReduced() or not self.active or not Motion.visible(root) then
			for key, value in goals do
				(object :: any)[key] = value
			end
			if complete then
				complete()
			end
			return
		end
		local spec = Tokens[token or "select"] or Tokens.select
		local tween = TweenService:Create(
			object,
			TweenInfo.new(spec.time, Enum.EasingStyle[spec.ease], Enum.EasingDirection.Out),
			goals
		)
		local entry: any = { object = object, goals = goals, cleanup = cleanup }
		entry.connection = tween.Completed:Connect(function(state: Enum.PlaybackState)
			if self.tweens[tween] ~= entry then
				return
			end
			self.tweens[tween] = nil
			entry.connection:Disconnect()
			if state == Enum.PlaybackState.Completed and not self.destroyed and complete then
				complete()
			end
		end)
		self.tweens[tween] = entry
		tween:Play()
	end
	function scope:after(seconds: number, callback: () -> ())
		self.nextId += 1
		local id = self.nextId
		self.timers[id] = { at = self.clock + seconds, callback = callback }
		return id
	end
	function scope:loop(callback: (number) -> (), hz: number, decorative: boolean?)
		self.nextId += 1
		local id = self.nextId
		self.loops[id] = { callback = callback, period = 1 / hz, elapsed = 0, decorative = decorative ~= false }
		return id
	end
	function scope:setReducedMotion(value: boolean)
		self.reducedMotion = value
		self:cancel()
	end
	function scope:setActive(value: boolean)
		self.active = value
		if not value then
			self:cancel()
		end
	end
	function scope:destroy()
		if self.destroyed then
			return
		end
		self.destroyed = true
		self:cancel()
		for _, c in self.connections do
			c:Disconnect()
		end
		table.clear(self.connections)
		table.clear(self.loops)
		table.clear(self.timers)
	end
	local wasVisible = true
	local wasReduced = scope:isReduced()
	scope:connect(Input.WindowFocusReleased, function()
		scope.focused = false
		scope:cancel()
	end)
	scope:connect(Input.WindowFocused, function()
		scope.focused = true
	end)
	scope:connect(root.Destroying, function()
		scope:destroy()
	end)
	scope:connect(RunService.Heartbeat, function(dt: number)
		local reduced = scope:isReduced()
		if reduced ~= wasReduced then
			if reduced then
				scope:cancel()
			end
			wasReduced = reduced
		end
		local running = scope.active and scope.focused and Motion.visible(root)
		if not running then
			if wasVisible then
				scope:cancel()
			end
			wasVisible = false
			return
		end
		wasVisible = true
		dt = math.min(dt, 0.1)
		scope.clock += dt
		local due = {}
		for id, timer in scope.timers do
			if timer.at <= scope.clock then
				scope.timers[id] = nil
				table.insert(due, timer.callback)
			end
		end
		for _, fn in due do
			if not scope.destroyed then
				fn()
			end
		end
		for _, loop in scope.loops do
			if not (scope:isReduced() and loop.decorative) then
				loop.elapsed += dt
				if loop.elapsed >= loop.period then
					local elapsed = math.min(loop.elapsed, 0.1)
					loop.elapsed = 0
					loop.callback(elapsed)
				end
			end
		end
	end)
	return scope
end
return Motion
