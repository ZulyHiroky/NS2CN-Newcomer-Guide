
--[[local networkVars =
{
    -- For client animations
    --healingActive = "boolean",
    --healWaveActive = "boolean",
    --gorge = "boolean",
    --moving = "boolean",
    --ownerId = "entityid"
}--]]

--[[function Crag:GetUnitNameOverride(viewer)
    
    local unitName = GetDisplayName(self)
    
    if self.gorge and not GetAreEnemies(self, viewer) and self.ownerId then
        local ownerName
        for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
            if playerInfo.playerId == self.ownerId then
                ownerName = playerInfo.playerName
                break
            end
        end
        if ownerName then
            
            local lastLetter = ownerName:sub(-1)
            if lastLetter == "s" or lastLetter == "S" then
                return string.format( "%s' Crag", ownerName )
            else
                return string.format( "%s's Crag", ownerName )
            end
        end
    
    end
    
    return unitName

end--]]

--Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)
Script.Load("lua/DigestMixin.lua")

class 'GorgeCrag' (Crag)

GorgeCrag.kMapName = "gorgecrag"
GorgeCrag.kMaxUseableRange = 6.5

local networkVars =
{
    ownerId = "entityid"
}

local kDigestDuration = 1.5

function GorgeCrag:OnCreate()
	Crag.OnCreate(self)
    InitMixin(self, DigestMixin)
end

function GorgeCrag:GetUseMaxRange()
    return self.kMaxUseableRange
end

function GorgeCrag:GetTechButtons(techId)
    local techButtons = { kTechId.HealWave, kTechId.None, kTechId.CragHeal, kTechId.None,
                              kTechId.None, kTechId.None, kTechId.None, kTechId.None }
        
    return techButtons
    
end

if not Server then
    function Crag:GetOwner()
        return self.ownerId ~= nil and Shared.GetEntity(self.ownerId)
    end
end

function GorgeCrag:OnDestroy()
    AlienStructure.OnDestroy(self)
    if Server then
		local team = self:GetTeam()
        if team then
            team:UpdateClientOwnedStructures(self:GetId())
        end
		local player = self:GetOwner()
		if player then
			if (self.consumed) then
				player:AddResources(kGorgeCragCostDigest)
			else
				player:AddResources(kGorgeCragCostKill)
			end
		end
    end
end

function GorgeCrag:GetUnitNameOverride(viewer)
    
    local unitName = GetDisplayName(self)
    
    if not GetAreEnemies(self, viewer) and self.ownerId then
        local ownerName
        for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
            if playerInfo.playerId == self.ownerId then
                ownerName = playerInfo.playerName
                break
            end
        end
        if ownerName then
            
            local lastLetter = ownerName:sub(-1)
            if lastLetter == "s" or lastLetter == "S" then
                return string.format( "%s' Crag", ownerName )
            else
                return string.format( "%s's Crag", ownerName )
            end
        end
    
    end
    
    return unitName

end

-- CQ: Predates Mixins, somewhat hackish
function GorgeCrag:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = useSuccessTable.useSuccess and self:GetCanDigest(player)
end

function GorgeCrag:GetCanBeUsedConstructed()
    return true
end

function GorgeCrag:GetCanTeleportOverride()
    return false
end

function GorgeCrag:GetCanConsumeOverride()
    return false
end

function GorgeCrag:GetCanReposition()
    return false
end

function GorgeCrag:GetCanDigest(player)
    return player == self:GetOwner() and player:isa("Gorge") and (not HasMixin(self, "Live") or self:GetIsAlive())
end

function GorgeCrag:GetDigestDuration()
    return kDigestDuration
end

function GorgeCrag:OnOverrideOrder(order)
    --if self.ownerId ~= nil then
        order:SetType(kTechId.Default)
    --elseif order:GetType() == kTechId.Default then
    --    order:SetType(kTechId.Move)
    --end
end

function GorgeCrag:GetMapBlipType()
    return kMinimapBlipType.Crag
end

function GorgeCrag:GetMatureMaxHealth()
    return kGorgeCragHealth * 1.5
end 

function GorgeCrag:GetMatureMaxArmor()
    return kGorgeCragArmor * 1.5
end

function GorgeCrag:OnAdjustModelCoords(modelCoords)
        
    local coords = modelCoords
	coords.xAxis = coords.xAxis * 0.7
	coords.yAxis = coords.yAxis * 0.7
	coords.zAxis = coords.zAxis * 0.7
    modelCoords = coords
    
    return modelCoords
    
end

Shared.LinkClassToMap("GorgeCrag", GorgeCrag.kMapName, networkVars)