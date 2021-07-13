--[[
Shine SFX Plus Plugin - Client
]]

Script.Load(Shine.GetPluginFile("sfx_plus_defaultoff", "debug_log.lua"))

local Shine = Shine
local SGUI = Shine.GUI
local VoteMenu = Shine.VoteMenu
local Notify = Shared.Message
local StringFormat = string.format
local IsType = Shine.IsType

local SOUND_CAT_KILL       = "kill"
local SOUND_CAT_ASSIST     = "assist"
local SOUND_CAT_KILLSTREAK = "killstreak"
local SOUND_CAT_STREAKSTOP = "streakstop"
local SOUND_CAT_THUGKILL   = "thugkill"

local Plugin = Plugin

Plugin.HasConfig = true
Plugin.ConfigName = "sfx_plus_defaultoff_client.json"
Plugin.CheckConfig = true
Plugin.SilentConfigSave = true

Plugin.DefaultConfig = {
    [SOUND_CAT_KILL] = {
        Play         = false,
        Volume       = 100,
    },
    [SOUND_CAT_ASSIST] = {
        Play         = false,
        Volume       = 100,
    },
    [SOUND_CAT_KILLSTREAK] = {
        Play         = false,
        Volume       = 100,
    },
    [SOUND_CAT_STREAKSTOP] = {
        Play         = false,
        Volume       = 100,
    },
    [SOUND_CAT_THUGKILL] = {
        Play         = false,
        Volume       = 100,
    }
}

function Plugin:GetSampleTestSound(Cat)
    if Cat == SOUND_CAT_KILL then
        return self.Sounds["FeedbackKillRand"]
    elseif Cat == SOUND_CAT_ASSIST then
        return self.Sounds["FeedbackAssistRand"]
    elseif Cat == SOUND_CAT_KILLSTREAK then
        return self.Sounds["KillStreakRand"]
    elseif Cat == SOUND_CAT_STREAKSTOP then
        return self.Sounds["StreakStopRand"]
    elseif Cat == SOUND_CAT_THUGKILL then
        return self.Sounds["ThugKillRand"]
    end
end

