--!strict
-- Pure layout in safe-parent pixels. No fixed desktop canvas and no global UIScale.
local Layout = {}
export type Box = { number }
function Layout.home(width: number, height: number, textScale: number?)
	local t = math.clamp(textScale or 1, 1, 1.5)
	local w, h = math.max(width, 280), math.max(height, 320)
	local pad, gap = 12, 10
	local content = math.min(w - pad * 2, 1840)
	local x = (w - content) / 2
	local out: any = { mode = "Portrait", nav = {}, textScale = t }
	local navH = math.max(56, math.ceil(46 * t))
	if w >= 1000 and h >= 550 then
		out.mode = "Spacious"
		local headerH = math.clamp(h * 0.16, 88, 146)
		out.logo = { x, pad, headerH * 1.38, headerH }
		out.currency = { x + content - 240, pad + 10, 240, 64 }
		local side = math.min(content * 0.38, 530)
		local bottom = h - pad - math.max(80, navH)
		local top = headerH + pad * 2
		local heroH = bottom - top - 28
		out.heading = { x + 8, top + heroH * 0.15, side - 16, 110 }
		out.play = { x + 8, top + heroH * 0.54, side - 16, 100 }
		out.preview = { x + side + 28, top, content - side - 28, heroH }
		for i = 1, 4 do
			local nw = (content - 3 * gap) / 4
			out.nav[i] = { x + (i - 1) * (nw + gap), bottom, nw, math.max(80, navH) }
		end
	elseif w > h then
		out.mode = "CompactLandscape"
		local rail = math.clamp(content * 0.21, 146, 180)
		out.logo = { x, 4, 120, 80 }
		out.currency = { x + content - 184, 10, 184, 52 }
		out.heading = { x + rail + 16, 12, math.max(100, content - rail - 212), 52 }
		local available = h - 92 - pad
		navH = math.max(48, math.min(navH, (available - 3 * 8) / 4))
		for i = 1, 4 do
			out.nav[i] = { x, 88 + (i - 1) * (navH + 8), rail, navH }
		end
		out.play = { x + rail + 16, h - 70, content - rail - 16, 58 }
		out.preview = { x + rail + 16, 80, content - rail - 16, h - 162 }
	else
		local headerH = 84
		out.logo = { x, 4, math.min(content * 0.45, 166), 96 }
		local balanceW = math.min(184, content * 0.51)
		out.currency = { x + content - balanceW, 16, balanceW, 56 }
		local nw = (content - gap) / 2
		local navY = h - pad - (navH * 2 + gap)
		for i = 1, 4 do
			out.nav[i] = { x + ((i - 1) % 2) * (nw + gap), navY + math.floor((i - 1) / 2) * (navH + gap), nw, navH }
		end
		local playH = math.max(70, math.ceil(52 * t))
		local py = navY - gap - playH
		out.play = { x + 6, py, content - 12, playH }
		local titleH = math.max(if h < 650 then 46 else 64, math.ceil(22 * t * 2.2))
		out.heading = { x, py - gap - titleH, content, titleH }
		out.preview = { x, headerH + 20, content, py - titleH - headerH - 40 }
	end
	-- Decoration yields space before a critical action. Tiny safe rectangles use a
	-- reduced hero, never scale down the destination hit rectangles.
	out.showPreview = out.preview[4] >= 72
	out.showHeading = out.mode ~= "CompactLandscape" or out.heading[3] >= 250
	out.headingSize = if out.mode == "Spacious" then 34 * t elseif out.mode == "Portrait" then 22 * t else 18 * t
	out.navSize = (if out.mode == "Spacious" then 23 else 16) * t
	out.playSize = (if out.mode == "Spacious" then 52 elseif out.mode == "CompactLandscape" then 28 else 36) * t
	return out
end
return Layout
