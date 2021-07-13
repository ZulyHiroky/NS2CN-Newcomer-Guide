--34
local Plugin = {}
Plugin.NotifyBad = { 255,0,0 }
Plugin.NotifyGood = { 0,255,0 }
Plugin.NotifyEqual = { 0, 150, 255 }



function Plugin:SetupDataTable()
    self:AddDTVar( "integer (0 to 10000)", "avgteam1", 0 )
    self:AddDTVar( "integer (0 to 10000)", "avgteam2", 0 )
	self:AddDTVar( "integer (0 to 100)", "totPlayersMarines", 0 )
	self:AddDTVar( "integer (0 to 100)", "totPlayersAliens", 0 )
	--The below var is used, to hide directly the text when you join spectator and directly shows it back when you re-join the RR
	self:AddDTVar( "integer (0 to 10)", "triggertextupdate", 0)
	self:AddDTVar( "boolean", "inform", true )
	self:AddDTVar( "boolean", "seedingphase", true )
	self:AddNetworkMessage( "DisplayScreenText", { show = "boolean" }, "Client" )
	self:AddNetworkMessage( "DisplayResetinfo", { show = "boolean" }, "Client" )
	self:AddDTVar("integer (0 to 100)", "MinPlayers", 0 )
end

Shine:RegisterExtension( "fairplay", Plugin )


function Plugin:Initialise()
	Print("Shine plugin Fairplay loaded (version 1.0 beta)")
	if(Server) then
			self.dt.inform=self.Config.InformPlayer
			self.dt.MinPlayers=self.Config.MinPlayers
			self.dt.seedingphase=true
	end
	--self:CreateCommands()
	--Replace the random team behavior to always choose the team where the player improve the skills
	if Server then
		local oldJoinRandomTeam = JoinRandomTeam;
		function JoinRandomTeam(player)
			--oldJoinRandomTeam(player);
			-- Join team with less players or random.
			local team1Players = GetGamerules():GetTeam(kTeam1Index):GetNumPlayers()
			local team2Players = GetGamerules():GetTeam(kTeam2Index):GetNumPlayers()
			
			-- Join team with least.
			if team1Players < team2Players then
				Server.ClientCommand(player, "jointeamone")
			elseif team2Players < team1Players then
				Server.ClientCommand(player, "jointeamtwo")
			else
				local playerskill = player.GetPlayerSkill and player:GetPlayerSkill() or 0
				--Print("pskill: %s", playerskill);
				local team_number
				if(playerskill ~= -1) then
					team_number =self:GetCanJoinTeam(self.dt.avgteam1, self.dt.avgteam2, self.dt.totPlayersMarines, self.dt.totPlayersAliens, playerskill)
				else --player has no skill, let him join a random team
					team_number=0
				end
				
				if(team_number == 0 or team_number == 5 or team_number == 6 or team_number == 7) then
					if math.random() < 0.5 then
						Server.ClientCommand(player, "jointeamone")
					else
						Server.ClientCommand(player, "jointeamtwo")
					end
				elseif(team_number == 1 or team_number == 3) then
					Server.ClientCommand(player, "jointeamone")
				else --2 or 4
					Server.ClientCommand(player, "jointeamtwo")
				end
				
			end
		end
		self.oldJoinRandomTeam = oldJoinRandomTeam;
	end
	--
	
	
	self.Enabled = true
	return true
end



function Plugin:CreateCommands()
	local Commands = Plugin.Commands

	local function Runtest()
		Print("testing plugin Jointeam...")
		Script.Load( "test/test_init.lua")
		return true
	end
	
	self:BindCommand( "sh_jointeam_ut", "jointeam_ut", Runtest, false )
end



function Plugin:NetworkUpdate( Key, OldValue, NewValue )

 if Client then
	self:UpdateScreenTextStatus()
	--self:UpdateResetinfoStatus()
 end
 
end

--The function define if a player witch team(s), he can join.
--The value returned is:
	-- 0: Can join any team
	-- 1: can join only marines and improve balance
	-- 2: can join only aliens and improve balance
	-- 3: can join marines and decrease balance (but less than aliens)
	-- 4: can join aliens and decrease balance (but less than  marines)
	-- 5: can join any team and decrease the balance identically whatever the team he choose
	-- 6: can join anyteam, function malfunctionned.
	-- 7: playerskill == -1, the player is probably a bot
	-- 8: skill difference would be above the limit: not allowed

