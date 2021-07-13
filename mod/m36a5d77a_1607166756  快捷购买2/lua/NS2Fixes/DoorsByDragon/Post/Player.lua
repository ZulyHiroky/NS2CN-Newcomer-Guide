
if Predict then

	local oldOnUpdatePlayer = Player.OnUpdatePlayer
	function Player:OnUpdatePlayer(deltaTime)
		oldOnUpdatePlayer(self, deltaTime)
		
		for index, entity in ientitylist(Shared.GetEntitiesWithClassname("Door")) do
			if entity.Update then
				entity:Update(deltaTime)
			end
		end
	end

end