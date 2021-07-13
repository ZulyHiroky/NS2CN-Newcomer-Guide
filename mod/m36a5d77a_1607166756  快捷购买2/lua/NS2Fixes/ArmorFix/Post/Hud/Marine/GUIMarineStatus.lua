

local oldUpdate = GUIMarineStatus.Update
function GUIMarineStatus:Update(deltaTime, parameters)

    local currentArmor= parameters[3]
	if currentArmor and currentArmor > 0 then
		parameters[3] = math.round(currentArmor)
	end

	return oldUpdate(self, deltaTime, parameters)
end