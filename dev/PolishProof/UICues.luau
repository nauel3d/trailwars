--!strict
-- Original source WAVs: assets/snap-audio. IDs stay absent until real upload succeeds.
local Cues = {}
local Assets: any = {}
function Cues.available(): boolean
	return next(Assets) ~= nil
end
local last = setmetatable({}, { __mode = "k" })
function Cues.play(parent: Instance, kind: string, preferences: any?)
	if preferences and (preferences.muted or preferences.volume == 0) then
		return
	end
	local id = Assets[kind]
	if not id then
		return
	end
	local gui = if parent:IsA("ScreenGui") then parent else parent:FindFirstAncestorOfClass("ScreenGui")
	if not gui or os.clock() - (last[gui] or -1) < 0.08 then
		return
	end
	last[gui] = os.clock()
	local pool = gui:FindFirstChild("UICueVoices")
	if not pool then
		pool = Instance.new("Folder")
		pool.Name = "UICueVoices"
		pool.Parent = gui
		for i = 1, 3 do
			local sound = Instance.new("Sound")
			sound.Name = "Voice" .. i
			sound.Parent = pool
		end
	end
	local voices = pool:GetChildren()
	local chosen = voices[1] :: Sound
	for _, voice in voices do
		if not (voice :: Sound).IsPlaying then
			chosen = voice :: Sound
			break
		end
	end
	chosen:Stop()
	chosen.SoundId = id
	chosen.Volume = math.clamp(if preferences then preferences.volume or 0.22 else 0.22, 0, 0.4)
	chosen:Play()
end
return Cues
