--!strict
-- Original bounded playtest balance, not claimed reference parity.
return table.freeze({
	Homing = table.freeze({
		CooldownTicks = 175,
		InitialTicks = 25,
		Speed = 270,
		TurnRate = 3.5,
		Radius = 7,
		LifeTicks = 225,
		Steal = 3,
		Range = 360,
	}),
	Jump = table.freeze({ CooldownTicks = 300, InitialTicks = 25, DurationTicks = 23 }),
	Turret = table.freeze({
		IntervalTicks = 150,
		InitialTicks = 25,
		Speed = 240,
		TurnRate = 3.2,
		Radius = 7,
		LifeTicks = 250,
		Steal = 1,
	}),
	MaxProjectiles = 18,
})