function Plugin:Initialise()
    self.Enabled = true

    --Sounds
    self.Sounds = {
        [ "FeedbackKill" ]      = "sound/sfx_plus.fev/onkill/sound",
        [ "FeedbackKillRand" ]  = "sound/sfx_plus.fev/onkill/random",
        [ "FeedbackAssist" ]    = "sound/sfx_plus.fev/onassist/sound",
        [ "FeedbackAssistRand" ]= "sound/sfx_plus.fev/onassist/random",
        [ "Doublekill" ]        = "sound/sfx_plus.fev/onkillstreak/doublekill",
        [ "Triplekill" ]        = "sound/sfx_plus.fev/onkillstreak/triplekill",
        [ "Multikill" ]         = "sound/sfx_plus.fev/onkillstreak/multikill",
        [ "Rampage" ]           = "sound/sfx_plus.fev/onkillstreak/rampage",
        [ "Killingspree" ]      = "sound/sfx_plus.fev/onkillstreak/killingspree",
        [ "Dominating" ]        = "sound/sfx_plus.fev/onkillstreak/dominating",
        [ "Unstoppable" ]       = "sound/sfx_plus.fev/onkillstreak/unstoppable",
        [ "Megakill" ]          = "sound/sfx_plus.fev/onkillstreak/megakill",
        [ "Ultrakill" ]         = "sound/sfx_plus.fev/onkillstreak/ultrakill",
        [ "Ownage" ]            = "sound/sfx_plus.fev/onkillstreak/ownage",
        [ "Ludicrouskill" ]     = "sound/sfx_plus.fev/onkillstreak/ludicrouskill",
        [ "Headhunter" ]        = "sound/sfx_plus.fev/onkillstreak/headhunter",
        [ "Whickedsick" ]       = "sound/sfx_plus.fev/onkillstreak/whickedsick",
        [ "Monsterkill" ]       = "sound/sfx_plus.fev/onkillstreak/monsterkill",
        [ "Holyshit" ]          = "sound/sfx_plus.fev/onkillstreak/holyshit",
        [ "Godlike" ]           = "sound/sfx_plus.fev/onkillstreak/godlike",
        [ "KillStreakRand" ]    = "sound/sfx_plus.fev/onkillstreak/random",
        [ "StreakStop" ]        = "sound/sfx_plus.fev/onstreakstop/surprisemfk",
        [ "StreakStop2" ]        = "sound/sfx_plus.fev/onstreakstop/glassimpacts",
        [ "StreakStopRand" ]    = "sound/sfx_plus.fev/onstreakstop/random",
        [ "ThugKill1" ]         = "sound/sfx_plus.fev/onthugkill/humiliation",
        [ "ThugKill2" ]         = "sound/sfx_plus.fev/onthugkill/humiliating",
        [ "ThugKill3" ]         = "sound/sfx_plus.fev/onthugkill/humiliating_defeat",
        [ "ThugKillRand" ]      = "sound/sfx_plus.fev/onthugkill/random"
    }

    for _, Sound in pairs( self.Sounds ) do
        Client.PrecacheLocalSound( Sound )
    end

    if Shine.AddStartupMessage then
        Shine.AddStartupMessage( "Shine SFX Plus Plugin loaded, current client setting: " )
    end

    self.AvailableSoundCategory = {
        SOUND_CAT_KILL,
        SOUND_CAT_ASSIST,
        SOUND_CAT_KILLSTREAK,
        SOUND_CAT_STREAKSTOP,
        SOUND_CAT_THUGKILL
    }

    Dbg( "[Shine]SFX-Plus: Log: Checking config...." )

    for i = 1, #self.AvailableSoundCategory do
        Cat = self.AvailableSoundCategory[i]

        if not IsType(self.Config[Cat].Play, "boolean") then
            Dbg( "[Shine]SFX-Plus: Warning: The play setting of '%s' was not valid, reset to false.", Cat )
            self.Config[Cat].Play = false
            self:SaveConfig()
        end

        if self.Config[Cat].Volume < 0 then
            self.Config[Cat].Volume = 0
            self:SaveConfig()
            Dbg( "[Shine]SFX-Plus: Warning: The volume setting of '%s' was lower than 0, clamped to 0.", Cat )
        elseif self.Config[Cat].Volume > 200 then
            self.Config[Cat].Volume = 200
            self:SaveConfig()
            Dbg( "[Shine]SFX-Plus: Warning: The volume setting of '%s' was higher than 200, clamped to 200.", Cat )
        end

        if Shine.AddStartupMessage then
            Shine.AddStartupMessage( StringFormat( "\tCategory: %s, Enable: %s, Volume: %s%%",
                Cat,
                self.Config[Cat].Play,
                self.Config[Cat].Volume ) )
        end
    end

    if Shine.AddStartupMessage then
        Shine.AddStartupMessage( "\t * You can change those setting with sh_sfxplus_en [category] [true/false] and sh_sfxplus_volume [category] [0~200]" )
    end

    local lang_info = Client.GetOptionString("locale", "enUS")
    self:SendNetworkMessage( "ClientMsg", { Name = "PreferredLocale", Value = lang_info }, true )
    Dbg( "[Shine]SFX-Plus: Preferred locale: %s", lang_info )

    return true
end


function Plugin:GetSoundSfxCurrentSetting( Cat )
    if not self.Config then
        return false, 0
    else
        return self.Config[Cat].Play, self.Config[Cat].Volume
    end
end


function Plugin:ReceivePlaySound( Message )
    if not Message.Name then return end

    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(Message.Category)

    if Play then
        local SfxResName = self.Sounds[ Message.Name ]

        if SfxResName then
            StartSoundEffect( SfxResName, Volume / 100 )
        else
            Dbg( "[Shine]SFX-Plus: Fail to load res for sound name '%s'", Message.Name )
        end
    end
