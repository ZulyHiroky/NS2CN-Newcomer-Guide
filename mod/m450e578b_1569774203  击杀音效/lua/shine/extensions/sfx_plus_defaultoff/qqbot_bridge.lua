--[[
  Bot post bridge
]]


local QQBotBridge = {}
local Plugin = Plugin

local IsType = Shine.IsType


-- CAT_KILL       = "kill"
-- CAT_ASSIST     = "assist"
-- CAT_KILLSTREAK = "killstreak"
-- CAT_STREAKSTOP = "streakstop"
-- CAT_THUGKILL   = "thugkill"


function QQBotBridge:OnPostFail(reason)
    Log(reason)
end

function QQBotBridge:OnPostSucc()
    Log('Post Msg Succ')
    return
end

local function CheckIsRealPlayer(Player)
    local Client = Player:GetClient()
    if Client and not Client:GetIsVirtual() then
        return true
    end
    return false
end

function QQBotBridge:CheckQQBotPost(Attacker, Victim, Cat ,Desc)
    Dbg("Checking post")
    if not self.Config.BotPostEnable then return end

    if not Desc.Broadcast then return end

    if not CheckIsRealPlayer(Attacker) or not CheckIsRealPlayer(Victim) then
        return
    end

    Dbg("Checking pass")

    local Msg = nil

    if Cat == CAT_KILLSTREAK then
        Msg = self.GenerateProperMsg( 'zhCN', Desc.Text, Attacker:GetName() )
    elseif Cat == CAT_THUGKILL then
        Msg = self.GenerateProperMsg( 'zhCN', Desc.Text, Attacker:GetName(), Victim:GetName() )
    elseif Cat == CAT_STREAKSTOP then
        Msg = self.GenerateProperMsg( 'zhCN', Desc.Text, Victim:GetName(), Attacker and Attacker:GetName() or "None" )
    else
        return
    end

    Dbg("Preparing Post")

    self:PostMsg(self.Config.BotPostPrefix .. Msg)

    Dbg("Post done")
end

function QQBotBridge:PostMsg(Msg)
    local Encode, Decode = json.encode, json.decode

    local Concat = {}
    local Count = 0

    local post_data = {
        token = self.Config.BotPostToken,
        msg = Msg
    }

    Shine.TimedHTTPRequest(self.Config.BotPostURL, 'POST', post_data, function(Response, Status)
        if not Response then
            self:OnPostFail('[QQBotBridge] Received empty response from the BotServer.')
            return
        end

        local Data = Decode(Response)

        if ( not IsType(Data, 'table') ) then
            self:OnPostFail('[QQBotBridge] BotServer returned corrupt data.')
            return
        end

        if Data['status'] ~= 'OK' then
            self:OnPostFail('[QQBotBridge] Request rejected by BotServer, status: '..tostring(Data['status']))
            return
        end

        self:OnPostSucc()
    end, function()
        self:OnPostFail('[QQBotBridge] BotServer connection timed out.')
    end )
end

Plugin:AddModule(QQBotBridge)
