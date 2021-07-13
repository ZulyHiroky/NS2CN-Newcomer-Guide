-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Voting.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================
local kVoteExpireTime = 20
local kDefaultVoteExecuteTime = 30
local kNextVoteAllowedAfterTime = 40
-- How many seconds must pass before a client can start another vote of a certain type after a failed vote.
local kStartVoteAfterFailureLimit = 3 * 60

Shared.RegisterNetworkMessage("SendVote", { voteId = "integer", choice = "boolean" })
kVoteState = enum( { 'InProgress', 'Passed', 'Failed' } )
Shared.RegisterNetworkMessage("VoteResults", { voteId = "integer", yesVotes = "integer (0 to 255)", noVotes = "integer (0 to 255)", requiredVotes = "integer (0 to 255)", state = "enum kVoteState" })
Shared.RegisterNetworkMessage("VoteComplete", { voteId = "integer" })
kVoteCannotStartReason = enum( { 'VoteAllowedToStart', 'VoteInProgress', 'Waiting', 'Spam', 'DisabledByAdmin', 'GameInProgress', 'TooEarly', 'TooLate', 'UnsupportedGamemode' } )
Shared.RegisterNetworkMessage("VoteCannotStart", { reason = "enum kVoteCannotStartReason" })

local kVoteCannotStartReasonStrings = { }
kVoteCannotStartReasonStrings[kVoteCannotStartReason.VoteInProgress] = "VOTE_IN_PROGRESS"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.Waiting] = "VOTE_WAITING"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.Spam] = "VOTE_SPAM"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.GameInProgress] = "VOTE_GAME_IN_PROGRESS"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.DisabledByAdmin] = "VOTE_DISABLED_BY_ADMIN"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.TooEarly] = "VOTE_TOO_EARLY"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.TooLate] = "VOTE_TOO_LATE"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.UnsupportedGamemode] = "VOTE_GAMEMODE_NOT_SUPPORTED"

-- to prevent message from being re-hooked when interface is re-created.
local hookedVoteTypes = {}

