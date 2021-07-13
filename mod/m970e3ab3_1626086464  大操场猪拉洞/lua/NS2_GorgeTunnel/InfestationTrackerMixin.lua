local updateInterval = 0.125
function InfestationTrackerMixin:UpdateInfestedState(onInfestation)
    --if self.infestedUpdateTime == Shared.GetTime() then return end
    if self.infestedUpdateTime and self.infestedUpdateTime > Shared.GetTime() then return end
    
    self.infestedUpdateTime = Shared.GetTime() + updateInterval

    -- no need to check here, since we already know that this place is infested
    if onInfestation then
        self:SetInfestationState(true)
    else
        UpdateInfestationMask(self)
    end

end