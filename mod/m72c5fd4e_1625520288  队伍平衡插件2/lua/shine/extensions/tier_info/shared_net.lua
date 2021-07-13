local Plugin = Plugin

--This will setup a datatable for the plugin, which is a table of networked values.
local MAX_SMURF_LENGTH = 450
local MAX_PLAYER_LENGTH = 2024;
function Plugin:SetupDataTable()
  self:AddDTVar("boolean", "EnableTeamAvgSkill", false)
  self:AddDTVar("boolean", "EnableTeamAvgSkillPregame", true)
  self:AddDTVar("boolean", "EnableTierSkill", true)
  self:AddDTVar("boolean", "EnableNsl", false)
  self:AddDTVar("integer (0 to 2147483647)", "QueueIndexId", 0)
  self:AddDTVar(string.format("string (%d)", 254), "QueueIndex", "{}")
  self:AddDTVar("integer (0 to 65535)", "marine_skill", 0)
  self:AddDTVar("integer (0 to 65535)", "alien_skill", 0)
end

--This is called when any datatable variable changes.
--function Plugin:NetworkUpdate( Key, Old, New )
--	if Server then return end
	
	--Key is the variable name, Old and New are the old and new values of the variable.
	--Print( "%s has changed from %s to %s.", Key, tostring( Old ), tostring( New ) )
--end

---- Start Message Register ----

Plugin.kMsgDataName = "TierInfo_Data"
Plugin.kMsgDataInfo = {
  p = string.format("string (%d)", MAX_PLAYER_LENGTH)
}

Plugin.kMsgPermName = "TierInfo_Perm"
Plugin.kMsgPermInfo = {perm = string.format("string (%d)", 20)}

Plugin.kMsgLastRoundName = "Tierinfo_RoundInfo"
Plugin.kMsgLastRoundInfo = {round_id = "integer (0 to 2147483647)"}
--

Shared.RegisterNetworkMessage(Plugin.kMsgDataName, Plugin.kMsgDataInfo)
Shared.RegisterNetworkMessage(Plugin.kMsgPermName, Plugin.kMsgPermInfo)
Shared.RegisterNetworkMessage(Plugin.kMsgLastRoundName, Plugin.kMsgLastRoundInfo)
---- End Message Register ----