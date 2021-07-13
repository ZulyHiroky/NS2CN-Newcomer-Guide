if Server then

	function PlayerHallucinationMixin:OnKill(...)

		self:SetBypassRagdoll(true)
		self:TriggerEffects( "death_hallucination" )
		
	end

end