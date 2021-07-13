-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\HydraStructureAbility.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
-- Gorge builds hydra.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'WhipStructureAbility' (StructureAbility)

WhipStructureAbility.kDropRange = 6.5

function WhipStructureAbility:GetDropRange()
    return WhipStructureAbility.kDropRange
end

function WhipStructureAbility:GetEnergyCost()
    return 40 -- Todo: Make a balance var
end

function WhipStructureAbility:GetGhostModelName(ability)
   
    return Whip.kModelName
    
end

function WhipStructureAbility:GetDropStructureId()
    return kTechId.GorgeWhip
end

local function EntityCalculateWhipFilter(entity)
    return function (test) return EntityFilterOneAndIsa(entity, "Clog") or test:isa("GorgeWhip") end
end

local function CalculateWhipPosition(position, player, normal)

    PROFILE("CalculateWhipPosition")

	local valid = true
    if valid then
        local extents = GetExtents(kTechId.Whip) / 2.25
        local traceStart = position + normal * 0.15 -- A bit above to allow whips to be placed on uneven ground easily
        local traceEnd = position + normal * extents.y
        local trace = Shared.TraceBox(extents, traceStart, traceEnd, CollisionRep.Damage, PhysicsMask.Bullets, EntityCalculateWhipFilter(player))

        if trace.fraction ~= 1 then
            -- DebugTraceBox(extents, traceStart, traceEnd, 0.1, 45, 45, 45, 1)
            valid = false
        end
    end

    return valid

end

function WhipStructureAbility:GetIsPositionValid(position, player, surfaceNormal)

    PROFILE("WhipStructureAbility:GetIsPositionValid")

    return CalculateWhipPosition(position, player, surfaceNormal)

end

function WhipStructureAbility:GetSuffixName()
    return "gorgewhip"
end

function WhipStructureAbility:GetDropClassName()
    return "GorgeWhip"
end

function WhipStructureAbility:GetDropMapName()
    return GorgeWhip.kMapName
end
