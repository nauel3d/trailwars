--!strict
-- Bundled engine layout/state diagnostics; does not simulate physical inputs.
local Home = require(script.Parent.Home)
local Kit = require(script.Parent.Components)
return function(parent: Instance)
	local report: any = { cases = 0, failures = {}, callbacks = 0, states = 0 }
	for _, size in
		{
			{ 320, 568 },
			{ 360, 640 },
			{ 390, 844 },
			{ 568, 320 },
			{ 667, 375 },
			{ 844, 390 },
			{ 768, 1024 },
			{ 1024, 768 },
			{ 1280, 720 },
			{ 1672, 941 },
			{ 2560, 1080 },
		}
	do
		for _, scale in { 1, 1.25, 1.5 } do
			local host = Kit.frame(parent, "EngineCase")
			host.Size = UDim2.fromOffset(size[1], size[2])
			local proof = Home.mount(host, {
				textScale = scale,
				reducedMotion = true,
				navigate = function()
					report.callbacks += 1
				end,
			})
			task.wait(0.04)
			proof.arrange()
			task.wait(0.04)
			for _, v in host:GetDescendants() do
				if v:IsA("TextLabel") then
					local visible = v.Visible
					local a = v.Parent
					while a and a ~= host do
						if a:IsA("GuiObject") and not a.Visible then
							visible = false
							break
						end
						a = a.Parent
					end
					if visible and not v.TextFits then
						table.insert(
							report.failures,
							{ size = size, scale = scale, kind = "text-fit", name = v.Name, text = v.Text }
						)
					end
				end
			end
			for _, control in proof.buttons do
				local p, s = control.root.AbsolutePosition - host.AbsolutePosition, control.root.AbsoluteSize
				if
					p.X < -1
					or p.Y < -1
					or p.X + s.X > size[1] + 1
					or p.Y + s.Y > size[2] + 1
					or math.min(s.X, s.Y) < 48
				then
					table.insert(
						report.failures,
						{ size = size, scale = scale, kind = "hit-bounds", name = control.root.Name }
					)
				end
				control:activate()
			end
			report.cases += 1
			proof.destroy()
			host:Destroy()
		end
	end
	local scope = Kit.new(true)
	local host = Kit.frame(parent, "StateCase")
	host.Size = UDim2.fromOffset(300, 100)
	local calls = 0
	local button = scope:button(host, "StateButton", "TEST", true, function()
		calls += 1
	end)
	button.root.Size = UDim2.fromOffset(280, 70)
	for _, state in { "Disabled", "Loading" } do
		button:setState(state)
		button:activate()
		assert(calls == 0, "Disabled/loading controls must not activate")
		report.states += 1
	end
	button:setState("Default")
	button:activate()
	assert(calls == 1, "Default control must activate once")
	report.states += 1
	button:setState("Selected")
	button:activate()
	assert(calls == 2, "Selected control must remain interactive")
	report.states += 1
	scope:destroy()
	assert(#scope.connections == 0, "Destroy must release connections")
	host:Destroy()
	report.note =
		"Roblox engine frame-size tests and callback/state checks; not hardware, safe-area, mouse, touch or controller certification."
	return report
end
