
--[[function Shift:GetUnitNameOverride(viewer)
    
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
                return string.format( "%s' Shift", ownerName )
            else
                return string.format( "%s's Shift", ownerName )
            end
        end
    
    end
    
    return unitName

end--]]

Script.Load("lua/DigestMixin.lua")

class 'GorgeShift' (Shift)

GorgeShift.kMapName = "gorgeshift"
GorgeShift.kMaxUseableRange = 6.5

local networkVars =
{
    ownerId = "entityid"
}

local kDigestDuration = 1.5


function GorgeShift:OnCreate()
	Shift.OnCreate(self)
    InitMixin(self, DigestMixin)
end

function GorgeShift:GetTechButtons(techId)

    local techButtons = { kTechId.None, kTechId.None, kTechId.ShiftEnergize, kTechId.None,
							kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    return techButtons   

end


function GorgeShift:GetMapBlipType()
    return kMinimapBlipType.Shift
end

function GorgeShift:GetUnitNameOverride(viewer)
    
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
                return string.format( "%s' Shift", ownerName )
            else
                return string.format( "%s's Shift", ownerName )
            end
        end
    
    end
    
    return unitName

end

if not Server then
    function GorgeShift:GetOwner()
        return self.ownerId ~= nil and Shared.GetEntity(self.ownerId)
    end
end


-- CQ: Predates Mixins, somewhat hackish
function GorgeShift:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = useSuccessTable.useSuccess and self:GetCanDigest(player)
end

function GorgeShift:GetCanBeUsedConstructed()
    return true
end

function GorgeShift:GetCanTeleportOverride()
    return false
end

function GorgeShift:GetCanConsumeOverride()
    return false
end

function GorgeShift:GetCanReposition()
	return false
end

function GorgeShift:GetCanDigest(player)
    return player == self:GetOwner() and player:isa("Gorge") and (not HasMixin(self, "Live") or self:GetIsAlive())
end


function GorgeShift:GetDigestDuration()
    return kDigestDuration
end

function GorgeShift:GetUseMaxRange()
    return self.kMaxUseableRange
end

function GorgeShift:OnOverrideOrder(order)
	order:SetType(kTechId.Default)
	--elseif order:GetType() == kTechId.Default then
	--order:SetType(kTechId.Move)
	--end
end

function GorgeShift:OnDestroy()
    AlienStructure.OnDestroy(self)
    if Server then
		local team = self:GetTeam()
        if team then
            team:UpdateClientOwnedStructures(self:GetId())
        end
		local player = self:GetOwner()
		if player then
			if (self.consumed) then
				player:AddResources(kGorgeShiftCostDigest)
			else
				player:AddResources(kGorgeShiftCostKill)
			end
		end
    end
end

function GorgeShift:GetMatureMaxHealth()
    return kGorgeShiftHealth * 1.5
end 

function GorgeShift:GetMatureMaxArmor()
    return kGorgeShiftArmor * 1.5
end

function GorgeShift:OnAdjustModelCoords(modelCoords)
        
    local coords = modelCoords
	coords.xAxis = coords.xAxis * 0.7
	coords.yAxis = coords.yAxis * 0.7
	coords.zAxis = coords.zAxis * 0.7
    modelCoords = coords
    
    return modelCoords
    
end


Shared.LinkClassToMap("GorgeShift", GorgeShift.kMapName, networkVars)
