--!strict
-- Bounded shared local audio. Empty verified-ID map means no requests, voices or playback.
local Assets: any = require(script.Parent.AudioAssets)
local Catalog = require(script.Parent.AudioCatalog)
local Cues = {}
local states = setmetatable({}, { __mode = "k" })
local function guiFor(parent)
	return if parent:IsA("ScreenGui") then parent else parent:FindFirstAncestorOfClass("ScreenGui")
end
function Cues.available(): boolean
	return next(Assets) ~= nil
end
function Cues.setVolume(preferences: any, channel: string, value: number)
	if channel == "music" then
		preferences.musicVolume = math.clamp(value, 0, 1)
	else
		preferences.sfxVolume = math.clamp(value, 0, 1)
	end
end
function Cues.stop(parent: Instance)
	local gui = guiFor(parent)
	local state = gui and states[gui]
	if state then
		for _, voice in state.voices do
			voice.sound:Stop()
		end
	end
end
function Cues.play(parent: Instance, kind: string, preferences: any?)
	kind = if kind == "warning" then "error" else kind
	local spec = Catalog[kind]
	local id = Assets[kind]
	if not id or not spec or preferences and preferences.muted then
		return
	end
	local volume = math.clamp(if preferences then preferences.sfxVolume or preferences.volume or 0.22 else 0.22, 0, 0.4)
	if volume == 0 then
		return
	end
	local gui = guiFor(parent)
	if not gui or not gui.Parent then
		return
	end
	local state = states[gui]
	if not state then
		local folder = Instance.new("Folder")
		folder.Name = "UICueVoices"
		folder.Parent = gui
		state = { voices = {}, last = {}, lastAny = -100, folder = folder }
		states[gui] = state
		for i = 1, 4 do
			local sound = Instance.new("Sound")
			sound.Name = "Voice" .. i
			sound.Parent = folder
			state.voices[i] = { sound = sound, priority = 0, started = 0 }
		end
		local connection
		connection = gui.Destroying:Connect(function()
			for _, voice in state.voices do
				voice.sound:Stop()
			end
			connection:Disconnect()
			states[gui] = nil
		end)
	end
	local now = os.clock()
	if now - (state.last[kind] or -100) < spec.repeatSeconds or now - state.lastAny < 0.04 then
		return
	end
	local chosen = nil
	for _, voice in state.voices do
		if not voice.sound.IsPlaying then
			chosen = voice
			break
		end
		if
			not chosen
			or voice.priority < chosen.priority
			or voice.priority == chosen.priority and voice.started < chosen.started
		then
			chosen = voice
		end
	end
	if chosen.sound.IsPlaying and chosen.priority > spec.priority then
		return
	end
	state.last[kind] = now
	state.lastAny = now
	chosen.sound:Stop()
	chosen.sound.SoundId = id
	chosen.sound.Volume = volume * spec.gain
	chosen.priority = spec.priority
	chosen.started = now
	chosen.sound:Play()
end
return Cues
