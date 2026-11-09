--!strict
-- Persistent native paths: frozen chunks never rewritten in the render loop.
local Renderer = {}
function Renderer.new(field: Frame, Kit: any, config: any)
	local controller: any =
		{ field = field, config = config, sprites = {}, chunks = {}, active = {}, consumed = 0, pathCount = 0 }
	local palette = {
		Kit.colors.coral,
		Kit.colors.blue,
		Kit.colors.yellow,
		Color3.fromRGB(20, 190, 173),
		Color3.fromRGB(178, 109, 211),
		Color3.fromRGB(244, 148, 60),
	}
	function controller:reset()
		for _, chunk in controller.chunks do
			chunk.path:Destroy()
		end
		for _, sprite in controller.sprites do
			sprite.core:Destroy()
		end
		controller.sprites = {}
		controller.chunks = {}
		controller.active = {}
		controller.consumed = 0
		controller.pathCount = 0
	end
	function controller:roster(players: any)
		for i, p in players do
			if not controller.sprites[p.id] then
				local core = Kit.frame(field, "Core_" .. p.id, palette[i])
				Kit.round(core, 99)
				Kit.outline(core, Kit.colors.ink, 2)
				core.AnchorPoint = Vector2.new(0.5, 0.5)
				core.ZIndex = 5
				local shine = Kit.frame(core, "Shine", Kit.colors.paper)
				Kit.round(shine, 99)
				shine.Size = UDim2.fromScale(0.25, 0.25)
				shine.Position = UDim2.fromScale(0.18, 0.16)
				local label = Kit.text(core, "Name", p.name, 12)
				label.Position = UDim2.new(-2, 0, -1, -4)
				label.Size = UDim2.new(5, 0, 0, 20)
				controller.sprites[p.id] = { core = core, color = palette[i] }
			end
		end
	end
	function controller:append(segments: any)
		local dirty = {}
		for _, s in segments do
			local sprite = controller.sprites[s.owner]
			if not sprite then
				continue
			end
			local chunk = controller.active[s.owner]
			if not chunk or #chunk.points >= 48 then
				local path = Instance.new("Path2D")
				path.Name = "Trail_" .. s.owner
				path.Color3 = sprite.color
				path.ZIndex = 2
				path.Thickness = math.max(1, config.TrailRadius * 2 * field.AbsoluteSize.X / config.Width)
				path.Parent = field
				chunk = {
					path = path,
					points = { Path2DControlPoint.new(UDim2.fromScale(s.ax / config.Width, s.ay / config.Height)) },
				}
				table.insert(controller.chunks, chunk)
				controller.active[s.owner] = chunk
				controller.pathCount += 1
			end
			table.insert(
				chunk.points,
				Path2DControlPoint.new(UDim2.fromScale(s.bx / config.Width, s.by / config.Height))
			)
			dirty[chunk] = true
			controller.consumed += 1
		end
		for chunk in dirty do
			chunk.path:SetControlPoints(chunk.points)
		end
	end
	function controller:draw(players: any)
		local scale = field.AbsoluteSize.X / config.Width
		if controller.lastScale ~= scale then
			for _, chunk in controller.chunks do
				chunk.path.Thickness = math.max(1, config.TrailRadius * 2 * scale)
			end
			controller.lastScale = scale
		end
		for _, p in players do
			local sprite = controller.sprites[p.id]
			if sprite then
				sprite.core.Position = UDim2.fromScale(p.x / config.Width, p.y / config.Height)
				local size = math.max(7, config.VisualRadius * 2 * scale)
				sprite.core.Size = UDim2.fromOffset(size, size)
				sprite.core.Visible = p.alive
			end
		end
	end
	function controller:destroy()
		controller:reset()
	end
	return controller
end
return Renderer
