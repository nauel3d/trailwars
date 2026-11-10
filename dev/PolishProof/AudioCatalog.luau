--!strict
return {
	select = { file = "select.wav", priority = 1, repeatSeconds = 0.10, gain = 0.65 },
	press = { file = "press.wav", priority = 1, repeatSeconds = 0.08, gain = 0.65 },
	back = { file = "back.wav", priority = 1, repeatSeconds = 0.12, gain = 0.6 },
	confirm = { file = "confirm.wav", priority = 2, repeatSeconds = 0.18, gain = 0.8 },
	queue = { file = "queue.wav", priority = 2, repeatSeconds = 0.8, gain = 0.75 },
	go = { file = "go.wav", priority = 3, repeatSeconds = 0.8, gain = 0.85 },
	jump = { file = "jump.wav", priority = 2, repeatSeconds = 0.2, gain = 0.65 },
	launch = { file = "launch.wav", priority = 2, repeatSeconds = 0.15, gain = 0.6 },
	hit = { file = "hit.wav", priority = 2, repeatSeconds = 0.12, gain = 0.65 },
	crash = { file = "crash.wav", priority = 3, repeatSeconds = 0.25, gain = 0.75 },
	rank = { file = "rank.wav", priority = 2, repeatSeconds = 0.4, gain = 0.65 },
	settle = { file = "settle.wav", priority = 2, repeatSeconds = 0.5, gain = 0.65 },
	victory = { file = "victory.wav", priority = 3, repeatSeconds = 1, gain = 0.85 },
	error = { file = "warning.wav", priority = 2, repeatSeconds = 0.25, gain = 0.6 },
}