end

function Plugin:ReceiveCommand( Message )
    local Commands = {
        [ "SetEnable" ] = function ( Cat, Enable )
            local old_config = self.Config[Cat].Play

            self.Config[Cat].Play = Enable == 1 and true or false
            self:SaveConfig()

            Dbg("[Shine]SFX-Plus: '%s'.Enable %s -> %s", Cat, old_config, Enable)
        end,
        [ "SetVolume" ] = function ( Cat, Volume )
            local old_config = self.Config[Cat].Volume
            local SampleSfx = self:GetSampleTestSound( Cat )

            self.Config[Cat].Volume = Volume
            self:SaveConfig()

            StartSoundEffect( SampleSfx, self.Config[Cat].Volume / 100 )

            Dbg("[Shine]SFX-Plus: '%s'.Volume %s -> %s", Cat, old_config, Volume)
        end
    }

    if Commands[ Message.Name ] and Message.Value then
        Commands[ Message.Name ]( Message.Category, Message.Value )
    end
end

function Plugin:Cleanup()
    self.Sounds = nil
    self.AvailableSoundCategory = nil

    self.BaseClass.Cleanup( self )

    self.Enabled = false
end

-- ---------------   GUI PART   --------------- --

--[[
SFX Plus config GUI.
]]

local SGUI = Shine.GUI
local Locale = Shine.Locale

local KillSfxConfigMenu = {}
SGUI:AddMixin( KillSfxConfigMenu, "Visibility" )

KillSfxConfigMenu.Tabs = {}

local Units = SGUI.Layout.Units
local HighResScaled = Units.HighResScaled
local Percentage = Units.Percentage
local Spacing = Units.Spacing
local UnitVector = Units.UnitVector

KillSfxConfigMenu.Size = UnitVector( HighResScaled( 600 ), HighResScaled( 500 ) )
KillSfxConfigMenu.EasingTime = 0.25

-- String constants in GUI
local VOTEMENU_BTN_NAME                                 = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_VOTEMENU_BTN_NAME" )

local TAB_NAME_KA_INDICATOR                             = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_NAME_KA_INDICATOR" )
local TAB_NAME_KILLSTREAK                               = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_NAME_KILLSTREAK" )
local TAB_NAME_THUGKILL                                 = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_NAME_THUGKILL" )

local TAB_KA_INDICATOR_LABEL_MAIN                       = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_KA_INDICATOR_LABEL_MAIN" )
local TAB_KA_INDICATOR_LABEL_ENABLE_KILL_FEEDBACK       = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_KA_INDICATOR_LABEL_ENABLE_KILL_FEEDBACK" )
local TAB_KA_INDICATOR_LABEL_KILL_FEEDBACK_VOLUME       = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_KA_INDICATOR_LABEL_KILL_FEEDBACK_VOLUME" )
local TAB_KA_INDICATOR_LABEL_ENABLE_ASSIST_FEEDBACK     = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_KA_INDICATOR_LABEL_ENABLE_ASSIST_FEEDBACK" )
local TAB_KA_INDICATOR_LABEL_ASSIST_FEEDBACK_VOLUME     = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_KA_INDICATOR_LABEL_ASSIST_FEEDBACK_VOLUME" )

local TAB_KILLSTREAK_LABEL_MAIN                         = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_KILLSTREAK_LABEL_MAIN" )
local TAB_KILLSTREAK_LABEL_ENABLE_PLAY_KILLSTREAK_SOUND = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_KILLSTREAK_LABEL_ENABLE_PLAY_KILLSTREAK_SOUND" )
local TAB_KILLSTREAK_LABEL_KILLSTREAK_SOUND_VOLUME      = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_KILLSTREAK_LABEL_KILLSTREAK_SOUND_VOLUME" )
local TAB_KILLSTREAK_LABEL_ENABLE_PLAY_STREAKSTOP_SOUND = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_KILLSTREAK_LABEL_ENABLE_PLAY_STREAKSTOP_SOUND" )
local TAB_KILLSTREAK_LABEL_STREAKSTOP_SOUND_VOLUME      = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_KILLSTREAK_LABEL_STREAKSTOP_SOUND_VOLUME" )

