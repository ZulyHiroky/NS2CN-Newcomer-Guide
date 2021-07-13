--[[
Shine SFX Plus Plugin - Server
]]

Script.Load(Shine.GetPluginFile("sfx_plus_defaultoff", "debug_log.lua"))

local Shine = Shine
local StringFormat = string.format
local IsType = Shine.IsType
local Clients = Shine.GameIDs
local Locale = Shine.Locale
local Plugin = Plugin

CAT_KILL       = "kill"
CAT_ASSIST     = "assist"
CAT_KILLSTREAK = "killstreak"
CAT_STREAKSTOP = "streakstop"
CAT_THUGKILL   = "thugkill"

Plugin.HasConfig = true
Plugin.ConfigName = "sfx_plus_defaultoff.json"
Plugin.CheckConfig = true
Plugin.DefaultConfig = {
    BotPostToken = 'K12e92aD67c922F7',
    BotPostURL = 'http://localhost:27030/server_event_post',
    BotPostPrefix = '[Broadcast] ',
    BotPostEnable = false,
    AlienColour = { 255, 125, 0 },
    MarineColour = { 0, 125, 255 },

    Enabled = {
        [CAT_KILL] = true,
        [CAT_ASSIST] = true,
        [CAT_KILLSTREAK] = true,
        [CAT_STREAKSTOP] = true,
        [CAT_THUGKILL] = true
    },

    LocaleSupported = {"zhCN", "enUS"},
    LocaleFallback = "enUS",
    LocaleFallbackChatNofity = "[SFX Plus] This server only support Chinese (Simplified) or English killing boradcast, your preferred locale has fellback to English.",

    KillStreak = {
        Desc = {
        }
    },
    StreakStop = {
        Desc = {
        }
    },
    ThugKill = {
        Desc = {
        }
    },
    KillFeedback = {
        Desc = {
            Text = nil,
            Broadcast = false,
            Sound = "FeedbackKill"  -- Random sound
        }
    },
    AssistFeedback = {
        Desc = {
            Text = nil,
            Broadcast = false,
            Sound = "FeedbackAssist"  -- Random sound
        }
    }
}

function Plugin:Initialise()
    self.Enabled = true

    self.ClientPreferredLocale = {}
    self.Killstreaks = {}

    table.sort(self.Config.StreakStop.Desc,
        function (a, b) return a.TriggerLevel < b.TriggerLevel end)

    Plugin:CreateCommands()

    Dbg("[Shine] SFX-Plus: Server loaded.")

    return true
end

function Plugin:CreateCommands()
    local sh_sfxplus_en_handler = function ( Client, Cat, IsPlay )
        if not IsType(IsPlay, "boolean") then
            Plugin:SendTranslatedNotifyColour( Client, "SERVER_SET_ERROR_INVALID_PARAMETER", { R = 255, G = 0, B = 0 } )
            return
        end

        local lower_cat = string.lower( Cat )

        if self.Config.Enabled[lower_cat] then
            self:SendNetworkMessage( Client, "Command", { Name = "SetEnable", Category = lower_cat, Value = IsPlay and 1 or 0 } , true)

            Plugin:SendTranslatedNotifyColour( Client,
                IsPlay and "SERVER_SET_ENABLE_SUCCESS_PLAY" or "SERVER_SET_ENABLE_SUCCESS_MUTE"
                , { R = 0, G = 255, B = 0, Category = Cat } )
            return
        elseif self.Config.Enabled[lower_cat] == nil then
            Plugin:SendTranslatedNotifyColour( Client, "SERVER_SET_ERROR_NO_CATEGORY", { R = 255, G = 0, B = 0, Category = Cat } )
        else
            Plugin:SendTranslatedNotifyColour( Client, "SERVER_SET_ERROR_CATEGORY_DISABLED", { R = 255, G = 0, B = 0, Category = Cat } )
        end
    end

    local sh_sfxplus_vol_handler = function ( Client, Cat, Volume )
        if not ( IsType(Volume, "number") and (0 <= Volume) and (Volume <= 200) ) then
            Plugin:SendTranslatedNotifyColour( Client, "SERVER_SET_ERROR_INVALID_PARAMETER", { R = 255, G = 0, B = 0 } )
            return
        end

        local lower_cat = string.lower( Cat )

        if self.Config.Enabled[lower_cat] then
            self:SendNetworkMessage( Client, "Command", { Name = "SetVolume", Category = lower_cat, Value = Volume } , true)
            Plugin:SendTranslatedNotifyColour( Client,
                "SERVER_SET_VOLUME_SUCCESS"
                , { R = 0, G = 255, B = 0, Category = Cat, Value = Volume } )
            return
        elseif self.Config.Enabled[lower_cat] == nil then
            Plugin:SendTranslatedNotifyColour( Client, "SERVER_SET_ERROR_NO_CATEGORY", { R = 255, G = 0, B = 0, Category = Cat } )
        else
            Plugin:SendTranslatedNotifyColour( Client, "SERVER_SET_ERROR_CATEGORY_DISABLED", { R = 255, G = 0, B = 0, Category = Cat } )
        end
    end

    local CmdPlay = self:BindCommand( "sh_sfxplus_en", "sfxplus_en", sh_sfxplus_en_handler, true, true )
    CmdPlay:AddParam{ Type = "string", MaxLength = 100, Help = "Category name" }
    CmdPlay:AddParam{ Type = "boolean", Help = "Enable" }
    CmdPlay:Help( "Set whether play certain category sound effect." )

    local CmdVolume = self:BindCommand( "sh_sfxplus_vol", "sfxplus_vol", sh_sfxplus_vol_handler, true, true )
    CmdVolume:AddParam{ Type = "string", MaxLength = 100, Help = "Category name" }
    CmdVolume:AddParam{ Type = "number", Min = 0, Max = 200, Error = "Please specify a number in range 0 ~ 200.", Help = "New volume" }
    CmdVolume:Help( "Set whether play certain category sound effect." )
