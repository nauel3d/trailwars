--!strict
-- Presentation seconds, never simulation clocks or input gates.
return table.freeze({
	Spawn = 0.18,
	JumpLift = 0.08,
	Landing = 0.18,
	Launch = 0.12,
	Crash = 0.48,
	Hit = 0.30,
	StaticImpact = 0.32,
	ProjectileBlend = 0.08,
	GoHold = 0.30,
	DeltaHold = 0.25,
	ScoreStart = 0.55,
	ReorderStart = 1.00,
	ScoreEnd = 1.40,
	Tweens = {
		coreSpawn = { time = 0.18, ease = "Back" },
		countdownPop = { time = 0.14, ease = "Back" },
		goPop = { time = 0.20, ease = "Back" },
		abilityConfirm = { time = 0.12, ease = "Quad" },
		turretEnter = { time = 0.22, ease = "Back" },
		roundCelebrate = { time = 0.35, ease = "Back" },
		scoreFill = { time = 0.40, ease = "Quad" },
		rankMove = { time = 0.22, ease = "Cubic" },
		matchCelebrate = { time = 0.65, ease = "Back" },
		rematchEnter = { time = 0.16, ease = "Quad" },
	},
})
