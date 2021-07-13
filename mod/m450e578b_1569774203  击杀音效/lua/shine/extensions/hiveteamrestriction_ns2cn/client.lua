--[[
    Shine Hive Team Restriction - Client
]]

local Plugin = ...

function Plugin:ReceiveShowSwitch()
    local Votemenu = Shine.VoteMenu
    local Enabled, Switch = Shine:IsExtensionEnabled( "serverswitch" )
    if Votemenu and Enabled and next( Switch.ServerList ) then
        Shared.ConsoleCommand( "sh_votemenu" )
        Votemenu:SetPage( "ServerSwitch" )
    end
end