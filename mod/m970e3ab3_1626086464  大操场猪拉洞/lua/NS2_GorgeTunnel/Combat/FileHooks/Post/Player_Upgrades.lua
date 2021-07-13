local oldPlayerReset_Lite = Player.Reset_Lite
function Player:Reset_Lite()
	oldPlayerReset_Lite()
	
end

---- Refunds all the upgrades and resets them back as if they had just joined the team.
--function Player:RefundAllUpgrades()
--
--	self:Reset_Lite()
--	self:AddLvlFree(self:GetLvl() - 1 + kCombatStartUpgradePoints)
--	self:SendDirectMessage("All points refunded. You can choose your upgrades again!")
--
--    for _, exosuit in ipairs(GetEntities("Exosuit")) do
--        local owner = exosuit:GetOwner()
--        if owner and owner == self then
--            exosuit:Kill(nil, nil, self:GetOrigin())
--        end
--    end
--
--	-- Kill the player when they do this. Prevents abuse!
--	if (self:GetIsAlive()) then
--		self:Kill(nil, nil, self:GetOrigin())
--	end
--end
