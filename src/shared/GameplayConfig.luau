--!strict
-- Original prototype calibration. See research/gameplay-reconstruction/unknowns.md.
-- Recovered client calibration: 50Hz, speed105 and angular rate≈2.6rad/s.
-- Arena scale, collider tolerances, self-tail grace and round timing are CUSTOM.
return table.freeze({
	TickRate = 50,
	Step = 1 / 50,
	Speed = 105,
	TurnRate = 2.6,
	RampSeconds = 0.5,
	Width = 1300,
	Height = 800,
	CoreRadius = 4.5,
	VisualRadius = 6.5,
	TrailRadius = 4,
	SelfGraceDistance = 12,
	CellSize = 40,
	CountdownSeconds = 3,
	MaxRoundSeconds = 45,
	MaxPlayers = 6,
	MaxSegments = 20000,
	MaxCatchupSteps = 8,
	MaxBacklogSeconds = 0.5,
	InputLeaseTicks = 20,
	SnapshotTicks = 5,
	MaxSegmentsPerPacket = 600,
	MaxInputMessagesPerSecond = 40,
	MaxSequence = 2147483647,
	ResultsSeconds = 4,
	QueueSeconds = 2,
	SoloPracticeDelay = 12,
	EnableTrailGaps = false,
	EnableProductionRewards = false,
})
