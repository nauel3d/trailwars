--!strict
local Layout = {}
function Layout.compute(w: number, h: number)
	local pad = if w < 500 then 8 else 16
	local compact = w < 700 or h < 500
	local top = if h < 420 then 42 else 56
	local bottom = if h < 420 then 70 else 94
	local side = if not compact then 190 else 0
	local areaW = math.max(1, w - pad * 2 - side)
	local areaH = math.max(1, h - top - bottom - pad)
	local fw = math.min(areaW, areaH * 1300 / 800)
	local fh = fw * 800 / 1300
	return {
		field = { pad + (areaW - fw) / 2, top + (areaH - fh) / 2, fw, fh },
		top = top,
		bottom = bottom,
		compact = compact,
		side = side,
		pad = pad,
	}
end
return Layout
