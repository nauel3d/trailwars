--!strict
-- Original continuous 2D collision math; no physics instances or Touched events.
local G = {}
local EPS = 1e-9
function G.pointSegmentSq(px: number, py: number, ax: number, ay: number, bx: number, by: number): number
	local dx, dy = bx - ax, by - ay
	local d = dx * dx + dy * dy
	local t = if d <= EPS then 0 else math.clamp(((px - ax) * dx + (py - ay) * dy) / d, 0, 1)
	return (px - ax - t * dx) ^ 2 + (py - ay - t * dy) ^ 2
end
function G.circleTOI(ax: number, ay: number, bx: number, by: number, cx: number, cy: number, r: number): number?
	local vx, vy = bx - ax, by - ay
	local ox, oy = ax - cx, ay - cy
	local c = ox * ox + oy * oy - r * r
	if c <= EPS then
		return 0
	end
	local a = vx * vx + vy * vy
	if a <= EPS then
		return nil
	end
	local b = 2 * (ox * vx + oy * vy)
	local disc = b * b - 4 * a * c
	if disc < -EPS then
		return nil
	end
	local t = (-b - math.sqrt(math.max(0, disc))) / (2 * a)
	return if t >= -EPS and t <= 1 + EPS then math.clamp(t, 0, 1) else nil
end
function G.capsuleTOI(
	ax: number,
	ay: number,
	bx: number,
	by: number,
	cx: number,
	cy: number,
	dx: number,
	dy: number,
	r: number
): number?
	if G.pointSegmentSq(ax, ay, cx, cy, dx, dy) <= r * r + EPS then
		return 0
	end
	local best: number? = nil
	local function take(t: number?)
		if t and (not best or t < best) then
			best = t
		end
	end
	take(G.circleTOI(ax, ay, bx, by, cx, cy, r))
	take(G.circleTOI(ax, ay, bx, by, dx, dy, r))
	local ux, uy = dx - cx, dy - cy
	local length = math.sqrt(ux * ux + uy * uy)
	if length > EPS then
		ux /= length
		uy /= length
		local x = (ax - cx) * ux + (ay - cy) * uy
		local y = -(ax - cx) * uy + (ay - cy) * ux
		local vx = (bx - ax) * ux + (by - ay) * uy
		local vy = -(bx - ax) * uy + (by - ay) * ux
		if math.abs(vy) > EPS then
			for _, side in { -r, r } do
				local t = (side - y) / vy
				local at = x + vx * t
				if t >= 0 and t <= 1 and at >= 0 and at <= length then
					take(t)
				end
			end
		end
	end
	return best
end
function G.growingTOI(
	ax: number,
	ay: number,
	bx: number,
	by: number,
	cx: number,
	cy: number,
	dx: number,
	dy: number,
	r: number
): number?
	-- Opponent trail exists only from C to C+t(D-C), never along a future path.
	local ux, uy = dx - cx, dy - cy
	local length = math.sqrt(ux * ux + uy * uy)
	if length <= EPS then
		return G.circleTOI(ax, ay, bx, by, cx, cy, r)
	end
	ux /= length
	uy /= length
	local x = (ax - cx) * ux + (ay - cy) * uy
	local y = -(ax - cx) * uy + (ay - cy) * ux
	local vx = (bx - ax) * ux + (by - ay) * uy
	local vy = -(bx - ax) * uy + (by - ay) * ux
	local best: number? = nil
	local function take(t: number?, kind: string)
		if not t then
			return
		end
		local at = x + vx * t
		if (kind == "start" and at > EPS) or (kind == "end" and at < length * t - EPS) then
			return
		end
		if not best or t < best then
			best = t
		end
	end
	take(G.circleTOI(ax, ay, bx, by, cx, cy, r), "start")
	take(G.circleTOI(ax - cx, ay - cy, bx - dx, by - dy, 0, 0, r), "end")
	if math.abs(vy) > EPS then
		for _, side in { -r, r } do
			local t = (side - y) / vy
			local at = x + vx * t
			if t >= 0 and t <= 1 and at >= -EPS and at <= length * t + EPS and (not best or t < best) then
				best = t
			end
		end
	end
	return best
end
function G.wallTOI(ax: number, ay: number, bx: number, by: number, width: number, height: number, r: number): number?
	if ax < r - EPS or ax > width - r + EPS or ay < r - EPS or ay > height - r + EPS then
		return 0
	end
	local best: number? = nil
	local function take(t: number)
		if t >= 0 and t <= 1 and (not best or t < best) then
			best = t
		end
	end
	if bx <= r and bx < ax then
		take((r - ax) / (bx - ax))
	end
	if bx >= width - r and bx > ax then
		take((width - r - ax) / (bx - ax))
	end
	if by <= r and by < ay then
		take((r - ay) / (by - ay))
	end
	if by >= height - r and by > ay then
		take((height - r - ay) / (by - ay))
	end
	return best
end
return G
