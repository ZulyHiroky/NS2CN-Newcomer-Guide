local function FilterBabblersAndTwo(ent1, ent2)
    return function (test) return test == ent1 or test == ent2 or test:isa("Babbler") end
end

function DropStructureAbility:GetPositionForStructure(startPosition, direction, structureAbility, lastClickedPosition, lastClickedPositionNormal)

    PROFILE("DropStructureAbility:GetPositionForStructure")

    local validPosition = false
    local range = structureAbility:GetDropRange(lastClickedPosition)
    local origin = startPosition + direction * range
    local player = self:GetParent()

    -- Trace short distance in front
    local trace = Shared.TraceRay(player:GetEyePos(), origin, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, FilterBabblersAndTwo(player, self))

    local displayOrigin = trace.endPoint


    -- If we hit nothing, try a slightly bigger ray
    if trace.fraction == 1 then
        local boxTrace = Shared.TraceBox(Vector(0.2,0.2,0.2), player:GetEyePos(), origin,  CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
        if boxTrace.entity and boxTrace.entity:isa("Web") then
            trace = boxTrace
        end

    end

    -- If we still hit nothing, trace down to place on ground
    if trace.fraction == 1 then
	
        origin = startPosition + direction * range
		if structureAbility.GetDropMapName() == Clog.kMapName then
			-- vertical ground check has long range
			range = 40
		end
        trace = Shared.TraceRay(origin, origin - Vector(0, range, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, FilterBabblersAndTwo(player, self))
    end

    -- If it hits something, position on this surface (must be the world or another structure)
    if trace.fraction < 1 then

        if trace.entity == nil then
            validPosition = true

        elseif trace.entity:isa("Infestation") or trace.entity:isa("Clog") then
            validPosition = true
        elseif trace.entity:isa("Web") and structureAbility.GetDropMapName() == Clog.kMapName then
            -- Allow up to 3 entites on a web
            validPosition = true
        end

        displayOrigin = trace.endPoint
		
    end

    -- Can only be built on infestation
    local requiresInfestation = LookupTechData(structureAbility.GetDropStructureId(), kTechDataRequiresInfestation)
    if requiresInfestation and not GetIsPointOnInfestation(displayOrigin) then

        if self:GetActiveStructure().OverrideInfestationCheck then
            validPosition = self:GetActiveStructure():OverrideInfestationCheck(trace)
        else
            validPosition = false
        end

    end

    if not structureAbility.AllowBackfacing() and trace.normal:DotProduct(GetNormalizedVector(startPosition - trace.endPoint)) < 0 then
        validPosition = false
    end

    -- Don't allow dropped structures to go too close to techpoints and resource nozzles
    if GetPointBlocksAttachEntities(displayOrigin) then
        validPosition = false
    end

    if not structureAbility:GetIsPositionValid(displayOrigin, player, trace.normal, lastClickedPosition, lastClickedPositionNormal, trace.entity) then
        validPosition = false
    end

    if trace.surface == "nocling" then
        validPosition = false
    end

    -- Don't allow placing above or below us and don't draw either
    local structureFacing = Vector(direction)

    if math.abs(Math.DotProduct(trace.normal, structureFacing)) > 0.9 then
        structureFacing = trace.normal:GetPerpendicular()
    end

    -- Coords.GetLookIn will prioritize the direction when constructing the coords,
    -- so make sure the facing direction is perpendicular to the normal so we get
    -- the correct y-axis.
    local perp = Math.CrossProduct( trace.normal, structureFacing )
    structureFacing = Math.CrossProduct( perp, trace.normal )

    local coords = Coords.GetLookIn( displayOrigin, structureFacing, trace.normal )

    if structureAbility.ModifyCoords then
        structureAbility:ModifyCoords(coords, lastClickedPosition, trace.normal, player)
    end

    -- perform a final check to ensure the gorge isn't trying to build from inside a clog.
    if GetIsPointInsideClogs(player:GetEyePos()) then
        validPosition = false
    end

    return coords, validPosition, trace.entity, trace.normal

end