local TAB_THUGKILL_LABEL_MAIN                           = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_THUGKILL_LABEL_MAIN" )
local TAB_THUGKILL_LABEL_ENABLE_PLAY_THUGKILL_SOUND     = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_THUGKILL_LABEL_ENABLE_PLAY_THUGKILL_SOUND" )
local TAB_THUGKILL_LABEL_THUGKILL_SOUND_VOLUME          = Locale:GetPhrase( "sfx_plus_defaultoff", "CLIENT_TAB_THUGKILL_LABEL_THUGKILL_SOUND_VOLUME" )

local function Run_sh_sfx_plus_en( Cat, Val )
    local console_cmd = StringFormat( "sh_sfxplus_en %s %s", Cat, Val )
    Shared.ConsoleCommand( console_cmd )
    return
end

local function Run_sh_sfx_plus_vol( Cat, Val )
    local console_cmd = StringFormat( "sh_sfxplus_vol %s %s", Cat, Val )
    Shared.ConsoleCommand( console_cmd )
    return
end

local TabConfigData = {
    {
        TabName = TAB_NAME_KA_INDICATOR,
        Title = TAB_KA_INDICATOR_LABEL_MAIN,
        Content = {
            {
                Description = TAB_KA_INDICATOR_LABEL_ENABLE_KILL_FEEDBACK,
                Type = "Boolean",
                GetCurrentVal = function ()
                    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(SOUND_CAT_KILL)
                    return Play
                end,
                ApplyNewVal = function ( new_val )
                    Run_sh_sfx_plus_en(SOUND_CAT_KILL, new_val)
                    return
                end
            },
            {
                Description = TAB_KA_INDICATOR_LABEL_KILL_FEEDBACK_VOLUME,
                Type = "Number",
                Min = 0,
                Max = 200,
                GetCurrentVal = function ()
                    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(SOUND_CAT_KILL)
                    return Volume
                end,
                ApplyNewVal = function ( new_val )
                    Run_sh_sfx_plus_vol(SOUND_CAT_KILL, new_val)
                    return
                end
            },
            {
                Description = TAB_KA_INDICATOR_LABEL_ENABLE_ASSIST_FEEDBACK,
                Type = "Boolean",
                GetCurrentVal = function ()
                    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(SOUND_CAT_ASSIST)
                    return Play
                end,
                ApplyNewVal = function ( new_val )
                    Run_sh_sfx_plus_en(SOUND_CAT_ASSIST, new_val)
                    return
                end
            },
            {
                Description = TAB_KA_INDICATOR_LABEL_ASSIST_FEEDBACK_VOLUME,
                Type = "Number",
                Min = 0,
                Max = 200,
                GetCurrentVal = function ()
                    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(SOUND_CAT_ASSIST)
                    return Volume
                end,
                ApplyNewVal = function ( new_val )
                    Run_sh_sfx_plus_vol(SOUND_CAT_ASSIST, new_val)
                    return
                end
            }
        }
    },
    {
        TabName = TAB_NAME_KILLSTREAK,
        Title   = TAB_KILLSTREAK_LABEL_MAIN,
        Content = {
            {
                Description = TAB_KILLSTREAK_LABEL_ENABLE_PLAY_KILLSTREAK_SOUND,
                Type = "Boolean",
                GetCurrentVal = function ()
                    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(SOUND_CAT_KILLSTREAK)
                    return Play
                end,
                ApplyNewVal = function ( new_val )
                    Run_sh_sfx_plus_en(SOUND_CAT_KILLSTREAK, new_val)
                    return
                end
            },
            {
                Description = TAB_KILLSTREAK_LABEL_KILLSTREAK_SOUND_VOLUME,
                Type = "Number",
                Min = 0,
                Max = 200,
                GetCurrentVal = function ()
                    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(SOUND_CAT_KILLSTREAK)
                    return Volume
                end,
                ApplyNewVal = function ( new_val )
                    Run_sh_sfx_plus_vol(SOUND_CAT_KILLSTREAK, new_val)
                    return
                end
            },
            {
                Description = TAB_KILLSTREAK_LABEL_ENABLE_PLAY_STREAKSTOP_SOUND,
                Type = "Boolean",
                GetCurrentVal = function ()
                    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(SOUND_CAT_STREAKSTOP)
                    return Play
                end,
                ApplyNewVal = function ( new_val )
                    Run_sh_sfx_plus_en(SOUND_CAT_STREAKSTOP, new_val)
                    return
                end
            },
            {
                Description = TAB_KILLSTREAK_LABEL_STREAKSTOP_SOUND_VOLUME,
                Type = "Number",
                Min = 0,
                Max = 200,
                GetCurrentVal = function ()
                    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(SOUND_CAT_STREAKSTOP)
                    return Volume
                end,
                ApplyNewVal = function ( new_val )
                    Run_sh_sfx_plus_vol(SOUND_CAT_STREAKSTOP, new_val)
                    return
                end
            }
        }
    },
    {
        TabName = TAB_NAME_THUGKILL,
        Title   = TAB_THUGKILL_LABEL_MAIN,
        Content = {
            {
                Description = TAB_THUGKILL_LABEL_ENABLE_PLAY_THUGKILL_SOUND,
                Type = "Boolean",
                GetCurrentVal = function ()
                    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(SOUND_CAT_THUGKILL)
                    return Play
                end,
                ApplyNewVal = function ( new_val )
                    Run_sh_sfx_plus_en(SOUND_CAT_THUGKILL, new_val)
                    return
                end
            },
            {
                Description = TAB_THUGKILL_LABEL_THUGKILL_SOUND_VOLUME,
                Type = "Number",
                Min = 0,
                Max = 200,
                GetCurrentVal = function ()
                    local Play, Volume = Plugin:GetSoundSfxCurrentSetting(SOUND_CAT_THUGKILL)
                    return Volume
                end,
                ApplyNewVal = function ( new_val )
                    Run_sh_sfx_plus_vol(SOUND_CAT_THUGKILL, new_val)
                    return
                end
            }
        }
    }
}