end

function Plugin:Cleanup()

    self.BaseClass.Cleanup( self )

    self.ClientPreferredLocale = nil
    self.Killstreaks = nil

    self.Enabled = false
end

function Plugin:ReceiveClientMsg( Client, Message )
    local Name = Message.Name
    local Value = Message.Value

    MsgHandler = {
        ["PreferredLocale"] = function ( Client, Value )
            Dbg("Client %s requests updating preferred locale: %s", Client, Value)
            for i = 1, #self.Config.LocaleSupported do
                if Value == self.Config.LocaleSupported[i] then
                    self.ClientPreferredLocale[ Client ] = Value
                    Dbg("Updated client preferred locale: %s, %s", Client, Value)
                    return
                end
            end

            self.ClientPreferredLocale[ Client ] = self.Config.LocaleFallback
            Shine:NotifyColour( Client, 255, 0, 0, StringFormat( self.Config.LocaleFallbackChatNofity ) )
            Dbg("Updated client preferred locale: %s, %s (fallback)", Client, self.Config.LocaleFallback )
        end,
        ["ChatEcho"] = function ( Client, Value )
            Shine:NotifyColour( Client, 255, 255, 255, Value )
        end,
        ["ChatEchoRandColor"] = function ( Client, Value )
            Shine:NotifyColour( Client, math.random(0, 255), math.random(0, 255), math.random(0, 255), Value )
        end
    }

    if MsgHandler[ Message.Name ] and Message.Value then
        MsgHandler[ Message.Name ]( Client, Message.Value )
    end
end

function Plugin:ClientDisconnect( Client )
    self.Killstreaks[ Client ] = nil
    self.ClientPreferredLocale[ Client ] = nil
    Dbg("Released client preferred locale: %s.", Client)
end

Shine.Hook.SetupGlobalHook( "RemoveAllObstacles", "OnGameReset", "PassivePost" )

function Plugin:OnGameReset()
    self.Killstreaks = {}
end

function Plugin:PostJoinTeam( _, Player )
    local Client = Player:GetClient()
    if not Client then return end

    self.Killstreaks[ Client ] = nil
end

function Plugin.GetRealDamageDealer( DamageDealer )
    local RealKiller = DamageDealer

    if DamageDealear and not DamageDealer:isa( "Player" ) then
        RealKiller = DamageDealer.GetOwner and DamageDealer:GetOwner() or nil
        if RealKiller and not RealKiller:isa( "Player" ) then
            --noinspection UnusedDef
            RealKiller = nil
        end
    end

    return RealKiller
end

function Plugin.GenerateProperMsg( PreferredLocale, TextData, ... )
    local arg = {...}
    local PatternMsg = PreferredLocale and ( TextData and TextData[PreferredLocale] or nil ) or nil
    local FinalMsg = nil
    if PatternMsg then
        if #arg ~= 0 then
            FinalMsg = StringFormat( PatternMsg, unpack(arg) )
        else
            FinalMsg = PatternMsg
        end
    end
    return FinalMsg
