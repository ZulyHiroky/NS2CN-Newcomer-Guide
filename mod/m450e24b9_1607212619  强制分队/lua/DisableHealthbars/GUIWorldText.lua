
local oldUpdateDamageMessage = GUIWorldText.UpdateDamageMessage
function GUIWorldText:UpdateDamageMessage(message, messageItem, useColor, deltaTime)
    oldUpdateDamageMessage(self, message, messageItem, useColor, deltaTime)
    if  message.entityId ~= nil then
        local entity =  Shared.GetEntity(message.entityId)
        if entity and entity.GetHealthScalar and not entity:isa("Babbler") then
            local scalar = entity:GetHealthScalar()
            if kClientDamageColor == 1 then
                useColor.r = Clamp(2*math.pow(1- scalar, 2.0), 0, 1)
                useColor.g = Clamp(2*math.pow(scalar, 1.0), 0, 1)
                useColor.b = 0.1 -- Clamp( -3 * math.pow((scalar-0.5),2)+1, 0, 1)
            elseif kClientDamageColor == 2 then
                useColor.r = 0.1 
                useColor.g = Clamp(2*math.pow(scalar, 2.0), 0, 1)
                useColor.b = Clamp(2*math.pow(1- scalar, 0.5), 0, 1)-- Clamp( -3 * math.pow((scalar-0.5),2)+1, 0, 1)
            else
                -- leave to default/NS2+
            end
            useColor.a = kClientDamageOpacity or 1
        end
        messageItem:SetColor(useColor)
    end

end