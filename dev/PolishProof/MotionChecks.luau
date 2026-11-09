--!strict
local Motion = require(script.Parent.Motion)
local Kit = require(script.Parent.Components)
local Demos = require(script.Parent.Demos)
local Arena = require(script.Parent.AnimatedArena)
return function(parent: Instance)
	local report: any =
		{ failures = {}, demos = 0, cancellation = false, hidden = false, reduced = false, disposed = false }
	for _, size in { { 320, 568 }, { 390, 704 }, { 749, 331 }, { 1408, 703 } } do
		for _, route in { "CUSTOMIZE", "SHOP", "RESULTS", "SETTINGS" } do
			local host = Kit.frame(parent, "DemoCase")
			host.Size = UDim2.fromOffset(size[1], size[2])
			local demo = Demos.mount(host, route, { reducedMotion = true })
			task.wait(0.06)
			for _, v in host:GetDescendants() do
				if v:IsA("TextLabel") and v.Visible then
					local visible = true
					local a = v.Parent
					while a and a ~= host do
						if a:IsA("GuiObject") and not a.Visible then
							visible = false
							break
						end
						a = a.Parent
					end
					if visible and not v.TextFits then
						table.insert(report.failures, { route = route, size = size, name = v.Name, text = v.Text })
					end
				end
			end
			if route == "CUSTOMIZE" then
				demo.select(3)
				demo.action:activate()
				assert(demo.equipped() == 3, "Demo equip updates local fixture")
			end
			if route == "SHOP" then
				demo.action:activate()
				demo.action:activate()
			end
			if route == "RESULTS" then
				demo.action:activate()
				demo.action:activate()
			end
			demo.destroy()
			host:Destroy()
			report.demos += 1
		end
	end
	local host = Kit.frame(parent, "MotionLifecycle")
	host.Size = UDim2.fromOffset(400, 300)
	local f = Kit.frame(host, "TweenTarget", Kit.colors.blue)
	f.Size = UDim2.fromOffset(30, 30)
	local scope = Motion.new(host)
	local stale, latest = 0, 0
	scope:to(f, { Rotation = 40 }, "enter", function()
		stale += 1
	end)
	scope:to(f, { Rotation = 0 }, "select", function()
		latest += 1
	end)
	task.wait(0.22)
	report.cancellation = stale == 0 and latest == 1
	local ticks = 0
	scope:loop(function()
		ticks += 1
	end, 30)
	task.wait(0.1)
	host.Visible = false
	task.wait(0.1)
	local paused = ticks
	task.wait(0.1)
	report.hidden = ticks == paused
	host.Visible = true
	scope:setReducedMotion(true)
	task.wait(0.1)
	paused = ticks
	task.wait(0.1)
	report.reduced = ticks == paused
	scope:after(0.01, function()
		error("Timer survived disposal")
	end)
	scope:destroy()
	task.wait(0.05)
	report.disposed = next(scope.tweens) == nil
		and next(scope.timers) == nil
		and next(scope.loops) == nil
		and #scope.connections == 0
	host:Destroy()
	local space = Kit.frame(parent, "ArenaBudget")
	space.Size = UDim2.fromOffset(800, 400)
	local arena = Arena.mount(space)
	task.wait(0.2)
	local before = #space:GetDescendants()
	local started = os.clock()
	task.wait(1.2)
	report.arena = {
		instancesBefore = before,
		instancesAfter = #space:GetDescendants(),
		simulationSteps = arena.model.steps,
		wallSeconds = os.clock() - started,
	}
	arena.destroy()
	space:Destroy()
	assert(report.cancellation and report.hidden and report.reduced and report.disposed, "Motion lifecycle regression")
	assert(report.arena.instancesBefore == report.arena.instancesAfter, "Animation must not grow hierarchy")
	report.note = "Engine diagnostics, not hardware performance certification. Audio upload remains separate."
	return report
end
