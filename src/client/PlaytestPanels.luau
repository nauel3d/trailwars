--!strict
local Panels = {}
function Panels.mount(parent: Instance, Kit: any, transport: any, kind: string, close: any, preferences: any)
	local root = Kit.frame(parent, "Playtest" .. kind, Kit.colors.paper)
	root.Size = UDim2.fromScale(1, 1)
	local scope = Kit.new(preferences.reducedMotion, preferences)
	local title = Kit.text(
		root,
		"Title",
		if kind == "PROFILE" then "PLAYER STATS / SERVER LEADERBOARD" else "PLAYTEST MATCH SETTINGS",
		24
	)
	title.Size = UDim2.new(1, -20, 0, 70)
	title.Position = UDim2.fromOffset(10, 10)
	local back = scope:button(root, "Back", "HOME", false, close)
	back.root.Size = UDim2.fromOffset(100, 48)
	back.root.Position = UDim2.new(0, 12, 1, -58)
	local text = Kit.text(root, "Details", "Loading server stats…", 16)
	text.Position = UDim2.fromOffset(12, 82)
	text.Size = UDim2.new(1, -24, 1, -155)
	text.TextYAlignment = Enum.TextYAlignment.Top
	local settings = { target = 40, rounds = 5, overtime = true, turrets = true }
	local controls = {}
	local dirty = false
	if kind == "SETTINGS" then
		text.Size = UDim2.new(1, -24, 0, 60)
		local function button(name, y, fn)
			local b = scope:button(root, name, name, false, function()
				dirty = true
				fn()
			end)
			b.root.Size = UDim2.new(1, -32, 0, 48)
			b.root.Position = UDim2.fromOffset(16, y)
			table.insert(controls, b)
			return b
		end
		button("Target", 150, function()
			settings.target = if settings.target == 30 then 40 elseif settings.target == 40 then 80 else 30
		end)
		button("Rounds", 206, function()
			settings.rounds = if settings.rounds == 3 then 5 else 3
		end)
		button("Overtime", 262, function()
			settings.overtime = not settings.overtime
		end)
		button("Turrets", 318, function()
			settings.turrets = not settings.turrets
		end)
		button("Apply", 374, function()
			transport:send("Configure", nil, nil, settings)
			dirty = false
		end)
	end
	local function arrange()
		local w, h = root.AbsoluteSize.X, root.AbsoluteSize.Y
		text.TextSize = if w < 500 or h < 500 then 13 else 16
		if kind == "SETTINGS" then
			title.TextSize = 18
			title.Position = UDim2.fromOffset(10, 4)
			title.Size = UDim2.new(1, -110, 0, 48)
			back.root.Position = UDim2.new(1, -96, 0, 6)
			back.root.Size = UDim2.fromOffset(84, 44)
			back.label.TextSize = 15
			text.Position = UDim2.fromOffset(12, 56)
			text.Size = UDim2.new(1, -24, 0, 48)
			local cols = if w > h then 2 else 1
			for i, b in controls do
				local x = (i - 1) % cols
				local y = math.floor((i - 1) / cols)
				b.root.Position = UDim2.fromOffset(12 + x * (w - 12) / cols, 112 + y * 56)
				b.root.Size = UDim2.fromOffset((w - 12) / cols - 12, 48)
				b.label.TextSize = if cols == 2 then 14 else 16
			end
		end
	end
	scope:connect(root:GetPropertyChangedSignal("AbsoluteSize"), arrange)
	task.defer(arrange)
	local function update(state)
		if not state then
			return
		end
		if kind == "PROFILE" then
			local lines = {
				"Storage: current server only · no live purchases",
				"Playtime includes Home, queue and play (including AFK).",
				"",
			}
			local list = table.clone(state.statistics or {})
			table.sort(list, function(a, b)
				return a.stats.matchesWon > b.stats.matchesWon
					or a.stats.matchesWon == b.stats.matchesWon and a.id < b.id
			end)
			for _, p in list do
				local st = p.stats
				table.insert(
					lines,
					string.format(
						"%s · W%d L%d · K%d D%d",
						p.name,
						st.matchesWon,
						st.matchesLost,
						st.kills,
						st.deaths
					)
				)
				table.insert(
					lines,
					string.format(
						"Score %d · %dh%02dm · Hits %d / Rockets %d",
						p.score,
						math.floor(st.totalPlaySeconds / 3600),
						math.floor(st.totalPlaySeconds % 3600 / 60),
						st.powerHits,
						st.turretHits
					)
				)
				if p.id == transport.selfId then
					table.insert(
						lines,
						string.format(
							"Session %dh %02dm %02ds · Total %dh %02dm %02ds",
							math.floor(st.sessionPlaySeconds / 3600),
							math.floor(st.sessionPlaySeconds % 3600 / 60),
							st.sessionPlaySeconds % 60,
							math.floor(st.totalPlaySeconds / 3600),
							math.floor(st.totalPlaySeconds % 3600 / 60),
							st.totalPlaySeconds % 60
						)
					)
					table.insert(lines, "Stolen score: " .. st.scoreStolen)
				end
				table.insert(lines, "")
			end
			text.Text = table.concat(lines, "\n")
		else
			if not dirty then
				settings = table.clone(state.settings)
			end
			text.Text =
				"Homing + Jump · at least 3 rounds\nHost may change these before a match; changes apply next match."
			controls[1].label.Text = "TARGET SCORE: " .. settings.target
			controls[2].label.Text = "MAX ROUNDS: " .. settings.rounds
			controls[3].label.Text = "TIES: "
				.. (if settings.overtime then "ONE OVERTIME, THEN SHARED" else "SHARED VICTORY")
			controls[4].label.Text = "POST-DEATH ROCKETS: " .. (if settings.turrets then "ON" else "OFF")
			controls[5].label.Text = if state.hostId == transport.selfId
				then "APPLY (QUEUE / FINAL ONLY)"
				else "HOST SETTINGS · READ ONLY"
			for _, b in controls do
				b.root.Active = state.hostId == transport.selfId
				b.root.Selectable = b.root.Active
			end
		end
	end
	return {
		root = root,
		update = update,
		destroy = function()
			scope:destroy()
			root:Destroy()
		end,
	}
end
return Panels
