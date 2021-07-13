

local function GetCommander(teamNum)
    local commanders = GetEntitiesForTeam("Commander", teamNum)
    return commanders[1]
end

function RoboticsFactory:ManufactureEntity()

    local mapName = LookupTechData(self.researchId, kTechDataMapName)
    local owner
    
    if self.researchingPlayerId and self.researchingPlayerId ~= Entity.invalidId then
        owner = Shared.GetEntity(self.researchingPlayerId)
    else
        owner = GetCommander(self:GetTeamNumber())
    end
    
    local builtEntity = CreateEntity(mapName, self:GetOrigin(), self:GetTeamNumber())        
    
    if not HasMixin(owner, "Owner") then
        owner = Entity.invalidId
    end
    
    if builtEntity ~= nil then             
        
        if owner ~= nil and owner ~= Entity.invalidId then
            builtEntity:SetOwner(owner)
        end
        builtEntity:SetAngles(self:GetAngles())
        builtEntity:SetIgnoreOrders(true)
       
    end
    
    return builtEntity
    
end