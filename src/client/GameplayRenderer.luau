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
		for _, child in field:GetChildren() do
			if child.Name == "Rocket" then
				child:Destroy()
			end
		end
		controller.rockets = {}
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
				controller.sprites[p.id] = { core = core, color = palette[i], label = label }
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
			if
				not chunk
				or #chunk.points >= 48
				or math.abs((chunk.bx or s.ax) - s.ax) + math.abs((chunk.by or s.ay) - s.ay) > 0.001
			then
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
			chunk.bx, chunk.by = s.bx, s.by
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
				local labelWidth = math.min(80, field.AbsoluteSize.X / 4)
				sprite.label.Size = UDim2.fromOffset(labelWidth, 18)
				sprite.label.AnchorPoint = Vector2.new(0.5, 1)
				local px, py = p.x * scale, p.y * scale
				sprite.label.Position = UDim2.fromOffset(
					math.clamp(px, labelWidth / 2, field.AbsoluteSize.X - labelWidth / 2) - px + size / 2,
					if py < 22 then size + 20 else -4
				)
				sprite.core.Visible = p.alive
				sprite.core.BackgroundTransparency = if p.jumping then 0.65 else 0
			end
		end
	end
	function controller:projectiles(data: any)
		controller.rockets = controller.rockets or {}
		local seen = {}
		for _, q in data do
			seen[q.id] = true
			local object = controller.rockets[q.id]
			if not object then
				object = Kit.frame(field, "Rocket", if q.kind == "Turret" then Kit.colors.yellow else Kit.colors.coral)
				Kit.round(object, 5)
				Kit.outline(object)
				object.Size = UDim2.fromOffset(14, 8)
				object.AnchorPoint = Vector2.new(0.5, 0.5)
				object.ZIndex = 7
				controller.rockets[q.id] = object
			end
			object.Position = UDim2.fromScale(q.x / config.Width, q.y / config.Height)
			object.Rotation = math.deg(q.heading)
		end
		for id, object in controller.rockets do
			if not seen[id] then
				object:Destroy()
				controller.rockets[id] = nil
			end
		end
	end
	function controller:destroy()
		controller:reset()
	end
	return controller
end
return Renderer
