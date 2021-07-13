local oldPlayerReset_Lite = Player.Reset_Lite
function Player:Reset_Lite()
	if GetHasGameRules() then
		local alienTeam = GetGamerules():GetTeam(kTeam2Type)
		local owner = Server.GetOwner(self)
		if owner then
			local clientId = owner:GetUserId()
			alienTeam:RemoveGorgeStructureFromClient(kTechId.GorgeCrag, clientId)
			alienTeam:RemoveGorgeStructureFromClient(kTechId.GorgeShade, clientId)
			alienTeam:RemoveGorgeStructureFromClient(kTechId.GorgeShift, clientId)
			alienTeam:RemoveGorgeStructureFromClient(kTechId.GorgeTunnel, clientId)
			alienTeam:RemoveGorgeStructureFromClient(kTechId.GorgeWhip, clientId)
		end
	end
	oldPlayerReset_Lite(self)
end