end

function Plugin:DispatchDesc( TriggerClient, Desc, Cat, Colour, ... )
    local arg = {...}

    if not Desc then return end

    if not self.Config.Enabled[Cat] then
        Dbg("DispatchDesc: Cat '%s' disabled, return", Cat)
        return
    end

    if Desc.Broadcast then
        local CachedLocalMsg = {}
        local Msg = nil

        if Desc.Text then
            for i = 1, #self.Config.LocaleSupported do
                local currLocale = self.Config.LocaleSupported[i]
                CachedLocalMsg[currLocale] = self.GenerateProperMsg( currLocale, Desc.Text, unpack(arg) )
            end

            for Client in Clients:Iterate() do
                Msg = CachedLocalMsg[ self.ClientPreferredLocale[Client] ]

                if not Msg then
                    Msg = CachedLocalMsg[ self.Config.LocaleFallback ]
                end

                Shine:NotifyColour( Client, Colour[ 1 ], Colour[ 2 ], Colour[ 3 ], Msg )
            end
        end

        if Desc.Sound then
            self:SendNetworkMessage( nil, "PlaySound", { Name = Desc.Sound, Category = Cat } , true)
        end

        Msg = CachedLocalMsg[ self.Config.LocaleFallback ]
        Dbg("DispatchDesc: Broadcasted Desc, Cat/%s, Msg/%s, Sound/%s",
            Cat,
            Msg and Msg or "None",
            Desc.Sound and Desc.Sound or "None")
    else
        if not TriggerClient then return end

        local Msg = nil
        if Desc.Text then
            Msg = self.GenerateProperMsg( self.ClientPreferredLocale[TriggerClient], Desc.Text, unpack(arg) )
            if not Msg then
                Msg = self.GenerateProperMsg( self.Config.LocaleFallback, Desc.Text, unpack(arg) )
            end

            Shine:NotifyColour( TriggerClient, Colour[ 1 ], Colour[ 2 ], Colour[ 3 ], Msg )
        end

        if Desc.Sound then
            self:SendNetworkMessage( TriggerClient, "PlaySound", { Name = Desc.Sound, Category = Cat } , true)
        end

        Msg = self.GenerateProperMsg( self.Config.LocaleFallback, Desc.Text, unpack(arg) )
        Dbg("DispatchDesc: Unicasted Desc, To/%s, Cat/%s, Msg/%s, Sound/%s",
            TriggerClient,
            Cat,
            Msg and Msg or "None",
            Desc.Sound and Desc.Sound or "None")
    end
end

function Plugin:GetTeamColour( Gamer )
    local Colour = { 255, 0, 0 }
    local team = Gamer:GetTeamNumber()

    if team == 1 then --noinspection UnusedDef
        Colour = self.Config.MarineColour
    elseif team == 2 then
        Colour = self.Config.AlienColour
    end

    return Colour
end

function Plugin:ProcessKillAndAssistFeedback( Attacker, Victim )
    local Attacker = self.GetRealDamageDealer( Attacker )

    if not Attacker or not Victim then return end

    if Victim:isa( "Player" ) then
        Dbg( "KA Feedback: Sending kill feedback to %s", Attacker:GetName() )
        self:DispatchDesc(
            Attacker:GetClient(),
            self.Config.KillFeedback.Desc,
            CAT_KILL,
            self:GetTeamColour(Attacker)
        )

        local VictimAttackers = Victim.damagePoints.attackers

        for i = 1, #VictimAttackers do
            local attackerId = VictimAttackers[i]

            local currentAttacker = self.GetRealDamageDealer( Shared.GetEntity( attackerId ) )

            if currentAttacker then
                if currentAttacker ~= Attacker then
                    Dbg( "KA Feedback: Sending assist feedback to %s", currentAttacker:GetName() )
                    self:DispatchDesc(
                        currentAttacker:GetClient(),
                        self.Config.AssistFeedback.Desc,
                        CAT_ASSIST,
                        self:GetTeamColour(Attacker)
                    )
                end
            end
        end
    end
end

function Plugin:GetStreakDesc( Streak )
    local Desc = self.Config.KillStreak.Desc[ tostring(Streak) ]

    if not Desc then return end

    if IsType(Desc, "number") then
        return self:GetStreakDesc( Desc )
    end

    return Desc
end

