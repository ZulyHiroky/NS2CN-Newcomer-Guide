Script.Load("lua/DigestMixin.lua")

class 'GorgeShade' (Shade)

GorgeShade.kCloakRadius = kGorgeShadeCloakRadius
GorgeShade.kMapName = "gorgeshade"
GorgeShade.kMaxUseableRange = 6.5
local kDigestDuration = 1.5
local networkVars =
{
    ownerId = "entityid"
}

function GorgeShade:OnCreate()
	Shade.OnCreate(self)
    InitMixin(self, DigestMixin)
end

function GorgeShade:GetDigestDuration()
    return kDigestDuration
end

function GorgeShade:GetUseMaxRange()
    return self.kMaxUseableRange
end

function GorgeShade:GetMapBlipType()
    return kMinimapBlipType.Shade	
end

function GorgeShade:GetUnitNameOverride(viewer)
    
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
                return string.format( "%s' Shade", ownerName )
            else
                return string.format( "%s's Shade", ownerName )
            end
        end
    
    end
    
    return unitName

end

if not Server then
    function GorgeShade:GetOwner()
        return self.ownerId ~= nil and Shared.GetEntity(self.ownerId)
    end
end

function GorgeShade:GetCanDigest(player)
    return player == self:GetOwner() and player:isa("Gorge") and (not HasMixin(self, "Live") or self:GetIsAlive())
end

-- CQ: Predates Mixins, somewhat hackish
function GorgeShade:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = useSuccessTable.useSuccess and self:GetCanDigest(player)
end

function GorgeShade:GetCanBeUsedConstructed()
    return true
end

function GorgeShade:GetCanTeleportOverride()
    return false
end

function GorgeShade:GetCanConsumeOverride()
    return false
end

function GorgeShade:GetCanReposition()
	return false
end

function GorgeShade:OnOverrideOrder(order)
	order:SetType(kTechId.Default)
end

function GorgeShade:GetTechButtons(techId)
	local techButtons = { kTechId.ShadeInk, kTechId.None, kTechId.ShadeCloak, kTechId.None, 
                          kTechId.None, kTechId.None, kTechId.None, kTechId.None }
	
    return techButtons
    
end

function GorgeShade:OnDestroy()
    AlienStructure.OnDestroy(self)
    if Server then
		local team = self:GetTeam()
        if team then
            team:UpdateClientOwnedStructures(self:GetId())
        end	
		local player = self:GetOwner()
		if player then
			if (self.consumed) then
				player:AddResources(kGorgeShadeCostDigest)
			else
				player:AddResources(kGorgeShadeCostKill)
			end
		end
    end
end

function GorgeShade:GetMatureMaxHealth()
    return kGorgeShadeHealth * 1.5
end 

function GorgeShade:GetMatureMaxArmor()
    return kGorgeShadeArmor * 1.5
end

function GorgeShade:OnAdjustModelCoords(modelCoords)
        
    local coords = modelCoords
	coords.xAxis = coords.xAxis * 0.7
	coords.yAxis = coords.yAxis * 0.7
	coords.zAxis = coords.zAxis * 0.7
    modelCoords = coords
    
    return modelCoords
    
end

Shared.LinkClassToMap("GorgeShade", GorgeShade.kMapName, networkVars)