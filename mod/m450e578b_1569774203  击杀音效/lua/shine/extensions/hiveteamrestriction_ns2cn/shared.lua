--[[
    Shine Hive Team Restriction - Shared
]]
local Plugin = Shine.Plugin( ... )
Plugin.NS2Only = true

function Plugin:SetupDataTable()
    self:AddNetworkMessage( "ShowSwitch", {}, "Client" )
end

return Plugin