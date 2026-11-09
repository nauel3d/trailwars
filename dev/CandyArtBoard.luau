--!strict
-- Native source-art QA only. Not a menu or a replacement game screen.
return function(parent: Instance)
	local RS = game.ReplicatedStorage
	local Kit = require(RS.TrailWarsDev.Components)
	local Art = require(RS.TrailWarsUI.CandyCometArt)
	local root = Kit.frame(parent, "CandyArtBoard", Kit.colors.paper)
	root.Size = UDim2.fromScale(1, 1)
	root.ZIndex = 30
	local title = Kit.text(root, "Title", "CANDY COMET · NATIVE SOURCE ART / COLOR & ID CHECK", 24)
	title.Size = UDim2.new(1, 0, 0, 60)
	title.ZIndex = 31
	local colors = {
		Kit.colors.coral,
		Kit.colors.blue,
		Kit.colors.yellow,
		Color3.fromRGB(0, 158, 149),
		Color3.fromRGB(165, 85, 205),
		Color3.fromRGB(238, 133, 39),
	}
	local names = { "01 COMET", "02 ORBIT", "03 SUNNY", "04 MINT", "05 PLUM", "06 TANGO" }
	local w, h = root.AbsoluteSize.X, root.AbsoluteSize.Y
	local cw = (w - 48) / 6
	local ch = math.min(170, (h - 220) / 3)
	for context = 1, 3 do
		for i, color in colors do
			local panel = Kit.frame(root, "Swatch", if context == 2 then Kit.colors.mint else Kit.colors.paper)
			panel.Position = UDim2.fromOffset(24 + (i - 1) * cw, 64 + (context - 1) * ch)
			panel.Size = UDim2.fromOffset(cw - 8, ch - 8)
			panel.ZIndex = 31
			Kit.round(panel, 12)
			if context == 3 then
				for j, c in { Kit.colors.coral, Kit.colors.blue, Kit.colors.yellow } do
					local path = Instance.new("Path2D")
					path.Color3 = c
					path.Thickness = 5
					path.ZIndex = 32
					path.Parent = panel
					path:SetControlPoints({
						Path2DControlPoint.new(UDim2.fromScale(0.1, 0.25 + j * 0.12)),
						Path2DControlPoint.new(UDim2.fromScale(0.9, 0.75 - j * 0.12)),
					})
				end
			end
			local body = Kit.frame(panel, "Portrait")
			body.Size = UDim2.fromOffset(48, 48)
			body.Position = UDim2.new(0.5, -24, 0.4, -24)
			body.Rotation = -15
			body.ZIndex = 33
			Art.core(body, Kit, color)
			-- Explicit per-object ZIndex keeps native source shapes above the QA background.
			for _, o in body:GetDescendants() do
				if o:IsA("GuiObject") then
					o.ZIndex += 30
				end
			end
			local label = Kit.text(panel, "Identity", names[i], 14)
			label.Position = UDim2.new(0, 0, 1, -26)
			label.Size = UDim2.new(1, 0, 0, 24)
			label.ZIndex = 35
		end
	end
	for i, turret in { false, true } do
		local x = w / 2 + (i - 1.5) * 250
		local rocket = Kit.frame(root, "ToyRocket")
		rocket.Size = UDim2.fromOffset(112, 72)
		rocket.Position = UDim2.fromOffset(x - 56, h - 130)
		rocket.ZIndex = 35
		Art.rocket(rocket, Kit, turret)
		for _, o in rocket:GetDescendants() do
			if o:IsA("GuiObject") then
				o.ZIndex += 30
			end
		end
		local label =
			Kit.text(root, "RocketLabel", if turret then "TURRET · CROSS WINGS" else "HOMING · STRIPED FINS", 16)
		label.Size = UDim2.fromOffset(240, 30)
		label.Position = UDim2.fromOffset(x - 120, h - 52)
		label.ZIndex = 35
	end
	return root
end
