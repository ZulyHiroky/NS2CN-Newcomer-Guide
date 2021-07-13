--[[
    Shine welcome message plugin.
]]

local Shine = Shine

local GetOwner = Server.GetOwner
local StringFormat = string.format
local TableEmpty = table.Empty

local Plugin = {}
Plugin.Version = "1.3"

Plugin.HasConfig = true
Plugin.ConfigName = "WelcomeMessages_zhcn.json"

Plugin.DefaultConfig = {
    MessageDelay = 5,
    Users = {
        [ "90000001" ] = {
            Welcome = "Bob has joined the party!",
            Leave = "Bob is off to fight more important battles."
        }
    },
    ShowGeneric = false,
    ShowForBots = false
}

Plugin.CheckConfig = true
Plugin.CheckConfigTypes = true
Plugin.SilentConfigSave = true

function Plugin:Initialise()
    self.Welcomed = {}
    self.Enabled = true

    return true
end

function Plugin:ShouldShowMessage( Client )
    return Shine:IsValidClient( Client ) and ( self.Config.ShowForBots
        or not Client:GetIsVirtual() )
end

function Plugin:ClientConnect( Client )
    self:SimpleTimer( self.Config.MessageDelay, function()
        if not self:ShouldShowMessage( Client ) then return end

        local ID = Client:GetUserId()
        local MessageTable = self.Config.Users[ tostring( ID ) ]

        if MessageTable and MessageTable.Welcome then
            if not MessageTable.Said then
                Shine:NotifyColour( nil, 200, 200, 200, MessageTable.Welcome )

                MessageTable.Said = true

                self:SaveConfig()
            end

            self.Welcomed[ Client ] = true

            return
        end

        if not self.Config.ShowGeneric then return end

        self.Welcomed[ Client ] = true

        local Player = Client:GetControllingPlayer()
        if not Player then return end

        Shine:NotifyColour( nil, 200, 200, 200, ">> %s 加入了战局。", true, Player:GetName() )
    end )
end

local Ceil = math.ceil

local function ColourIntToTable( Int )
    local Colour = ColorIntToColor( Int )
    return { Ceil( Colour.r * 255 ), Ceil( Colour.g * 255 ), Ceil( Colour.b * 255 ) }
end

local TeamColours = {
    [ 0 ] = { 192, 192, 192 },
    [ 1 ] = { 0, 110, 200 },
    [ 2 ] = { 200, 150, 0 }
}

function Plugin:ClientDisconnect( Client )
    if not self.Welcomed[ Client ] then return end

    self.Welcomed[ Client ] = nil

    local ID = Client:GetUserId()
    local MessageTable = self.Config.Users[ tostring( ID ) ]

    if MessageTable and MessageTable.Leave then
        Shine:NotifyColour( nil, 200, 200, 200, MessageTable.Leave )

        MessageTable.Said = nil

        self:SaveConfig()

        return
    end

    if not self.Config.ShowGeneric then return end

    local Player = Client:GetControllingPlayer()
    if not Player then return end

    local Team = Client.DisconnectTeam or 0
    local Colour = TeamColours[ Team ] or TeamColours[ 0 ]

    if not Client.DisconnectReason then
        Shine:NotifyColour( nil, Colour[ 1 ], Colour[ 2 ], Colour[ 3 ],
            StringFormat( "<< %s 离开了战局。", Player:GetName() ) )
    else
        Shine:NotifyColour( nil, Colour[ 1 ], Colour[ 2 ], Colour[ 3 ],
            StringFormat( "<- %s 被服务器自动踢出，理由 (%s)。", Player:GetName(), Client.DisconnectReason ) )
    end
end

function Plugin:OnScriptDisconnect( Client )
    local Player = Client:GetControllingPlayer()

    if not Player then return end

    local Team = Player.GetTeamNumber and Player:GetTeamNumber()
    if not Team then return end

    Client.DisconnectTeam = Team
end

function Plugin:PostJoinTeam( Gamerules, Player, OldTeam, NewTeam, Force, ShineForce )
    if NewTeam < 0 then return end
    if not Player then return end

    local Client = GetOwner( Player )

    if Client then
        Client.DisconnectTeam = NewTeam
    end
end

function Plugin:Cleanup()
    self.Welcomed = nil
    self.BaseClass.Cleanup( self )

    self.Enabled = false
end

Shine.Hook.SetupGlobalHook( "Server.DisconnectClient", "OnScriptDisconnect", "PassivePre" )

Shine:RegisterExtension( "welcomemessages_zhcn", Plugin )