function Plugin:GetThugKillDesc( WeaponID )
    local Desc = self.Config.ThugKill.Desc[ tostring( WeaponID ) ]

    if not Desc then return end

    if IsType(Desc, "number") then
        return self:GetThugKillDesc( Desc )
    end

    return Desc
end

function Plugin:ProcessKillStreakAndStreakStop( Attacker, Victim )
    Dbg("Streak and Stop: Entering ...")
    if not Victim or not Victim:isa( "Player" ) then
        return
    end
    Dbg("Streak and Stop: Valid Victim")

    local VictimClient = Victim:GetClient()
    if not VictimClient then return end
    Dbg("Streak and Stop: Valid Victim.Client")

    if self.Killstreaks[ VictimClient ] then -- Check streak stop
        Dbg("Streak and Stop: Checking StreakStop...")
        local StreakNum = self.Killstreaks[ VictimClient ]
        local StreakStopDesc = nil

        for i = 1, #self.Config.StreakStop.Desc do
            -- The array Config.StreakStop.Desc is sorted during initializing based on the value of TriggerLevel
            if StreakNum < self.Config.StreakStop.Desc[i].TriggerLevel then
                break
            end
            StreakStopDesc = self.Config.StreakStop.Desc[i]
        end

        local RealKiller = self.GetRealDamageDealer( Attacker )
        if not RealKiller then
            RealKiller = Attacker
        end

        if StreakStopDesc then
            Dbg("Streak and Stop: Triggered StreakStop, TriggerLevel/%s", StreakStopDesc.TriggerLevel)
            self:DispatchDesc(
                RealKiller and RealKiller:GetClient() or nil,
                StreakStopDesc,
                CAT_STREAKSTOP,
                self:GetTeamColour(Victim),
                Victim:GetName(),
                RealKiller and RealKiller:GetName() or "None"
            )
            self:CheckQQBotPost( RealKiller, Victim, CAT_STREAKSTOP, StreakStopDesc )
        end
        self.Killstreaks[ VictimClient ] = nil
    end

    Attacker = self.GetRealDamageDealer( Attacker )
    if not Attacker then return end
    Dbg("Streak and Stop: Valid Attacker")

    local AttackerClient = Attacker:GetClient()
    if not AttackerClient then return end
    Dbg("Streak and Stop: Valid Attacker.Client")

    if not self.Killstreaks[ AttackerClient ] then self.Killstreaks[ AttackerClient ] = 1
    else self.Killstreaks[ AttackerClient ] = self.Killstreaks[ AttackerClient ] + 1 end

    Dbg("Streak and Stop: Checking KillStreak...")
    local StreakDesc = self:GetStreakDesc( self.Killstreaks[AttackerClient] )

    if StreakDesc then
        Dbg("Streak and Stop: Triggered KillStreak, Streak/%s", self.Killstreaks[AttackerClient])
        self:DispatchDesc(
            AttackerClient,
            StreakDesc,
            CAT_KILLSTREAK,
            self:GetTeamColour(Attacker),
            Attacker:GetName()
        )
        self:CheckQQBotPost( Attacker, Victim, CAT_KILLSTREAK, StreakDesc )
    end
end

function Plugin:ProcessThugKill( Attacker, Victim, WeaponID )
    Dbg("Streak and Stop: Entering ...")
    Attacker = self.GetRealDamageDealer( Attacker )
    if not Attacker or not Victim or not Victim:isa( "Player" ) then return end
    Dbg("Streak and Stop: Valid Attacker and Victim")

    Dbg("Streak and Stop: Checking ThugKill...")
    local ThugDesc = self:GetThugKillDesc( WeaponID )

    if ThugDesc then
        Dbg("Streak and Stop: ThugKill triggered, WeaponID/%s", WeaponID)
        self:DispatchDesc(
            Attacker:GetClient(),
            ThugDesc,
            CAT_THUGKILL,
            self:GetTeamColour(Attacker),
            Attacker:GetName(),
            Victim:GetName()
        )
        self:CheckQQBotPost( Attacker, Victim, CAT_THUGKILL, ThugDesc )
    end
end

function Plugin:OnEntityKilled( Gamerules, Victim, Attacker, Inflictor, Point, Direction )
    self:ProcessKillAndAssistFeedback( Attacker, Victim )

    self:ProcessKillStreakAndStreakStop(Attacker, Victim)

    if Inflictor then
        self:ProcessThugKill(Attacker, Victim, Inflictor:GetDeathIconIndex())
    end
end

Script.Load(Shine.GetPluginFile("sfx_plus_defaultoff", "qqbot_bridge.lua"))
