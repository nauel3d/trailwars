--!strict
local Kit = require(script.Parent.Components)
local Motion = require(script.Parent.Motion)
local Demo = require(script.Parent.DemoModel)
local Leaderboard = require(script.Parent.Leaderboard)
local Arena = {}
function Arena.mount(parent: Instance, options: any?)
	local opts = options or {}
	local root = Kit.frame(parent, "LivingDemo")
	root.Size = UDim2.fromScale(1, 1)
	local motion = Motion.new(root, opts)
	local model = Demo.new()
	local label = Kit.text(root, "DemoLabel", "DEMO · TURN, SURVIVE, LAST CORE STANDING", 14)
	label.Size = UDim2.new(1, 0, 0, 24)
	local field = Kit.frame(root, "ArenaField")
	field.ClipsDescendants = true
	local board = Leaderboard.mount(
		root,
		{ demo = true, selfId = "coral", reducedMotion = opts.reducedMotion, preferences = opts.preferences }
	)
	local obstacles = {}
	for i, _ in model.obstacles do
		local f = Kit.panel(field, "Obstacle" .. i)
		f.BackgroundColor3 = Kit.colors.mint
		Kit.round(f, 99)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		table.insert(obstacles, f)
	end
	local sprites = {}
	for i, a in model.agents do
		local color = ({ Kit.colors.blue, Kit.colors.coral, Kit.colors.yellow })[i]
		local edge = Instance.new("Path2D")
		edge.Name = a.id .. "Outline"
		edge.Color3 = Kit.colors.ink
		edge.Parent = field
		local path = Instance.new("Path2D")
		path.Name = a.id .. "Trail"
		path.Color3 = color
		path.ZIndex = 2
		path.Parent = field
		local core = Kit.panel(field, a.id .. "Core")
		core.BackgroundColor3 = color
		Kit.round(core, 99)
		core.AnchorPoint = Vector2.new(0.5, 0.5)
		core.ZIndex = 4
		local shine = Kit.frame(core, "Shine", Kit.colors.paper)
		Kit.round(shine, 99)
		shine.Position = UDim2.fromScale(0.2, 0.16)
		shine.Size = UDim2.fromScale(0.23, 0.23)
		local burst = Kit.frame(field, a.id .. "Crash")
		Kit.round(burst, 99)
		Kit.outline(burst, color, 3)
		burst.AnchorPoint = Vector2.new(0.5, 0.5)
		burst.Visible = false
		burst.ZIndex = 5
		table.insert(sprites, { edge = edge, path = path, core = core, burst = burst, wasAlive = true })
	end
	local status = Kit.text(field, "DemoEvent", "", 14)
	status.AnchorPoint = Vector2.new(0.5, 1)
	status.Position = UDim2.fromScale(0.5, 1)
	status.Size = UDim2.new(1, -8, 0, 28)
	status.ZIndex = 6
	local function draw()
		local w, h = field.AbsoluteSize.X, field.AbsoluteSize.Y
		local thickness = math.clamp(math.min(w, h) * 0.026, 3, 8)
		for i, o in model.obstacles do
			local f = obstacles[i]
			f.Position = UDim2.fromScale(o.x, o.y)
			local d = o.r * 2 * math.min(w, h)
			f.Size = UDim2.fromOffset(d, d)
		end
		for i, a in model.agents do
			local s = sprites[i]
			local points = {}
			for _, p in a.trail do
				table.insert(points, Path2DControlPoint.new(UDim2.fromScale(p.x, p.y)))
			end
			if #points < 48 then
				table.insert(points, Path2DControlPoint.new(UDim2.fromScale(a.x, a.y)))
			end
			s.edge:SetControlPoints(points)
			s.edge.Thickness = thickness + 2
			s.path:SetControlPoints(points)
			s.path.Thickness = thickness
			s.core.Position = UDim2.fromScale(a.x, a.y)
			local size = math.clamp(math.min(w, h) * 0.09, 16, 32)
			s.core.Size = UDim2.fromOffset(size, size)
			s.core.Rotation = math.deg(a.heading)
			s.core.Visible = a.alive
			if s.wasAlive and not a.alive then
				s.burst.Visible = true
				s.burst.Position = s.core.Position
				s.burst.Size = UDim2.fromOffset(size, size)
				local function hide()
					s.burst.Visible = false
				end
				motion:to(s.burst, { Size = UDim2.fromOffset(size * 2.5, size * 2.5) }, "confirm", hide, hide)
				status.Text = a.name .. " · OUT!"
				motion:after(0.8, function()
					status.Text = ""
				end)
			end
			s.wasAlive = a.alive
		end
		root:SetAttribute("DemoSteps", model.steps)
		root:SetAttribute("DemoCrashes", model.crashes)
	end
	local function arrange()
		local w, h = root.AbsoluteSize.X, root.AbsoluteSize.Y
		local narrow = w < 430
		board.root.Visible = h >= 150
		if narrow and board.root.Visible then
			Kit.box(field, { 0, 26, w, math.max(54, h - 130) })
			Kit.box(board.root, { 2, h - 98, w - 4, 96 })
		elseif board.root.Visible then
			local bw = math.clamp(w * 0.30, 160, 230)
			Kit.box(field, { 0, 26, w - bw - 12, h - 26 })
			Kit.box(board.root, { w - bw, 28, bw, math.min(h - 32, 140) })
		else
			Kit.box(field, { 0, 26, w, math.max(24, h - 26) })
		end
		label.Text = if w < 430 then "TRAIL WARS · DEMO" else "DEMO · TURN, SURVIVE, LAST CORE STANDING"
		draw()
		board.setRows(Demo.rows(model), true)
	end
	local accumulator = 0
	motion:loop(function(dt: number)
		accumulator = math.min(accumulator + dt, 0.1)
		while accumulator >= 1 / 30 do
			Demo.step(model, 1 / 30)
			accumulator -= 1 / 30
		end
		draw()
	end, 30)
	motion:loop(function()
		board.setRows(Demo.rows(model))
	end, 0.8)
	motion:connect(root:GetPropertyChangedSignal("AbsoluteSize"), arrange)
	-- Populate an explanatory still frame for reduced motion; no decorative tick.
	for _ = 1, 30 do
		Demo.step(model, 1 / 30)
	end
	task.defer(arrange)
	return {
		root = root,
		model = model,
		arrange = arrange,
		setActive = function(value: boolean)
			motion:setActive(value)
		end,
		setReducedMotion = function(value: boolean)
			motion:setReducedMotion(value)
			board.setReducedMotion(value)
		end,
		destroy = function()
			motion:destroy()
			board.destroy()
			root:Destroy()
		end,
	}
end
return Arena
