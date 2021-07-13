--It is the job of shared.lua to create the plugin table.
local Plugin = Plugin
local StringFormat = string.format

function Plugin:Initialise()
    self:CreateCommands()
    self.Enabled = true
    return true
end

function Plugin:CreateCommands()
    redir_handler = function ( CallClient, Ip, Port, Numplayer )
        local target_srv = StringFormat( "%s:%d", Ip, Port )

        Shine.QueryServer( Ip, Port + 1, function( Data )
            if not Data then
                Shine:NotifyColour( CallClient, 255, 5, 5,
                    StringFormat( "Redirection rejected: Cannot validate the target server %s.", target_srv )
                )
                return
            else
                local Connected = Data.numberOfPlayers
                local Max = Data.maxPlayers
                local SName = Data.serverName
                local SMap = Data.mapName
                local Tags = Data.serverTags

                Shine:NotifyColour( CallClient, 5, 255, 5,
                    StringFormat(
                        "Redirection accepted: Redirecting to target %s ('%s'@%s|%i/%i)...",
                        target_srv, SName, SMap, Connected, Max )
                )
                local redir_cnt = 0

                if Numplayer == 0 then
                    redir_cnt = -1
                end

                for Client in Shine.GameIDs:Iterate() do
                    local Player = Client:GetControllingPlayer()
                    if Player then
                        Shine.SendNetworkMessage( Client, "Shine_Command", {
                            Command = StringFormat( "connect %s", target_srv )
                        }, true )

                        if redir_cnt >= 0 then
                            redir_cnt = redir_cnt + 1
                            if redir_cnt >= Numplayer then break end
                        end
                    end
                end
            end
        end )
    end

    local CmdVolume = self:BindCommand( "sh_redir", "redir", redir_handler, false, true )
    CmdVolume:AddParam{
        Type = "string",
        MaxLength = 128,
        Help = "Target Host"
    }
    CmdVolume:AddParam{
        Type = "number",
        Min = 0, Max = 65535,
        Error = "Please specify a number in range 0 ~ 65535.",
        Help = "Target Port"
    }
    CmdVolume:AddParam{
        Type = "number",
        Min = 0, Max = 200,
        Optional = true, Default = 0,
        Error = "Please specify a number in range 0 ~ 200.",
        Help = "Number of player (Optional, 0 for all player, default is 0)"
    }
    CmdVolume:Help( "Hot redirect clients to another server." )
end

--We call the base class cleanup to remove the console commands.
function Plugin:Cleanup()
    self.BaseClass.Cleanup( self )
    self.Enabled = false
end
