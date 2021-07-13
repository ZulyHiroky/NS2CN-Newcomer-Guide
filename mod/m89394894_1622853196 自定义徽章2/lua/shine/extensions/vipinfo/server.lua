--[[
    Shine dmdvip plugin
]]

local Shine = Shine
local Plugin = Plugin

Plugin.Version = "2.0"
Plugin.HasConfig = true --Does this plugin have a config file?
Plugin.ConfigName = "dmdvip.json" --What's the name of the file?
Plugin.DefaultState = true --Should the plugin be enabled when it is first added to the config?
Plugin.NS2Only = true --Set to true to disable the plugin in NS2: Combat if you want to use the same code for both games in a mod.
Plugin.DefaultConfig = {
    ShowMenuEntry = true,
    MenuEntryUrl = "",
    MenuEntryName = "dmdvip"
}
Plugin.CheckConfig = true --Should we check for missing/unused entries when loading?
Plugin.CheckConfigTypes = true --Should we check the types of values in the config to make sure they match our default's types?
local verbose = false


function Plugin:Initialise()



    self:CreateCommands()

    self.dt.ShowMenuEntry = self.Config.ShowMenuEntry
    self.dt.MenuEntryName = self.Config.MenuEntryName

    self.Enabled = true

    return true
end





function Plugin.ShowDmdVipInfo( Client )
	if not Shine:IsValidClient( Client ) then return end
    Plugin:SendNetworkMessage( Client, "OpenWebpageInSteam", { URL = Plugin.Config.MenuEntryUrl }, true )
end


function Plugin:CreateCommands()
     self:BindCommand( "sh_vip", "vip", Plugin.ShowDmdVipInfo, true )
         :Help( "Shows vip info" )
end


function Plugin:Cleanup()
    self.LastGameState = nil
    self.GameStartTime = nil

    self.BaseClass.Cleanup( self )

    self.Enabled = false
end