local function NeedsToScale()
    return SGUI.GetScreenSize() > 1920
end

local function GetSmallFont()
    if NeedsToScale() then
        return SGUI.FontManager.GetFont( "kAgencyFB", 27 )
    end

    return Fonts.kAgencyFB_Small
end

local function GetMediumFont()
    if NeedsToScale() then
        return SGUI.FontManager.GetFont( "kAgencyFB", 33 )
    end

    return Fonts.kAgencyFB_Medium
end

function KillSfxConfigMenu:Create()
    if self.Menu then return end

    self.Menu = SGUI:Create( "TabPanel" )
    self.Menu:SetAnchor( "CentreMiddle" )
    self.Menu:SetAutoSize( self.Size, true )

    self.Menu:SetTabWidth( HighResScaled( 128 ):GetValue() )
    self.Menu:SetTabHeight( HighResScaled( 96 ):GetValue() )
    self.Menu:SetFontScale( GetSmallFont() )

    self.Pos = self.Menu:GetSize() * - 0.5
    self.Menu:SetPos( self.Pos )

    self.Menu.OnPreTabChange = function( Window )
        if not Window.ActiveTab then return end

        local Tab = self.Tabs[ Window.ActiveTab ]
        if not Tab or not Tab.OnCleanup then return end

        Tab.OnCleanup( Window.ContentPanel )
    end

    self.Menu.TitleBarHeight = HighResScaled( 24 ):GetValue()
    self:PopulateTabs( self.Menu )

    self.Menu:AddCloseButton()
    if NeedsToScale() then
        local Font, Scale = SGUI.FontManager.GetFont( "kArial", 20 )
        self.Menu.CloseButton:SetFontScale( Font, Scale )
    end
    self.Menu.OnClose = function()
        self:ForceHide()
        return true
    end
