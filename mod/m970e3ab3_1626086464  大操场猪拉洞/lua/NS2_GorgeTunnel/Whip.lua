Whip.kMoveSpeed = 4.5

-- CQ: EyePos seems to be somewhat hackish; used in several places but not owned anywhere... predates Mixins
function Whip:GetEyePos()
    return self:GetOrigin() + self:GetCoords().yAxis * 1.8 -- Vector(0, 1.8, 0)
end

function Whip:OnAdjustModelCoords(modelCoords)
        
    local coords = modelCoords
	coords.xAxis = coords.xAxis * 1.5
	coords.yAxis = coords.yAxis * 1.2
	coords.zAxis = coords.zAxis * 1.5
    modelCoords = coords
    
    return modelCoords
    
end

Script.Load("lua/DigestMixin.lua")

class 'GorgeWhip' (Whip)

GorgeWhip.kMapName = "gorgewhip"
GorgeWhip.kMaxUseableRange = 6.5
local kDigestDuration = 1.5

local networkVars =
{
    ownerId = "entityid"
}

function GorgeWhip:OnCreate()
	Whip.OnCreate(self)	
    InitMixin(self, DigestMixin)
end

function GorgeWhip:GetUseMaxRange()
    return self.kMaxUseableRange
end

function GorgeWhip:GetMapBlipType()
    return kMinimapBlipType.Whip
end

function GorgeWhip:GetUnitNameOverride(viewer)
    
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
                return string.format( "%s' Whip", ownerName )
            else
                return string.format( "%s's Whip", ownerName )
            end
        end
    
    end
    
    return unitName

end

function GorgeWhip:GetTechButtons(techId)
    local techButtons = { kTechId.Slap, kTechId.None, kTechId.None, kTechId.None,
                        kTechId.None, kTechId.None, kTechId.None, kTechId.None }

    if self:GetIsMature() then
        techButtons[1] = kTechId.WhipBombard
    end
    
    return techButtons
    
end

if not Server then
    function GorgeWhip:GetOwner()
        return self.ownerId ~= nil and Shared.GetEntity(self.ownerId)
    end
end

-- CQ: Predates Mixins, somewhat hackish
function GorgeWhip:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = useSuccessTable.useSuccess and self:GetCanDigest(player)
end

function GorgeWhip:GetCanBeUsedConstructed()
    return true
end

function GorgeWhip:GetCanTeleportOverride()
    return false
end

function GorgeWhip:GetCanConsumeOverride()
    return false
end

function GorgeWhip:GetCanReposition()
    return false
end

function GorgeWhip:GetCanDigest(player)
    return player == self:GetOwner() and player:isa("Gorge") and (not HasMixin(self, "Live") or self:GetIsAlive())
end

function GorgeWhip:GetDigestDuration()
    return kDigestDuration
end

function GorgeWhip:OnOverrideOrder(order)
	order:SetType(kTechId.Default)
end

function GorgeWhip:OnDestroy()
    AlienStructure.OnDestroy(self)
    if Server then
		local team = self:GetTeam()
        if team then
            team:UpdateClientOwnedStructures(self:GetId())
        end	

		local player = self:GetOwner()
		if player then
			if (self.consumed) then
				player:AddResources(kGorgeWhipCostDigest)
			else
				player:AddResources(kGorgeWhipCostKill)
			end
		end

    end
end

function GorgeWhip:GetMatureMaxHealth()
    return kGorgeWhipHealth * 2
end 

function GorgeWhip:GetMatureMaxArmor()
    return kGorgeWhipArmor * 2
end

function GorgeWhip:OnAdjustModelCoords(modelCoords)

    return modelCoords
    
end

Shared.LinkClassToMap("GorgeWhip", GorgeWhip.kMapName, networkVars)