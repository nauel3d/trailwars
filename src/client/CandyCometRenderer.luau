--!strict
-- Optional art layer over the preserved renderer. No movement, collision or scoring logic.
local Base = require(script.Parent.GameplayRenderer)
local Art = require(script.Parent.CandyCometArt)
local Tokens = require(game.ReplicatedStorage.TrailWars.GameplayMotion)
local Cues = require(game.ReplicatedStorage.TrailWarsDev.UICues)
local Candy = {}
function Candy.new(field: Frame, Kit: any, config: any, options: any?)
	local opts = options or {}
	local renderer = Base.new(field, Kit, config)
	local originalRoster, originalAppend, originalReset = renderer.roster, renderer.append, renderer.reset
	local ink, paper = Kit.colors.ink, Kit.colors.paper
	local colors = {
		Kit.colors.coral,
		Kit.colors.blue,
		Kit.colors.yellow,
		Color3.fromRGB(0, 158, 149),
		Color3.fromRGB(165, 85, 205),
		Color3.fromRGB(238, 133, 39),
	}
	local elapsed = 0
	local seenRound, highEvent = nil, 0
	local primed = false
	local fx = {}
	local accents = {}
	local freeRockets, rocketState = {}, {}
	local function write(object, cache, property, value)
		if cache[property] ~= value then
			object[property] = value
			cache[property] = value
		end
	end
	local function reduced()
		return opts.preferences and opts.preferences.reducedMotion == true
	end
	local function part(parent, name, color, x, y, w, h, z, radius)
		local f = Kit.frame(parent, name, color)
		f.Position = UDim2.fromScale(x, y)
		f.Size = UDim2.fromScale(w, h)
		f.ZIndex = z
		if radius then
			Kit.round(f, radius)
		end
		return f
	end
	local function ring(parent, name, color, z)
		local f = part(parent, name, nil, 0, 0, 1, 1, z, 99)
		local stroke = Kit.outline(f, color, 1.5)
		return f, stroke
	end
	-- Bounded impact pool: no allocation when a hit or crash arrives.
	for i = 1, 12 do
		local root = Kit.frame(field, "Impact" .. i)
		root.AnchorPoint = Vector2.new(0.5, 0.5)
		root.ZIndex = 9
		root.Visible = false
		local circle, stroke = ring(root, "Shock", ink, 9)
		local marks = {}
		local caption = Kit.text(root, "Caption", "", 12)
		caption.Position = UDim2.fromScale(-1, -1)
		caption.Size = UDim2.new(3, 0, 0, 18)
		caption.ZIndex = 11
		for j = 1, 4 do
			local mark = part(root, "Chip" .. j, ink, 0, 0, 0.2, 0.1, 10, 2)
			mark.AnchorPoint = Vector2.new(0.5, 0.5)
			marks[j] = mark
		end
		fx[i] = {
			root = root,
			circle = circle,
			stroke = stroke,
			marks = marks,
			caption = caption,
			age = 1,
			duration = 0.48,
		}
	end
	local cursor = 0
	local feedback = { text = "", untilTime = 0 }
	local function impact(x, y, color, lethal, cause, localPlayer, points)
		cursor = cursor % #fx + 1
		local f = fx[cursor]
		f.x, f.y, f.age, f.lethal = x, y, 0, lethal
		f.duration = if reduced() then Tokens.StaticImpact else if lethal then Tokens.Crash else Tokens.Hit
		f.root.Position = UDim2.fromScale(x / config.Width, y / config.Height)
		f.root.Visible = true
		f.stroke.Color = if lethal then ink else color
		f.stroke.Transparency = 0
		f.caption.Text = if lethal then "!" elseif points then "-" .. points else ""
		f.caption.TextTransparency = 0
		f.circle:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, if cause == "Wall" then 4 else 99)
		for _, m in f.marks do
			m.BackgroundColor3 = color
		end
		if localPlayer then
			feedback.text = if not lethal
				then "TAGGED · KEEP MOVING!"
				elseif cause == "Wall" then "WALL CRASH · ELIMINATED"
				elseif cause == "SelfTrail" then "OWN TRAIL · ELIMINATED"
				elseif cause == "Core" then "CORE COLLISION · ELIMINATED"
				else "TRAIL CRASH · ELIMINATED"
			feedback.untilTime = elapsed + 2
		end
	end
	function renderer:roster(players)
		originalRoster(renderer, players)
		for i, p in players do
			local s = renderer.sprites[p.id]
			if s.art then
				continue
			end
			s.color = colors[i]
			s.number = i
			s.cache, s.style, s.labelCache, s.artCache = {}, {}, {}, {}
			s.spawned = elapsed
			s.core.BackgroundTransparency = 1
			s.core:FindFirstChildOfClass("UIStroke").Enabled = false
			s.core.Shine.Visible = false
			s.shadow = part(s.core, "Contact", ink, -0.1, 0.28, 1.2, 0.85, 3, 99)
			s.shadow.BackgroundTransparency = 0.82
			s.art = part(s.core, "CandyRacer", nil, 0, 0, 1, 1, 5)
			s.art.AnchorPoint = Vector2.new(0.5, 0.5)
			local art = Art.core(s.art, Kit, s.color)
			for key, value in art do
				s[key] = value
			end
			s.jumpRing, s.jumpStroke = ring(s.core, "AirRing", s.color, 4)
			s.jumpRing.Position = UDim2.fromScale(-0.4, -0.4)
			s.jumpRing.Size = UDim2.fromScale(1.8, 1.8)
			s.jumpRing.Visible = false
			s.label.Text = tostring(i) .. " · " .. (if p.id == opts.selfId then "YOU" else p.name)
			s.label.BackgroundTransparency = 0.05
			s.label.BackgroundColor3 = if p.id == opts.selfId then ink else paper
			s.label.TextColor3 = if p.id == opts.selfId then paper else ink
			s.label.TextWrapped = false
			s.label.TextTruncate = Enum.TextTruncate.AtEnd
			s.label.TextSize = 11
			s.label.AnchorPoint = Vector2.new(0.5, 1)
			s.label.ZIndex = 8
			Kit.round(s.label, 5)
			local accent = Instance.new("Path2D")
			accent.Name = "ActiveRibbon_" .. p.id
			accent.Color3 = s.color:Lerp(paper, 0.58)
			accent.ZIndex = 3
			accent.Parent = field
			accents[p.id] = accent
		end
	end
	function renderer:append(segments)
		originalAppend(renderer, segments)
		local dirty = {}
		for _, s in segments do
			dirty[s.owner] = true
		end
		for id in dirty do
			local chunk = renderer.active[id]
			local accent = accents[id]
			if chunk and accent then
				local points = {}
				for i = math.max(1, #chunk.points - (opts.accentPoints or 8) + 1), #chunk.points do
					table.insert(points, chunk.points[i])
				end
				accent:SetControlPoints(points)
				accent.Thickness = math.max(0.5, config.TrailRadius * 0.55 * field.AbsoluteSize.X / config.Width)
			end
		end
	end
	function renderer:draw(players)
		debug.profilebegin("TrailWars/CoreDraw")
		local scale = field.AbsoluteSize.X / config.Width
		if renderer.lastScale ~= scale then
			for _, chunk in renderer.chunks do
				chunk.path.Thickness = math.max(1, config.TrailRadius * 2 * scale)
			end
			for _, accent in accents do
				accent.Thickness = math.max(0.5, config.TrailRadius * 0.55 * scale)
			end
			renderer.lastScale = scale
		end
		for _, p in players do
			local s = renderer.sprites[p.id]
			if not s or not s.art then
				continue
			end
			local size = math.max(if field.AbsoluteSize.X >= 550 then 10 else 7, config.VisualRadius * 2 * scale)
			local detailed = size >= 9
			local jumping = p.jumping == true
			write(s.core, s.cache, "Position", UDim2.fromScale(p.x / config.Width, p.y / config.Height))
			write(s.core, s.cache, "Size", UDim2.fromOffset(size, size))
			write(s.core, s.cache, "Visible", p.alive)
			write(s.art, s.artCache, "Rotation", math.deg(p.heading))
			if s.detail ~= detailed then
				s.detail = detailed
				for _, o in { s.visor, s.rim, s.shade, s.face } do
					o.Visible = detailed
				end
				s.bodyStroke.Thickness = if detailed then 1.5 else 1.15
			end
			if s.lastSize ~= size then
				s.spec.Visible = size >= 8
				s.lastSize = size
			end
			if jumping ~= s.jumping then
				s.changed = elapsed
				if s.jumping and p.alive and not reduced() then
					impact(p.x, p.y, s.color, false, "Landing", false)
				end
				s.jumping = jumping
				s.shadow.Visible = not jumping
				s.jumpRing.Visible = jumping
				s.jumpStroke.Transparency = if jumping then 0.1 else 1
			end
			local age = elapsed - (s.changed or 0)
			local lift = if jumping and not reduced()
				then math.min(1, age / Tokens.JumpLift) * math.min(5, size * 0.3)
				else 0
			write(s.art, s.artCache, "Position", UDim2.new(0.5, 0, 0.5, -lift))
			local lean = if reduced() or jumping then 0 else (p.turn or 0) * 0.06
			local spawn = if reduced()
				then 1
				else 1 - 0.2 * (1 - math.clamp((elapsed - s.spawned) / Tokens.Spawn, 0, 1)) ^ 3
			local shell = if detailed then 1.25 else 1
			write(
				s.art,
				s.artCache,
				"Size",
				UDim2.fromScale((shell + math.abs(lean)) * spawn, (shell - math.abs(lean)) * spawn)
			)
			if accents[p.id] and s.accentVisible ~= (p.alive and not jumping) then
				s.accentVisible = p.alive and not jumping
				accents[p.id].Visible = s.accentVisible
			end
			local text = tostring(s.number)
				.. (if jumping then " · AIR" elseif p.id == opts.selfId then " · YOU" else " · " .. p.name)
			write(s.label, s.labelCache, "Text", text)
			local lw = if field.AbsoluteSize.X < 450 then 54 else 88
			write(s.label, s.labelCache, "Size", UDim2.fromOffset(lw, 17))
			local px, py = p.x * scale, p.y * scale
			write(
				s.label,
				s.labelCache,
				"Position",
				UDim2.fromOffset(
					math.clamp(px, lw / 2 + 2, field.AbsoluteSize.X - lw / 2 - 2) - px + size / 2,
					if py < 24 then size + 20 else -5 - lift
				)
			)
		end
		debug.profileend()
	end
	function renderer:projectiles(data)
		renderer.rockets = renderer.rockets or {}
		local seen = {}
		for _, q in data do
			seen[q.id] = true
		end
		for id, object in renderer.rockets do
			if not seen[id] then
				object.Visible = false
				renderer.rockets[id] = nil
				rocketState[id] = nil
				table.insert(freeRockets, object)
			end
		end
		for _, q in data do
			seen[q.id] = true
			local object = renderer.rockets[q.id]
			local state = rocketState[q.id]
			if not object then
				object = table.remove(freeRockets)
				if not object then
					object = Kit.frame(field, "Rocket")
					object.AnchorPoint = Vector2.new(0.5, 0.5)
					object.ZIndex = 7
					Art.rocket(object, Kit, false)
				end
				local turret = q.kind == "Turret"
				object.Stripe.Visible = not turret
				object.TurretWings.Visible = turret
				object.Nose.BackgroundColor3 = if turret then Kit.colors.yellow else Kit.colors.coral
				object.Visible = true
				state = {
					x = q.x,
					y = q.y,
					fromX = q.x,
					fromY = q.y,
					visualX = q.x,
					visualY = q.y,
					changed = elapsed,
					born = elapsed,
					cache = {},
				}
				rocketState[q.id] = state
				renderer.rockets[q.id] = object
			end
			if state.x ~= q.x or state.y ~= q.y then
				state.fromX, state.fromY = state.visualX, state.visualY
				state.x, state.y = q.x, q.y
				state.changed = elapsed
			end
			local a = if reduced() then 1 else math.clamp((elapsed - state.changed) / Tokens.ProjectileBlend, 0, 1)
			state.visualX = state.fromX + (state.x - state.fromX) * a
			state.visualY = state.fromY + (state.y - state.fromY) * a
			write(
				object,
				state.cache,
				"Position",
				UDim2.fromScale(state.visualX / config.Width, state.visualY / config.Height)
			)
			write(object, state.cache, "Rotation", math.deg(q.heading))
			local width = math.clamp(23 * field.AbsoluteSize.X / config.Width, 13, 26)
			write(object, state.cache, "Size", UDim2.fromOffset(width, width * 0.65))
			object.Exhaust.Visible = not reduced()
			local launch = math.clamp((elapsed - state.born) / Tokens.Launch, 0, 1)
			object.Exhaust.Size = UDim2.fromScale(0.2 + 0.2 * launch, 0.32)
		end
	end
	function renderer:events(roundId, events)
		if roundId ~= seenRound then
			seenRound, highEvent, primed = roundId, 0, false
		end
		for _, e in events do
			if e.sequence > highEvent then
				highEvent = e.sequence
				-- Initial/resync history is not a fresh impact. The high-water survives renderer reset.
				if primed and e.x and e.y then
					local s = renderer.sprites[e.victim]
					impact(
						e.x,
						e.y,
						if s then s.color else Kit.colors.coral,
						e.kind == "Eliminated",
						e.cause,
						e.victim == opts.selfId,
						e.points
					)
					if e.owner == opts.selfId or e.victim == opts.selfId then
						Cues.play(field, if e.kind == "Eliminated" then "crash" else "hit", opts.preferences)
					end
					if e.owner == opts.selfId and e.victim ~= opts.selfId then
						feedback.text = if e.kind == "Eliminated"
							then "TRAIL ELIMINATION!"
							elseif (e.points or 0) > 0 then "TAG! +" .. e.points .. " POINTS"
							else "TAG CONFIRMED"
						feedback.untilTime = elapsed + 1
					end
				end
			end
		end
		primed = true
	end
	function renderer:step(dt)
		elapsed += math.min(dt, 0.1)
		for _, f in fx do
			if not f.root.Visible then
				continue
			end
			f.age += dt
			local t = math.min(1, f.age / f.duration)
			if t >= 1 then
				f.root.Visible = false
				continue
			end
			local radius = if reduced() then 12 else (if f.lethal then 9 + 22 * t else 6 + 12 * t)
			f.root.Size = UDim2.fromOffset(radius, radius)
			f.stroke.Transparency = t
			f.caption.TextTransparency = t
			for j, m in f.marks do
				local a = j * math.pi / 2 + 0.4
				m.Visible = not reduced() and f.lethal
				m.Position = UDim2.fromScale(0.5 + math.cos(a) * (0.4 + t * 0.5), 0.5 + math.sin(a) * (0.4 + t * 0.5))
				m.Rotation = math.deg(a) + 30 * t
				m.BackgroundTransparency = t
			end
		end
	end
	function renderer:feedback()
		return if elapsed < feedback.untilTime then feedback.text else ""
	end
	function renderer:reset()
		for _, a in accents do
			a:Destroy()
		end
		accents = {}
		freeRockets, rocketState = {}, {}
		for _, f in fx do
			f.root.Visible = false
		end
		feedback.untilTime = 0
		originalReset(renderer)
	end
	function renderer:destroy()
		renderer:reset()
		for _, f in fx do
			f.root:Destroy()
		end
	end
	return renderer
end
return Candy
