Log("Hiding health bars")
local oldUpdateUnitStatusBlip = GUIUnitStatus.UpdateUnitStatusBlip
function GUIUnitStatus:UpdateUnitStatusBlip( blipIndex, localPlayerIsCommander, baseResearchRot, showHints, playerTeamType )
    oldUpdateUnitStatusBlip(self, blipIndex, localPlayerIsCommander, baseResearchRot, showHints, playerTeamType )
    
    local blipData = self.activeStatusInfo[blipIndex]
    local teamType = blipData.TeamType
    local isPlayer = blipData.IsPlayer
    local isEnemy = false
    
    if isPlayer then
        if kAnyTeamEnabled then
            -- anyteam fixes this function, and makes playerTeamType the team number
            isEnemy = playerTeamType ~= blipData.TeamNumber
        elseif playerTeamType ~= kNeutralTeamType then
            isEnemy = (playerTeamType ~= teamType) and (teamType ~= kNeutralTeamType)
        end
        
        if isEnemy then
            local updateBlip = self.activeBlipList[blipIndex]
            updateBlip.HealthBarBg:SetIsVisible(false)
            updateBlip.ArmorBarBg:SetIsVisible(false)
            updateBlip.GraphicsItem:SetIsVisible(false)
            updateBlip.NameText:SetIsVisible(false)
            updateBlip.HintText:SetIsVisible(false)
        end
    end
end