
if Server then

	local oldForceEvenTeams = ForceEvenTeams
	function ForceEvenTeams()
		oldForceEvenTeams()
		if GetGamerules():GetGameStarted() then
			GetGamerules():ResetGame()
		end
	end
	
end