--[[
Shine Kill SFX Plugin - Shared
]]

Script.Load(Shine.GetPluginFile("sfx_plus_defaultoff", "debug_log.lua"))

local Plugin = {}
Plugin.Version = "1.1"

function Plugin:SetupDataTable()
    local Command ={
        Name = "string(255)",
        Category = "string(15)",
        Value = "integer (0 to 200)"
    }
    self:AddNetworkMessage( "Command", Command, "Client" )

    local Sound = {
        Name = "string(255)",
        Category = "string(15)"
    }
    self:AddNetworkMessage( "PlaySound", Sound, "Client" )

    local CMsg = {
        Name = "string (255)",
        Value = "string (255)"
    }
    self:AddNetworkMessage( "ClientMsg", CMsg, "Server" )

    local MessageTypes = {
        None = {},
        CatOnly = {
            Category = "string(15)",
        },
        CatAndValue = {
            Category = "string(15)",
            Value    = "integer (0 to 200)"
        }
    }

    self:AddNetworkMessages( "AddTranslatedNotifyColour", {
        [ MessageTypes.None ] = {
            "SERVER_SET_ERROR_INVALID_PARAMETER"
        },
        [ MessageTypes.CatOnly ] = {
            "SERVER_SET_ENABLE_SUCCESS_PLAY", "SERVER_SET_ENABLE_SUCCESS_MUTE", "SERVER_SET_ERROR_NO_CATEGORY", "SERVER_SET_ERROR_CATEGORY_DISABLED"
        },
        [ MessageTypes.CatAndValue ] = {
            "SERVER_SET_VOLUME_SUCCESS"
        }
    } )
end

Shine:RegisterExtension( "sfx_plus_defaultoff", Plugin )