function Plugin:CheckJoin(avgt1, avgt2, numPlayert1, numPlayert2, playerskill)
    
    if(playerskill <= 0) then --bots and rookies may join anywhere
		return 7
	end
	
	if Server and self.Config.Debug then
        Print("Fairplay DEBUG: CheckJoin BlockSkillDiff: %s MinPlayers: %s", self.Config.BlockSkillDiff, self.Config.MinPlayers)
    end
    
    local BlockSkillDiff = 200 --lets give a deafult value for clients
    if Server then
        BlockSkillDiff = self.Config.BlockSkillDiff
    end
	
	-- both teams skill averages will be calculated with the playercounts of the team with the more players
	local curMorePlayers = 0
	if (numPlayert1 >= numPlayert2) then
	    curMorePlayers = numPlayert1
	else
	    curMorePlayers = numPlayert2
	end
	
	if ( curMorePlayers <= 0 ) then -- prevent divide by zero if teams are empty
	    curMorePlayers = 1
	end
	
    local curSkillAvgM = avgt1 * numPlayert1 / curMorePlayers
    local curSkillAvgA = avgt2 * numPlayert2 / curMorePlayers
    local curSkillDiff =  curSkillAvgM - curSkillAvgA
    local newNumPlayersM = numPlayert1 + 1
    local newNumPlayersA = numPlayert2 + 1
 
    local newMorePlayersM = 0
	if (newNumPlayersM >= numPlayert2) then
	    newMorePlayersM = newNumPlayersM
	else
	    newMorePlayersM = numPlayert2
	end
	
    local newMorePlayersA = 0
	if (newNumPlayersA >= numPlayert1) then
	    newMorePlayersA = newNumPlayersA
	else
	    newMorePlayersA = numPlayert1
	end
		
    local newMSkillAvgM = (avgt1*numPlayert1+playerskill)/newMorePlayersM
    local newASkillAvgM = (avgt2*numPlayert2)/newMorePlayersM
    local newSkillDiffM = newMSkillAvgM - newASkillAvgM
 
    local newMSkillAvgA = (avgt1*numPlayert1)/newMorePlayersA
    local newASkillAvgA = (avgt2*numPlayert2+playerskill)/newMorePlayersA
    local newSkillDiffA = newMSkillAvgA - newASkillAvgA
    
    
    if Server and self.Config.Debug then
        Print("Fairplay DEBUG: CheckJoin (M/A) Current SkillAvgs: %d/%d (%d) Players: %d:%d", curSkillAvgM, curSkillAvgA, curSkillDiff, numPlayert1, numPlayert2)
	    Print("Fairplay DEBUG: CheckJoin if +%d to Marines: (M/A) new avgs: %d/%d (%d) players: %d/%d BlockSkillDiff: %d", playerskill, newMSkillAvgM, newASkillAvgM, newSkillDiffM, newNumPlayersM, numPlayert2, BlockSkillDiff)
	    Print("Fairplay DEBUG: CheckJoin if +%d to  Aliens: (M/A) new avgs: %d/%d (%d) players: %d/%d BlockSkillDiff: %d", playerskill, newMSkillAvgA, newASkillAvgA, newSkillDiffA, numPlayert1, newNumPlayersA, (-1 * BlockSkillDiff))
	end
	
	-- negative SkillDiff means marines are weaker
	if ( ( math.abs(newSkillDiffM) < math.abs(newSkillDiffA) ) and ( curSkillDiff < newSkillDiffM ) and ( newSkillDiffM <= BlockSkillDiff ) ) then
	    -- joining marines will improve
	    return 1
	elseif ( ( math.abs(newSkillDiffA) < math.abs(newSkillDiffM) ) and ( curSkillDiff > newSkillDiffA ) and ( newSkillDiffA >= (-1 * BlockSkillDiff) ) ) then
	    -- joining aliens will improve
	    return 2
	else
	    return 8
	end
end

--For testing we must pass all arguments, instead of using plugins variables
function Plugin:GetCanJoinTeam(avgt1, avgt2, numPlayert1, numPlayert2, playerskill)

	if(playerskill == -1) then
		return 7
	end
	
	-- both teams skill averages will be calculated with the playercounts of the team with the more players
	local curMorePlayers = 0
	if (numPlayert1 >= numPlayert2) then
	    curMorePlayers = numPlayert1
	else
	    curMorePlayers = numPlayert2
	end
		
	local newavgt1=(avgt1*numPlayert1+playerskill)/(curMorePlayers+1)
	local newavgt2=(avgt2*numPlayert2+playerskill)/(curMorePlayers+1)
	
	local realAvgt1 = 0
	local realAvgt2 = 0
	if ( curMorePlayers > 0 ) then
        realAvgt1 = avgt1*numPlayert1/curMorePlayers
        realAvgt2 = avgt2*numPlayert2/curMorePlayers
    end
    local deltaCurrent = math.abs((realAvgt1-realAvgt2))
	local deltaT1 = math.abs((newavgt1-realAvgt2))
	local deltaT2 = math.abs((newavgt2-realAvgt1))
	
	if Server and self.Config.Debug then
	    Print("Fairplay DEBUG: GetCanJoinTeam Skill: %d  M(count/avg(real)/newavg): %d/%d(%d)/%d , A(count/avg(real)/newavg): %d/%d(%d)/%d", playerskill, numPlayert1, avgt1, realAvgt1, newavgt1, numPlayert2, avgt2, realAvgt2, newavgt2 )
	end

    if Server and self.Config.Debug then
	    Print("Fairplay DEBUG: GetCanJoinTeam deltaCurrent: %s, deltaT1: %s, deltaT2: %s",deltaCurrent, deltaT1, deltaT2)
	end

	if((deltaT1 <= deltaCurrent) and (deltaT2 <= deltaCurrent)) then
		--Improve balance when joining anyteam
		return 0	
	elseif((deltaT1 <= deltaCurrent) and (deltaT2 > deltaCurrent)) then
		--Improve balance when joining marines team only 
		return 1
	elseif((deltaT1 > deltaCurrent) and (deltaT2 <= deltaCurrent)) then
		--Improve balance when joining aliens team only 
		return 2
	elseif((deltaT1 > deltaCurrent) and (deltaT2 > deltaCurrent)) then
		--Never improve balance when joining, we need to find the team where he does less damage
		if(deltaT1 < deltaT2) then
			return 3
		elseif(deltaT1 > deltaT2)then
			return 4
		else --deltaT1 == deltaT2
			return 5
		end
	else
	--Should never be reach
		return 6
	end
end

function Plugin:Cleanup()
if Server then
JoinRandomTeam=self.oldJoinRandomTeam;
end

if Client then
	if(self.screentext_current) then
				self.screentext_current.Obj:SetIsVisible(false)
				self.screentext_JoinM.Obj:SetIsVisible(false)
				self.screentext_JoinA.Obj:SetIsVisible(false)
	end
end

self.Enabled = false
end