end

Shine.Hook.Add( "OnResolutionChanged", "ClientConfig_OnResolutionChanged", function()
    if not KillSfxConfigMenu.Menu then return end

    KillSfxConfigMenu.Menu:Destroy()
    KillSfxConfigMenu.Menu = nil

    if KillSfxConfigMenu.Visible then
        KillSfxConfigMenu:Create()
    end
end )

function KillSfxConfigMenu.AnimateVisibility( Window, Show, Visible, EasingTime, TargetPos, IgnoreAnim )
    local IsAnimated = Shine.Config.AnimateUI and not IgnoreAnim

    if not Show and IsAnimated then
        Shine.Timer.Simple( EasingTime, function()
            if not SGUI.IsValid( Window ) then return end
            Window:SetIsVisible( false )
        end )
    else
        Window:SetIsVisible( Show )
    end

    if Show and not Visible then
        if IsAnimated then
            Window:SetPos( Vector2( - Client.GetScreenWidth() + TargetPos.x, TargetPos.y ) )
            Window:MoveTo( nil, nil, TargetPos, 0, EasingTime )
        else
            Window:SetPos( TargetPos )
        end

        SGUI:EnableMouse( true )
    elseif not Show and Visible then
        SGUI:EnableMouse( false )

        if IsAnimated then
            Window:MoveTo( nil, nil, Vector2( Client.GetScreenWidth() - TargetPos.x, TargetPos.y ), 0,
                EasingTime, nil, math.EaseIn )
        end
    end
end

function KillSfxConfigMenu:SetIsVisible( Bool, IgnoreAnim )
    if self.Visible == Bool then return end

    if not self.Menu then
        self:Create()
    end

    self.AnimateVisibility( self.Menu, Bool, self.Visible, self.EasingTime, self.Pos, IgnoreAnim )

    self.Visible = Bool

    if not self.Visible then
        Plugin:SendNetworkMessage( "ClientMsg", { Name = "ChatEchoRandColor", Value = "Good duck to you." }, true )
    end
end

function KillSfxConfigMenu:GetIsVisible()
    return self.Visible or false
end

KillSfxConfigMenu:BindVisibilityToEvents( "OnHelpScreenDisplay", "OnHelpScreenHide" )

function KillSfxConfigMenu:PopulateTabs( Menu )
    local Tabs = self.Tabs
    for i = 1, #Tabs do
        local Tab = Tabs[ i ]
        Menu:AddTab( Tab.Name, function( Panel )
            Tab.OnInit( Panel )
        end )
    end
end

