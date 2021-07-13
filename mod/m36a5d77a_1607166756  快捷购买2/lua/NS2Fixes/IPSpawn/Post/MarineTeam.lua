
local oldSpawnInfantryPortal = debug.getupvaluex(MarineTeam.SpawnInitialStructures, "SpawnInfantryPortal")

local function SpawnInfantryPortal(self, techPoint)

	oldSpawnInfantryPortal(self, techPoint)
	self.spawnedPortals = self.spawnedPortals + 1

end

debug.setupvaluex(MarineTeam.SpawnInitialStructures, "SpawnInfantryPortal", SpawnInfantryPortal, true)

local oldOnInitialized = MarineTeam.OnInitialized
function MarineTeam:OnInitialized()
	self.spawnedPortals = 0
	oldOnInitialized(self)
end

local oldResetTeam = MarineTeam.ResetTeam
function MarineTeam:ResetTeam()
	self.spawnedPortals = 0
	return oldResetTeam(self)
end

local oldUpdate = MarineTeam.Update
function MarineTeam:Update(timePassed)

    oldUpdate(self, timePassed)
	
	local gameLength = Shared.GetTime() - GetGamerules():GetGameStartTime()
	if self.startTechPoint and self.spawnedPortals == 1 and
		gameLength < kMaxTimeBeforeReset and self:GetNumPlayers() > 8 then
		
		-- this will increment self.spawnedPortals
		SpawnInfantryPortal(self, self.startTechPoint)
		
		if GetGamerules():GetGameStarted() then
			Shared.Message("Spawning an extra infantry portal for marines due to a 9th player joining.")
		end
		
	end
    
end


