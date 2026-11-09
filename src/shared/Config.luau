--!strict
-- Integration switches are deliberately closed. No paid item IDs exist yet.
return table.freeze({
	SchemaVersion = 1,
	DataStoreName = "TrailWars_Profile_v1",
	LeaseSeconds = 120,
	HeartbeatSeconds = 30,
	MaxReceiptRecords = 10000,
	MaxRewardRecords = 2000,
	EnableLivePurchases = false,
	EnableProductionProfiles = false,
	EnableStudioMock = true,
	RemoteCooldownSeconds = 0.35,
})
