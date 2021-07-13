
-- work around a very silly vanilla bug
local oldSetPlayerPoseParameters = SetPlayerPoseParameters
function SetPlayerPoseParameters(player, viewModel, headAngles)
	
	if not player.SetPoseParam then
		return
	end
	oldSetPlayerPoseParameters(player, viewModel, headAngles)
end