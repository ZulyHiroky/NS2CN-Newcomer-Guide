-- Gorge select structure message
Shared.RegisterNetworkMessage("GorgeBuildStructure", {
	origin = "vector",
	direction = "vector",
	structureIndex = "integer (1 to 9)",
	lastClickedPosition = "vector",
	lastClickedPositionNormal = "vector"
})
