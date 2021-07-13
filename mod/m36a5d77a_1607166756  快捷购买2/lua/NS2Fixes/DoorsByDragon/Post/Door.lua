
function Door:OnUpdateAnimationInput(modelMixin)

    PROFILE("Door:OnUpdateAnimationInput")
    
    local open = self.state == Door.kState.Open

	-- force Predict to always have open doors
    if Predict then
        open = true
    end

    -- local lock = self.state == Door.kState.Locked or self.state == Door.kState.Welded
    
    modelMixin:SetAnimationInput("open", open)
    modelMixin:SetAnimationInput("lock", false)
    
end



Shared.LinkClassToMap("Door", Door.kMapName, {}, true)