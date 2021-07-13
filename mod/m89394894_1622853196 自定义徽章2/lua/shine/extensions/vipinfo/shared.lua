--[[
    Shine vipinfo plugin
    ]]

local Plugin = {}


function Plugin:SetupDataTable()
	self:AddDTVar( "boolean", "ShowMenuEntry", true )
    self:AddDTVar( "string (64)", "MenuEntryName", "vipinfo" )
	self:AddNetworkMessage( "OpenWebpageInSteam", { URL = "string (255)" }, "Client" )
end


function Plugin:NetworkUpdate( Key, OldValue, NewValue )
	if Client and Key == "ShowMenuEntry" and OldValue ~= NewValue then
		self:UpdateMenuEntry(NewValue)
	end
end


Shine:RegisterExtension( "vipinfo", Plugin )
