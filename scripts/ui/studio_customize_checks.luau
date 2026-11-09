-- Client-only appearance regression check, run in customize-proof.project.json.
-- Does not alter a live profile or run gameplay.
local RS = game.ReplicatedStorage
local App = require(RS.TrailWarsUI.App)
local F = require(RS.TrailWarsDev.Fixtures)
local gui = Instance.new("ScreenGui")
gui.DisplayOrder = 100
gui.Parent = game.Players.LocalPlayer.PlayerGui
local out = { cases = 0, failures = {} }
for _, size in { { 1672, 941 }, { 390, 844 }, { 844, 390 }, { 768, 1024 }, { 320, 568 } } do
	for _, scale in { 1, 1.5 } do
		local t = Instance.new("Frame")
		t.Size = UDim2.fromOffset(size[1], size[2])
		t.Parent = gui
		local p = F.profile(480)
		p.settings.textScale = scale
		local clean =
			App.mount(t, { preview = true, initialRoute = "Customize", profile = p, transport = F.transport(p) })
		task.wait()
		task.wait()
		out.cases += 1
		for _, v in t:GetDescendants() do
			if v:IsA("TextLabel") and v.Name ~= "TypeShadow" and v.Name ~= "HeadingYours" and v.Text ~= "" then
				local visible = v.Visible
				local a = v.Parent
				while a and a ~= t do
					if a:IsA("GuiObject") and not a.Visible then
						visible = false
						break
					end
					a = a.Parent
				end
				if visible and not v.TextFits then
					table.insert(out.failures, { size = size, scale = scale, name = v.Name, text = v.Text })
				end
			end
		end
		clean()
		t:Destroy()
	end
end
gui:Destroy()
return out
