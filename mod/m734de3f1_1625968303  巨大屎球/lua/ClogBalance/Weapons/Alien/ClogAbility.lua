local kMinDistance = 0.669
local kClogOffset = 0.469

function ClogAbility:GetIsPositionValid(position, player, normal)

    local entities = GetEntitiesWithinRange("ScriptActor", position, 7)    
    for _, entity in ipairs(entities) do
    
        if not entity:isa("Infestation") and not entity:isa("Babbler") and entity ~= player and (not entity.GetIsAlive or entity:GetIsAlive()) then
        
            local checkDistance = ConditionalValue(entity:isa("PhaseGate") or entity:isa("TunnelEntrance") or entity:isa("InfantryPortal"), 3, kMinDistance)
            local valid = ((entity:GetCoords().yAxis * checkDistance * 0.75 + entity:GetOrigin()) - position):GetLength() > checkDistance

            if not valid then
                return false
            end
        
        end
    
    end
    
    -- ensure we're not creating clogs inside of other clogs.
    local radius = Clog.kRadius - 0.001
    local entities = GetEntitiesWithinRange("Clog", position, radius)
    for i=1, #entities do
        if entities[i] then
            return false
        end
    end
    
    return true
    

end

function ClogAbility:ModifyCoords(coords)
    coords.origin = coords.origin + coords.yAxis * kClogOffset
end

function ClogAbility:GetDropRange()
    return 3
end