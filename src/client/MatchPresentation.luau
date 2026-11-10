--!strict
-- Semantic match presentation. Authoritative state triggers effects; inputs never wait for them.
local Art = require(script.Parent.CandyCometArt)
local Cues = require(game.ReplicatedStorage.TrailWarsDev.UICues)
local Tokens = require(game.ReplicatedStorage.TrailWars.GameplayMotion)
local Presentation = {}
function Presentation.mount(parent: Instance, Kit: any, Motion: any, preferences: any, selfId: string, pilot: Frame)
	local root = Kit.frame(parent, "MatchPresentation")
	root.Size = UDim2.fromScale(1, 1)
	root.ZIndex = 16
	local scope = Motion.new(root, { preferences = preferences })
	local badge = Kit.panel(root, "StartBadge")
	badge.AnchorPoint = Vector2.new(0.5, 0.5)
	badge.ZIndex = 17
	local badgeText = Kit.text(badge, "Word", "", 56)
	badgeText.ZIndex = 18
	local heroShadow = Kit.frame(root, "ChampionShadow", Kit.colors.ink)
	Kit.round(heroShadow, 18)
	heroShadow.ZIndex = 16
	local hero = Kit.panel(root, "ChampionCard")
	hero.ZIndex = 17
	local avatar = Kit.frame(hero, "Champion")
	avatar.AnchorPoint = Vector2.new(0.5, 0.5)
	avatar.ZIndex = 18
	local art = Art.core(avatar, Kit, Kit.colors.coral)
	for _, x in avatar:GetDescendants() do
		if x:IsA("GuiObject") then
			x.ZIndex += 14
		end
	end
	local title = Kit.text(hero, "Headline", "", 26)
	title.ZIndex = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	local detail = Kit.text(hero, "Detail", "", 14)
	detail.ZIndex = 18
	detail.TextXAlignment = Enum.TextXAlignment.Left
	local confetti = {}
	for i = 1, 6 do
		local chip = Kit.frame(
			root,
			"CelebrationChip",
			({ Kit.colors.coral, Kit.colors.blue, Kit.colors.yellow })[(i - 1) % 3 + 1]
		)
		chip.Size = UDim2.fromOffset(8, 5)
		chip.ZIndex = 19
		chip.Visible = false
		Kit.round(chip, 2)
		confetti[i] = chip
	end
	local generation = 0
	local previousPhase, previousRound, previousRemaining, previousActor = nil, nil, nil, nil
	local lastPower = {}
	local boardRect = nil
	local lastW, lastH, lastLarge, lastCount = nil, nil, nil, nil
	local function cancel()
		generation += 1
		scope:cancel()
		badge.Visible = false
		hero.Visible = false
		heroShadow.Visible = false
		for _, chip in confetti do
			chip.Visible = false
		end
	end
	local function burst(x, y)
		if scope:isReduced() then
			return
		end
		local gen = generation
		for i, chip in confetti do
			chip.Visible = true
			chip.BackgroundTransparency = 0
			chip.Rotation = i * 30
			chip.Position = UDim2.fromOffset(x, y)
			scope:to(chip, {
				Position = UDim2.fromOffset(x + (i - 3.5) * 25, y + 30 + (i % 2) * 22),
				Rotation = i * 73,
				BackgroundTransparency = 1,
			}, "matchCelebrate")
		end
		scope:after(0.8, function()
			if generation == gen then
				for _, chip in confetti do
					chip.Visible = false
				end
			end
		end)
	end
	local function arrange(w, h, field, large, count)
		badge.Position = UDim2.fromOffset(field[1] + field[3] / 2, field[2] + field[4] / 2)
		badge.Size = UDim2.fromOffset(math.min(200, field[3] - 0.1), math.min(90, field[4] * 0.5))
		badgeText.TextSize = if field[4] < 180 then 36 else 56
		if w > h and h < 500 then
			Kit.box(hero, { 8, 54, 184, math.min(146, h - 124) })
			avatar.Position = UDim2.fromOffset(42, 40)
			avatar.Size = UDim2.fromOffset(48, 48)
			Kit.box(title, { 76, 10, 102, 50 })
			title.TextSize = 17
			Kit.box(detail, { 10, 82, 164, 40 })
			detail.TextSize = 12
			boardRect = { 206, 52, w - 222, h - 116 }
		else
			local bw = math.min(560, w - 24)
			local bh = math.min(350, h - 214, 42 + count * 48)
			local top = math.max(56, (h - (76 + 10 + bh + 18 + 48)) / 2)
			Kit.box(hero, { (w - bw) / 2, top, bw, 76 })
			avatar.Position = UDim2.fromOffset(48, 38)
			avatar.Size = UDim2.fromOffset(60, 60)
			Kit.box(title, { 90, 6, bw - 104, 42 })
			title.TextSize = if w < 360 then 20 elseif w < 500 then 23 else 28
			Kit.box(detail, { 92, 47, bw - 106, 28 })
			detail.TextSize = if w < 500 then 12 else 14
			boardRect = { (w - bw) / 2, top + 86, bw, bh }
		end
		hero.Visible = large
		heroShadow.Visible = large
		heroShadow.Position = hero.Position + UDim2.fromOffset(0, 4)
		heroShadow.Size = hero.Size
	end
	local function update(state, me, field, sprites, powerButtons)
		root.Visible = true
		local phase = state.phase
		local changed = phase ~= previousPhase or state.roundId ~= previousRound
		local wasPhase = previousPhase
		if changed then
			cancel()
		end
		local large = phase == "Intermission" or phase == "Final"
		if changed then
			hero.Visible = large
			heroShadow.Visible = large
		end
		local w, h = parent.AbsoluteSize.X, parent.AbsoluteSize.Y
		local count = if state.series then #state.series.players else 0
		if w ~= lastW or h ~= lastH or large ~= lastLarge or count ~= lastCount then
			arrange(w, h, field, large, count)
			lastW, lastH, lastLarge, lastCount = w, h, large, count
		end
		local gen = generation
		if phase == "Countdown" and (changed or previousRemaining ~= state.remaining) then
			if changed then
				Cues.play(root, "queue", preferences)
			end
			badge.Visible = true
			badgeText.Text = tostring(state.remaining)
			badge.BackgroundColor3 = Kit.colors.paper
			badge.Rotation = if scope:isReduced() then 0 else -5
			scope:to(badge, { Rotation = 0 }, "countdownPop")
		elseif phase == "Active" and changed and wasPhase == "Countdown" then
			badge.Visible = true
			badgeText.Text = "GO!"
			Cues.play(root, "go", preferences)
			badge.BackgroundColor3 = Kit.colors.yellow
			badge.Rotation = if scope:isReduced() then 0 else -8
			scope:to(badge, { Rotation = 0 }, "goPop")
			scope:after(Tokens.GoHold, function()
				if generation == gen then
					badge.Visible = false
				end
			end)
		end
		local actor = state.powers and state.powers.actors[selfId]
		if actor and actor.state ~= previousActor and previousActor ~= nil and not large then
			if not scope:isReduced() then
				pilot.Rotation = -4
				scope:to(pilot, { Rotation = 0 }, "turretEnter")
			end
		end
		for slot, button in powerButtons do
			local cooldown = actor and actor[slot] or 0
			if not changed and lastPower[slot] and lastPower[slot] <= 0.15 and cooldown > 1 then
				button.root:SetAttribute("ConfirmedActivation", state.tick)
				if slot == "Homing" then
					Cues.play(root, "launch", preferences)
				elseif actor.jumping then
					Cues.play(root, "jump", preferences)
				end
				if not scope:isReduced() then
					button.face.Rotation = -2
					scope:to(button.face, { Rotation = 0 }, "abilityConfirm")
				end
			end
			lastPower[slot] = cooldown
		end
		if large and changed then
			local ids = state.series and state.series.winnerIds or {}
			local winner = if phase == "Final" then ids[1] else state.roundWinnerId
			local name = "SURVIVOR"
			local rank = nil
			for _, p in if state.series then state.series.players else {} do
				if p.id == winner then
					name = p.name
				end
				if p.id == selfId then
					rank = p.rank
				end
			end
			local isWinner = table.find(ids, selfId) ~= nil
			Cues.play(root, if phase == "Final" and isWinner then "victory" else "settle", preferences)
			title.Text = if phase == "Final"
				then (if #ids > 1 then "SHARED WIN!" elseif isWinner then "YOU WIN!" else name .. " WINS!")
				elseif me and me.alive then "ROUND SURVIVED!"
				else "ROUND COMPLETE"
			detail.Text = if phase == "Final"
				then (if isWinner then "NICE RUN · PLAY AGAIN?" else "YOU #" .. tostring(rank or "-") .. " · " .. name)
				else "SCORES IN · NEXT IN " .. state.intermission
			title.TextWrapped = false
			title.TextTruncate = Enum.TextTruncate.AtEnd
			detail.TextWrapped = false
			detail.TextTruncate = Enum.TextTruncate.AtEnd
			hero.BackgroundColor3 = if phase == "Final" and isWinner then Kit.colors.yellow else Kit.colors.mint
			local sprite = sprites[winner or selfId] or sprites[selfId]
			local color = if sprite then sprite.color else Kit.colors.coral
			art.shell.BackgroundColor3 = color
			art.face.BackgroundColor3 = color
			art.shade.BackgroundColor3 = color:Lerp(Kit.colors.ink, 0.22)
			art.rim.BackgroundColor3 = color:Lerp(Kit.colors.paper, 0.55)
			avatar.Rotation = if scope:isReduced() then -10 else -30
			local targetSize = avatar.Size
			if not scope:isReduced() then
				avatar.Size = UDim2.fromOffset(targetSize.X.Offset * 0.75, targetSize.Y.Offset * 0.75)
			end
			scope:to(
				avatar,
				{ Rotation = -10, Size = targetSize },
				if phase == "Final" then "matchCelebrate" else "roundCelebrate"
			)
			if phase == "Final" or me and me.alive then
				burst(hero.Position.X.Offset + hero.Size.X.Offset * 0.8, hero.Position.Y.Offset + 20)
			end
		elseif phase == "Intermission" then
			detail.Text = "SCORES IN · NEXT ROUND IN " .. state.intermission
		end
		previousPhase, previousRound, previousRemaining = phase, state.roundId, state.remaining
		previousActor = actor and actor.state
		return boardRect
	end
	return {
		update = update,
		enter = function()
			cancel()
			previousPhase = nil
			previousActor = nil
			lastPower = {}
			root.Visible = true
			parent.Position = UDim2.fromOffset(0, if scope:isReduced() then 0 else 6)
			scope:to(parent, { Position = UDim2.fromOffset(0, 0) }, "rematchEnter")
		end,
		hide = function()
			cancel()
			root.Visible = false
			previousPhase = nil
			previousActor = nil
			lastPower = {}
		end,
		setReduced = function(value)
			scope:setReducedMotion(value)
			if value then
				for _, chip in confetti do
					chip.Visible = false
				end
			end
		end,
		destroy = function()
			cancel()
			scope:destroy()
			root:Destroy()
		end,
	}
end
return Presentation
