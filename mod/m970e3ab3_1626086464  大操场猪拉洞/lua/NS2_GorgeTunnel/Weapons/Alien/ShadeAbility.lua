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

class 'ShadeStructureAbility' (StructureAbility)

ShadeStructureAbility.kDropRange = 6.5

function ShadeStructureAbility:GetDropRange()
    return ShadeStructureAbility.kDropRange
end

function ShadeStructureAbility:GetEnergyCost()
    return 40 -- Todo: Make a balance var
end

function ShadeStructureAbility:GetGhostModelName(ability)
   
    return Shade.kModelName
    
end

function ShadeStructureAbility:GetDropStructureId()
    return kTechId.GorgeShade
end

local function EntityCalculateShadeFilter(entity)
    return function (test) return EntityFilterOneAndIsa(entity, "Clog") or test:isa("GorgeShade") end
end

local function CalculateShadePosition(position, player, normal)

    PROFILE("CalculateShadePosition")

	local valid = true
    if valid then
        local extents = GetExtents(kTechId.GorgeShade) / 2.25
        local traceStart = position + normal * 0.15 -- A bit above to allow shades to be placed on uneven ground easily
        local traceEnd = position + normal * extents.y
        local trace = Shared.TraceBox(extents, traceStart, traceEnd, CollisionRep.Damage, PhysicsMask.Bullets, EntityCalculateShadeFilter(player))

        if trace.fraction ~= 1 then
            -- DebugTraceBox(extents, traceStart, traceEnd, 0.1, 45, 45, 45, 1)
            valid = false
        end
    end

    return valid

end

function ShadeStructureAbility:GetIsPositionValid(position, player, surfaceNormal)

    PROFILE("ShadeStructureAbility:GetIsPositionValid")

    return CalculateShadePosition(position, player, surfaceNormal)

end

function ShadeStructureAbility:GetSuffixName()
    return "gorgeshade"
end

function ShadeStructureAbility:GetDropClassName()
    return "GorgeShade"
end

function ShadeStructureAbility:GetDropMapName()
    return GorgeShade.kMapName
end