function KillSfxConfigMenu:AddTab( Name, Tab )
    if self.Tabs[ Name ] then return end

    Tab.Name = Name
    self.Tabs[ Name ] = Tab
    self.Tabs[ #self.Tabs + 1 ] = Tab
end

local SettingsTypes = {
    [ "Boolean" ] = {
        Create = function( Panel, Layout, Entry )
            Dbg("Adding Boolean item, desc: %s", Entry.Description)

            local CheckBox = Panel:Add( "CheckBox" )
            CheckBox:SetFontScale( GetSmallFont() )
            CheckBox:AddLabel( Entry.Description )
            CheckBox:SetAutoSize( UnitVector( HighResScaled( 24 ), HighResScaled( 24 ) ) )

            local Enabled = Entry.GetCurrentVal()

            CheckBox:SetChecked( Enabled or false, true )

            CheckBox.OnChecked = function( CheckBox, Value )
                Entry.ApplyNewVal( Value )
            end

            CheckBox:SetMargin( Spacing( 0, 0, 0, HighResScaled( 8 ) ) )
            Layout:AddElement( CheckBox )

            return CheckBox
        end
    },
    [ "Number" ] = {
        Create = function( Panel, Layout, Entry )
            Dbg("Adding Boolean item, desc: %s", Entry.Description)

            local Desc = Panel:Add( "Label" )
            Desc:SetFontScale( GetSmallFont() )
            Desc:SetText( Entry.Description )
            Desc:SetMargin( Spacing( 0, 0, 0, HighResScaled( 8 ) ) )
            Layout:AddElement( Desc )

            local Slider = Panel:Add( "Slider" )

            Slider:SetupFromTable{
                HandleColour = Colour( 0.8, 0.6, 0.1, 1 ),
                LineColour = Colour( 1, 1, 1, 1 ),
                DarkLineColour = Colour( 0.4, 0.4, 0.4, 1 ),
                TextColour = Colour( 1, 1, 1, 1 ),
                Size = GUIScale( Vector( 230, 32, 0 ) ),
                IsSchemed = false,
                Padding = GUIScale( 20 )
            }
            Slider:SetTextScale( GUIScale( Vector( 1, 1 , 1 ) ) )

            Slider:SetBounds( Entry.Min, Entry.Max )
            Slider:SetFontScale( GetSmallFont() )

            local Val = Entry.GetCurrentVal()
            Slider:SetValue( Val )

            Slider.OnValueChanged = function( Slider, Value )
                Entry.ApplyNewVal( Value )
            end

            Slider:SetMargin( Spacing( 0, 0, 0, HighResScaled( 8 ) ) )
            Layout:AddElement( Slider )

            return Slider
        end
    }
}

local function InitializeTabUsingConfigData( TabConfig )
    KillSfxConfigMenu:AddTab( TabConfig.TabName, {
        OnInit = function( Panel )
            Panel:SetScrollable()
            Panel:SetScrollbarHeightOffset( HighResScaled( 40 ):GetValue() )
            Panel:SetScrollbarWidth( HighResScaled( 8 ):GetValue() )
            Panel:SetScrollbarPos( Vector2( - HighResScaled( 16 ):GetValue(), HighResScaled( 32 ):GetValue() ) )

            local Settings = TabConfig.Content

            local Layout = SGUI.Layout:CreateLayout( "Vertical", {
                Padding = Spacing( HighResScaled( 24 ), HighResScaled( 32 ),
                    HighResScaled( 24 ), HighResScaled( 32 ) )
            } )

            local Title = Panel:Add( "Label" )
            Title:SetFontScale( GetMediumFont() )
            Title:SetText( TabConfig.Title )
            Title:SetMargin( Spacing( 0, 0, 0, HighResScaled( 16 ) ) )
            Layout:AddElement( Title )

            for i = 1, #Settings do
                local Setting = Settings[ i ]
                local Creator = SettingsTypes[ Setting.Type ]

                if Creator then
                    local Object = Creator.Create( Panel, Layout, Setting )
                end
            end

            Panel:SetLayout( Layout )
        end
    } )
end


for i = 1, #TabConfigData do
    local TabConfig = TabConfigData[i]
    Dbg("Initializing tab: %s", TabConfig.TabName)
    InitializeTabUsingConfigData(TabConfig)
end

Shine:RegisterClientCommand( "sh_killsfxconfigmenu", function()
    KillSfxConfigMenu:Show()
end )

-- -----------   VOTE MENU ENTRY   ------------ --

VoteMenu:EditPage( "Main", function( self )
    if Plugin.Enabled then
        self:AddSideButton( VOTEMENU_BTN_NAME, function()
            self:ForceHide()
            Shared.ConsoleCommand( "sh_killsfxconfigmenu" )
        end )
    end
end )

Dbg( "[Shine]SFX-Plus: Log: INIT DONE...." )
