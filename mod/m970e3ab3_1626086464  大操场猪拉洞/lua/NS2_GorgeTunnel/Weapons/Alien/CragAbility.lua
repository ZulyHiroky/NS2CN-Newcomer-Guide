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

class 'CragStructureAbility' (StructureAbility)

CragStructureAbility.kDropRange = 6.5

function CragStructureAbility:GetDropRange()
    return CragStructureAbility.kDropRange
end

function CragStructureAbility:GetEnergyCost()
    return 40 -- Todo: Make a balance var
end

function CragStructureAbility:GetGhostModelName(ability)
   
    return Crag.kModelName
    
end

function CragStructureAbility:GetDropStructureId()
    return kTechId.GorgeCrag
end

local function EntityCalculateCragFilter(entity)
    return function (test) return EntityFilterOneAndIsa(entity, "Clog") or test:isa("GorgeCrag") end
end

local function CalculateCragPosition(position, player, normal)

    PROFILE("CalculateCragPosition")

	local valid = true
    if valid then
        local extents = GetExtents(kTechId.GorgeCrag) / 2.25
        local traceStart = position + normal * 0.15 -- A bit above to allow crags to be placed on uneven ground easily
        local traceEnd = position + normal * extents.y
        local trace = Shared.TraceBox(extents, traceStart, traceEnd, CollisionRep.Damage, PhysicsMask.Bullets, EntityCalculateCragFilter(player))

        if trace.fraction ~= 1 then
            -- DebugTraceBox(extents, traceStart, traceEnd, 0.1, 45, 45, 45, 1)
            valid = false
        end
    end

    return valid

end

function CragStructureAbility:GetIsPositionValid(position, player, surfaceNormal)

    PROFILE("CragStructureAbility:GetIsPositionValid")

    return CalculateCragPosition(position, player, surfaceNormal)

end

function CragStructureAbility:GetSuffixName()
    return "gorgecrag"
end

function CragStructureAbility:GetDropClassName()
    return "GorgeCrag"
end

function CragStructureAbility:GetDropMapName()
    return GorgeCrag.kMapName
end