if Server then

    -- Allow reset between Countdown and kMaxTimeBeforeReset
    function VotingResetGameAllowed()
        local gameRules = GetGamerules()
        return gameRules:GetGameState() == kGameState.Countdown or (gameRules:GetGameStarted() and Shared.GetTime() - gameRules:GetGameStartTime() < kMaxTimeBeforeReset)
    end
    
    local activeVoteName, activeVoteData, activeVoteResults, activeVoteStartedAtTime, activeVoteNumPlayers
    local activeVoteId = 0
    local lastVoteStartAtTime
    local lastTimeVoteResultsSent = 0
	local lastSentResults = {}
    local voteSuccessfulCallbacks = { }
    
    local startVoteHistory = { }
    
    function GetStartVoteAllowed(voteName, client)

        -- Check that there is no current vote.
        if activeVoteName then    
            return kVoteCannotStartReason.VoteInProgress
        end
        
        -- Check that enough time has passed since the last vote.
        if lastVoteStartAtTime and Shared.GetTime() - lastVoteStartAtTime < kNextVoteAllowedAfterTime then
            return kVoteCannotStartReason.Waiting
        end
        
        -- Check that this client hasn't started a failed vote of this type recently.
        if client then
            for v = #startVoteHistory, 1, -1 do

                local vote = startVoteHistory[v]
                if voteName == vote.type and client:GetUserId() == vote.client_id then

                    if not vote.succeeded and Shared.GetTime() - vote.start_time < kStartVoteAfterFailureLimit then
                        return kVoteCannotStartReason.Spam
                    end

                end

            end
        end
        
        local votingSettings = Server.GetConfigSetting("voting")
        if votingSettings and votingSettings[string.lower(voteName)] == false then
            return kVoteCannotStartReason.DisabledByAdmin
        end
        
        if voteName == "VoteResetGame" then
            if not VotingResetGameAllowed() then
                if GetGamerules():GetGameState() < kGameState.Countdown then
                    return kVoteCannotStartReason.TooEarly
                else
                    return kVoteCannotStartReason.TooLate
                end
            end
        end

        if voteName == "VoteAddCommanderBots" then
            if not VotingAddCommanderBotsAllowed() then
                return kVoteCannotStartReason.UnsupportedGamemode
            end
        end
        
        if voteName == "VotingForceEvenTeams" then
            if GetGamerules():GetGameStarted() then
                return kVoteCannotStartReason.GameInProgress
            end
        end
        
        return kVoteCannotStartReason.VoteAllowedToStart
        
    end
    
    local function GetNumVotingPlayers()
        return Server.GetNumPlayers() - #gServerBots
    end
        
    local function GetVotePassed(yesVotes, noVotes)
        return yesVotes > (activeVoteNumPlayers / 2)
    end
    
    function StartVote(voteName, client, data)
        
        local voteCanStart = GetStartVoteAllowed(voteName, client)
        if voteCanStart == kVoteCannotStartReason.VoteAllowedToStart then

            local clientId = client and client:GetId() or 0
        
            activeVoteId = activeVoteId + 1
            activeVoteName = voteName
            activeVoteResults = {
                voters = {},
                votes = {}
            }
            activeVoteStartedAtTime = Shared.GetTime()
			activeVoteNumPlayers = GetNumVotingPlayers()
            lastVoteStartAtTime = activeVoteStartedAtTime
			lastSentResults = {}
            data.voteId = activeVoteId
            local now = Shared.GetTime()
            data.expireTime = now + kVoteExpireTime
            data.client_index = clientId
            Server.SendNetworkMessage(voteName, data)
            
            activeVoteData = data
            
            table.insert(startVoteHistory, { type = voteName, client_id = clientId, start_time = now, succeeded = false })
            
            Print("Started Vote: " .. voteName)
            
        elseif client then
            Server.SendNetworkMessage(client, "VoteCannotStart", { reason = voteCanStart }, true)
        end
        
    end
    
    function HookStartVote(voteName)
        
        local function OnStartVoteReceived(client, message)
            StartVote(voteName, client, message)
        end
        Server.HookNetworkMessage(voteName, OnStartVoteReceived)
        
    end
    
    function RegisterVoteType(voteName, voteData)
        
        assert(voteData.voteId == nil, "voteId field detected while registering a vote type")
        voteData.voteId = "integer"
        assert(voteData.expireTime == nil, "expireTime field detected while registering a vote type")
        voteData.expireTime = "time"
        assert(voteData.client_index == nil, "client_index field detected while registering a vote type")
        voteData.client_index = "integer"
        Shared.RegisterNetworkMessage(voteName, voteData)
        HookStartVote(voteName)
        
    end
    
    function SetVoteSuccessfulCallback(voteName, delayTime, callback)
    
        local voteSuccessfulCallback = { }
        voteSuccessfulCallback.delayTime = delayTime
        voteSuccessfulCallback.callback = callback
        voteSuccessfulCallbacks[voteName] = voteSuccessfulCallback
        
    end
    
    local function CountVotes(voteResults)
    
        local yes = 0
        local no = 0
        for i = 1, #voteResults.voters do

            local clientId = voteResults.voters[i]
            local choice = voteResults.votes[clientId]

			--Log("voter: %s for %s",clientId,  #voteResults.voters)
            yes = (choice and yes + 1) or yes
            no = (not choice and no + 1) or no
            
        end
        
        return yes, no
        
    end
    
    local lastVoteSent = 0
    
    local function OnSendVote(client, message)
    
        if activeVoteName then
        
            local votingDone = Shared.GetTime() - activeVoteStartedAtTime >= kVoteExpireTime
            if not votingDone and message.voteId == activeVoteId then
                local clientId = client:GetUserId()
                if activeVoteResults.votes[clientId] == nil then
                    table.insert(activeVoteResults.voters, clientId)
                end

                activeVoteResults.votes[clientId] = message.choice
                lastVoteSent = Shared.GetTime()
            end
            
        end
        
    end
    Server.HookNetworkMessage("SendVote", OnSendVote)
    
    local function OnUpdateVoting(dt)
    
        if activeVoteName then
        
			if not activeVoteNumPlayers or activeVoteNumPlayers < GetNumVotingPlayers() then
				activeVoteNumPlayers = GetNumVotingPlayers()
			end
			
            local yes, no = CountVotes(activeVoteResults)
            local required = math.floor(activeVoteNumPlayers / 2) + 1
            local voteSuccessful = GetVotePassed(yes, no)
            local voteFailed = no >= math.floor(activeVoteNumPlayers / 2) + 1
        
			local voteState = kVoteState.InProgress
			
			local votingDone = Shared.GetTime() - activeVoteStartedAtTime >= kVoteExpireTime or voteSuccessful or voteFailed
			if votingDone then
				voteState = voteSuccessful and kVoteState.Passed or kVoteState.Failed
			end
			
			local newMessage = { voteId = activeVoteId, yesVotes = yes, noVotes = no, state = voteState, requiredVotes = required }
			local newMessageString = table.tostring(newMessage)
			
            if Shared.GetTime() - lastTimeVoteResultsSent > 0.2 and not newMessageString ~= lastSentResults then
            
                Server.SendNetworkMessage("VoteResults", newMessage, true)
                lastTimeVoteResultsSent = Shared.GetTime()
				lastSentResults = newMessageString
                
            end
            
            local voteSuccessfulCallback = voteSuccessfulCallbacks[activeVoteName]
            local delay = (voteSuccessfulCallback and (kVoteExpireTime + voteSuccessfulCallback.delayTime)) or kDefaultVoteExecuteTime
            
            if voteSuccessful then
                delay = lastVoteSent - activeVoteStartedAtTime + voteSuccessfulCallback.delayTime
            end
            if Shared.GetTime() - activeVoteStartedAtTime >= delay then
            
                Server.SendNetworkMessage("VoteComplete", { voteId = activeVoteId }, true)
                
                local yes, no = CountVotes(activeVoteResults)
                local voteSuccessful = GetVotePassed(yes, no)
                startVoteHistory[#startVoteHistory].succeeded = voteSuccessful
                Print("Vote Complete: " .. activeVoteName .. ". Successful? " .. (voteSuccessful and "Yes" or "No"))
                
                if voteSuccessfulCallback and voteSuccessful then
                    voteSuccessfulCallback.callback(activeVoteData)
                end
                
                activeVoteName = nil
                activeVoteData = nil
                activeVoteResults = nil
                activeVoteStartedAtTime = nil
				activeVoteNumPlayers = nil
                
            end
            
        end
        
    end
    Event.Hook("UpdateServer", OnUpdateVoting)
	
	-- this is a HORRIBLE hack for shine's HORRIBLE hack
	local oldgetinfo = debug.getinfo
	debug.getinfo = function(thread, f, what)
		local info = oldgetinfo(thread, f, what)
		
		if f == "S" and info.source == "@lua/NS2Fixes/Voting/Replace/Voting.lua" then
			info.source = "@lua/Voting.lua"
		end
		
		return info
	end
    
end

if Client then

    local currentVoteQuery
    local currentVoteId = 0
    local currentVoteExpireTime = 0
    local yesVotes = 0
    local noVotes = 0
    local requiredVotes = 0
    local lastVoteResults
    
    function RegisterVoteType(voteName, voteData)
        
        assert(voteData.voteId == nil, "voteId field detected while registering a vote type")
        voteData.voteId = "integer"
        assert(voteData.expireTime == nil, "expireTime field detected while registering a vote type")
        voteData.expireTime = "time"
        assert(voteData.client_index == nil, "client_index field detected while registering a vote type")
        voteData.client_index = "integer"
        Shared.RegisterNetworkMessage(voteName, voteData)
        
    end
    
    local voteSetupCallbacks = { }
    function AddVoteSetupCallback(callback)
        table.insert(voteSetupCallbacks, callback)
    end
    
    function AttemptToStartVote(voteName, data)
        Client.SendNetworkMessage(voteName, data, true)
    end
    
    function SendVoteChoice(votedYes)
    
        if currentVoteId > 0 then
        
            -- DON'T predict the vote locally for the UI.
            Client.SendNetworkMessage("SendVote", { voteId = currentVoteId, choice = votedYes }, true)
            
        end
        
    end
    
    function GetCurrentVoteId()
        return currentVoteId
    end
    
    function GetCurrentVoteQuery()
        return currentVoteQuery
    end
    
    function GetCurrentVoteTimeLeft()
        return math.max(0, currentVoteExpireTime - Shared.GetTime())
    end
    
    function GetLastVoteResults()
        return lastVoteResults
    end
    
    function AddVoteStartListener(voteName, queryTextGenerator)
        
        if hookedVoteTypes[voteName] then
            return
        end
        
        local function OnVoteStarted(data)
        
            currentVoteId = data.voteId
            currentVoteExpireTime = data.expireTime
            yesVotes = 0
            noVotes = 0
            requiredVotes = 0
            currentVoteQuery = queryTextGenerator(data)
            lastVoteResults = nil
            local message = StringReformat(Locale.ResolveString("VOTE_PLAYER_STARTED_VOTE"), { name = Scoreboard_GetPlayerName(data.client_index) })
            ChatUI_AddSystemMessage(message)
            
        end
        Client.HookNetworkMessage(voteName, OnVoteStarted)
        
        hookedVoteTypes[voteName] = true
        
    end
    
    local function OnVoteResults(message)
    
        if currentVoteId == message.voteId then
        
            
            yesVotes =  message.yesVotes
            noVotes = message.noVotes
            requiredVotes = math.max(requiredVotes, message.requiredVotes)
            
            if message.state == kVoteState.Passed then
                lastVoteResults = true
            elseif message.state == kVoteState.Failed then
                lastVoteResults = false
            end
            
        end
        
    end
    Client.HookNetworkMessage("VoteResults", OnVoteResults)
    
    function GetVoteResults()
        return yesVotes, noVotes, requiredVotes
    end
    
    local function OnVoteComplete(message)
    
        if message.voteId == currentVoteId then
        
            currentVoteQuery = nil
            currentVoteId = 0
            currentVoteExpireTime = 0
            yesVotes = 0
            noVotes = 0
            requiredVotes = 0
            lastVoteResults = nil
            
        end
        
    end
    Client.HookNetworkMessage("VoteComplete", OnVoteComplete)
    
    local function OnVoteCannotStart(message)
    
        local reasonStr = kVoteCannotStartReasonStrings[message.reason]
        ChatUI_AddSystemMessage(Locale.ResolveString(reasonStr))
        
    end
    Client.HookNetworkMessage("VoteCannotStart", OnVoteCannotStart)
    
    -- Must be called after GUIStartVoteMenu is created.
    function OnGUIStartVoteMenuCreated(name, script)
    
        if name ~= "GUIStartVoteMenu" then
            return
        end
        
        -- Setup all the vote types.
        for s = 1, #voteSetupCallbacks do
            voteSetupCallbacks[s](script)
        end
        
    end
    ClientUI.AddScriptCreationEventListener(OnGUIStartVoteMenuCreated)
    
end

--Load all the Votes
Script.Load("lua/VotingKickPlayer.lua")
Script.Load("lua/VotingChangeMap.lua")
Script.Load("lua/VotingResetGame.lua")
Script.Load("lua/VotingRandomizeRR.lua")
Script.Load("lua/VotingForceEvenTeams.lua")
Script.Load("lua/VotingAddCommanderBots.lua")