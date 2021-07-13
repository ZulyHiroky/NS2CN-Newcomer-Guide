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

class 'ShiftStructureAbility' (StructureAbility)

ShiftStructureAbility.kDropRange = 6.5

function ShiftStructureAbility:GetDropRange()
    return ShiftStructureAbility.kDropRange
end

function ShiftStructureAbility:GetEnergyCost()
    return 40 -- Todo: Make a balance var
end

function ShiftStructureAbility:GetGhostModelName(ability)
   
    return Shift.kModelName
    
end

function ShiftStructureAbility:GetDropStructureId()
    return kTechId.GorgeShift
end

local function EntityCalculateShiftFilter(entity)
    return function (test) return EntityFilterOneAndIsa(entity, "Clog") or test:isa("GorgeShift") end
end

local function CalculateShiftPosition(position, player, normal)

    PROFILE("CalculateShiftPosition")

	local valid = true
    if valid then
        local extents = GetExtents(kTechId.GorgeShift) / 2.25
        local traceStart = position + normal * 0.15 -- A bit above to allow shifts to be placed on uneven ground easily
        local traceEnd = position + normal * extents.y
        local trace = Shared.TraceBox(extents, traceStart, traceEnd, CollisionRep.Damage, PhysicsMask.Bullets, EntityCalculateShiftFilter(player))

        if trace.fraction ~= 1 then
            -- DebugTraceBox(extents, traceStart, traceEnd, 0.1, 45, 45, 45, 1)
            valid = false
        end
    end

    return valid

end

function ShiftStructureAbility:GetIsPositionValid(position, player, surfaceNormal)

    PROFILE("ShiftStructureAbility:GetIsPositionValid")

    return CalculateShiftPosition(position, player, surfaceNormal)

end

function ShiftStructureAbility:GetSuffixName()
    return "gorgeshift"
end

function ShiftStructureAbility:GetDropClassName()
    return "GorgeShift"
end

function ShiftStructureAbility:GetDropMapName()
    return GorgeShift.kMapName
end
