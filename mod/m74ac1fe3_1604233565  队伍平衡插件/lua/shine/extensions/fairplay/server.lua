--34
--The plugin table registered in shared.lua is passed in as the global "Plugin".
local Plugin = Plugin
local avgglobal=0
local avgteam1=0
local avgteam2=0
local playersinfo
local Shine=Shine
local totPlayersMarines=0
local totPlayersAliens=0
local notify
local gamestate=0
local tag="[Fairplay]"
Plugin.avgglobal = avgglobal
Plugin.avgteam1 = avgteam1
Plugin.avgteam2 = avgteam2
Plugin.gamestate = gamestate
Plugin.playersinfo= playersinfo 
Plugin.totPlayersMarines =totPlayersMarines
Plugin.totPlayersAliens =totPlayersAliens
Plugin.seedingphase =seedingphase
Plugin.tag=tag
Plugin.NotifyPrefixColour = {
	0, 150, 255
}
--local rseed =math.randomseed( os.time() )

Plugin.HasConfig = true
Plugin.ConfigName = "fairplay.json" 
Plugin.DefaultConfig = {
    InformPlayer = true,
	ForcePlayer = true,
	BlockSkillDiff = 200,
	MinPlayers = 12,
	AllowAsyncTeams = true,
	StrictTeamsPre = false,
	Debug = false,
	Munin = false,
}
Plugin.CheckConfig = true

--Shine hook, when a player try to join a team
--return without arguments allow the player to join the team
--return false, 0 prevent the player is not authorized to join the team
function Plugin:JoinTeam( Gamerules, Player, NewTeam, force, ShineForce ) -- jointeam is hook on server side only
	--GameStates 
	-- kGameState = enum( {'NotStarted', 'WarmUp', 'PreGame', 'Countdown', 'Started', 'Team1Won', 'Team2Won', 'Draw'} )
	--	2: pregame (bots)
	--	5: started with bot commander
	--  6: postgame? someone won?
	self.gamestate = Gamerules:GetGameState()
	if self.Config.Debug then
		Print("Fairplay DEBUG enabled, MinPlayers: %d, BlockSkillDiff: %d, StrictTeamsPre: %s, GameState: %s, Seeding: %s",self.Config.MinPlayers, self.Config.BlockSkillDiff, self.Config.StrictTeamsPre, self.gamestate, self.dt.seedingphase) 
	end
	if(self.Config.ForcePlayer == true) then
	    
		local playerskill=Shared.GetEntity(Player.playerInfo.playerId):GetPlayerSkill()
		--TO DO, do something about the NS2 vote randomize ready room. 
		--This vote don't use the force value :x
		if(force) then
			if self.Config.Debug then
			    Print("Fairplay DEBUG: %s Have been forced to join a team by NS2", playerskill)
			end
			return
		elseif(ShineForce) then
			if self.Config.Debug then
			    Print("Fairplay DEBUG: %s Have been forced to join a team by Shine", playerskill)
			end
			return
		end
		
		if(NewTeam < 1) or (NewTeam > 2) then --join spec or RR
			--if self.Config.Debug then
			--    Print("Fairplay DEBUG: If you want to go into the RR or spectate, I let you do")
			--end
			return
		end
		 
		local gamerules = GetGamerules()
		--local team1Players = gamerules.team1:GetNumPlayers()
	    --local team2Players = gamerules.team2:GetNumPlayers()
		local team1SumPlayers, _, team1Bots = gamerules:GetTeam1():GetNumPlayers()
	    local team2SumPlayers, _, team2Bots = gamerules:GetTeam2():GetNumPlayers()
		local team1Players = team1SumPlayers - team1Bots
		local team2Players = team2SumPlayers - team2Bots
		local sumPlayers = team1Players + team2Players
		local minTeam = self.Config.MinPlayers/2
            
		-- check if trying to join the team with the more players
		if self.Config.Debug then
		    Print("Fairplay DEBUG: Players of A/M: %s + %s (%s) / %s + %s (%s)", team1Players, team1Bots, team1SumPlayers, team2Players, team2Bots, team2SumPlayers)
		end
		
	    if (self.gamestate ~= 5) and (self.Config.StrictTeamsPre == false) then
	        if (team1Players >= minTeam and team2Players < minTeam) or (team2Players >= minTeam and team1Players < minTeam) then
	            if self.Config.Debug then
			        Print("Fairplay DEBUG: Game not started, but a team still has bots.")
			    end
	        else
	            if self.Config.Debug then
			        Print("Fairplay DEBUG: Game not started. Teamchoices are not restriced")
			    end
	            return
	        end
	    end
        if (team1Players > team2Players) and (NewTeam == gamerules.team1:GetTeamNumber()) and (playerskill ~= -1 ) and ( self.Config.AllowAsyncTeams == false ) then
		    if self.Config.Debug then
			    Print("Fairplay DEBUG: %s tried to join marines but too many players there", playerskill)
		    end
			Shine:NotifyColour( Player, 255, 0, 0, string.format("too many players in the %s team", Shine:GetTeamName(NewTeam, true)))
            return false, 0
        elseif (team2Players > team1Players) and (NewTeam == gamerules.team2:GetTeamNumber()) and (playerskill ~= -1) and ( self.Config.AllowAsyncTeams == false ) then
			if self.Config.Debug then
			    Print("Fairplay DEBUG: %s tried to join aliens, but too many players there", playerskill)
			end
		    Shine:NotifyColour( Player, 255, 0, 0, string.format("too many players in the %s team", Shine:GetTeamName(NewTeam, true)))
            return false, 0
        end
			
		--check if trying to join the team with less players
		--TO DO check if there is many people in RR and if enough of them can improve the balance, then also restrict the join.
		if (team1Players > team2Players) and (NewTeam == gamerules.team2:GetTeamNumber()) and (self.dt.seedingphase == true) then
			self.NotifyPrefixColour=self.NotifyEqual
			self:NotifyTranslated(Player, "OK_LESS_PLAYER")
            self:NotifyTranslated(Player, "OK_ALIENS")
			if self.Config.Debug then
			    Print("Fairplay DEBUG: %s joining  to less player team: aliens", playerskill)
			end
			return 
        elseif (team2Players > team1Players) and (NewTeam == gamerules.team1:GetTeamNumber()) and (self.dt.seedingphase == true) then
			self.NotifyPrefixColour=self.NotifyEqual
			self:NotifyTranslated(Player, "OK_LESS_PLAYER")
           	self:NotifyTranslated(Player, "OK_MARINES")
           	if self.Config.Debug then
			    Print("Fairplay DEBUG: %s joining to less player team: marines", playerskill)
			end
         	return 
        end
			
		--It let us only the case where the number of players in each team is equal.
		local canjoin = 0
		if(self.dt.seedingphase == true) then	
		    canjoin = self:GetCanJoinTeam(self.avgteam1, self.avgteam2, team1Players, team2Players, playerskill)
		else
		    canjoin = self:CheckJoin(self.avgteam1, self.avgteam2, team1Players, team2Players, playerskill)
		end

		if(NewTeam == gamerules.team1:GetTeamNumber()) then
			-- try to join marines
			if(canjoin == 0) then
				self.NotifyPrefixColour=self.NotifyGood
				self:NotifyTranslated(Player, "OK_CHOICE")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to marine: OK (0=does not matters the team)", playerskill)
				end
				return
			elseif(canjoin == 1) then
				self.NotifyPrefixColour=self.NotifyGood
				self:NotifyTranslated(Player, "OK_MARINES")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to marine: OK (1=balance improved)", playerskill)
				end
				return
			elseif(canjoin == 2) then
				self.NotifyPrefixColour=self.NotifyBad
				self:NotifyTranslated(Player, "ERROR_1")
				self:NotifyTranslated(Player, "ERROR_2")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to marine: NO (2=STACKING!)", playerskill)
				end
				return false, 0
			elseif(canjoin == 3) then
				self.NotifyPrefixColour=self.NotifyEqual
				self:NotifyTranslated(Player, "OK_MARINES")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to marine: EW (3=may join, but balance will be worse, however less than joining aliens)", playerskill)
			    end	
                --TODO: apply StackDiff
				return
			elseif(canjoin == 4) then
				self.NotifyPrefixColour=self.NotifyBad
				self:NotifyTranslated(Player, "ERROR_1")
				self:NotifyTranslated(Player, "ERROR_2")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to marine: NO (4=not allowed, balance would be more worse than joining aliens)", playerskill)
				end
				return false, 0
			elseif(canjoin == 5) then
				self.NotifyPrefixColour=self.NotifyEqual
				self:NotifyTranslated(Player, "OK_CHOICE")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to marine: EW (5=teams are balanced, joining any team will make it worse)", playerskill)
				end
				--TODO: apply StackDiff
				return
			elseif(canjoin == 7) then
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s bot joined to marine (7)", playerskill)
				end
				return
			elseif(canjoin == 8) then
			    if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to marine: NO (8=teams are balanced, joining any team will make it worse)", playerskill)
				end
				self.NotifyPrefixColour=self.NotifyBad
			    self:NotifyTranslated(Player, "ERROR_0")
			    return false
			else --6
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to marine: (%s)THIS SHOULD NOT HAPPEN", playerskill, canjoin)
				end
			    return
			end
		else --aliens
			if(canjoin == 0) then
				self.NotifyPrefixColour=self.NotifyGood
				self:NotifyTranslated(Player, "OK_CHOICE")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to alien: OK (0=does not matters the team)", playerskill)
				end
				return
			elseif(canjoin == 1) then
				self.NotifyPrefixColour=self.NotifyBad
				self:NotifyTranslated(Player, "ERROR_1")
				self:NotifyTranslated(Player, "ERROR_2")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to alien: NO (1=STACKING!)", playerskill)
				end
				return false, 0
			elseif(canjoin == 2) then
				self.NotifyPrefixColour=self.NotifyGood
				self:NotifyTranslated(Player, "OK_ALIENS")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to alien: OK (2=balance improved))", playerskill)
				end
				return
			elseif(canjoin == 3) then
				self.NotifyPrefixColour=self.NotifyBad
				self:NotifyTranslated(Player, "ERROR_1")
				self:NotifyTranslated(Player, "ERROR_2")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to alien: NO (3=not allowed, balance would be more worse than joining marines)", playerskill)
				end
				return false, 0
			elseif(canjoin == 4) then
				self.NotifyPrefixColour=self.NotifyEqual
				self:NotifyTranslated(Player, "OK_ALIENS")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to alien: EW (4=may join, but balance will be worse, however less than joining marines)", playerskill)
				end
				--TODO: apply StackDiff
				return
			elseif(canjoin == 5) then
				self.NotifyPrefixColour=self.NotifyEqual
				self:NotifyTranslated(Player, "OK_CHOICE")
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to alien: EW (5=teams are balanced, joining any team will make it worse)", playerskill)
				end
				--TODO: apply StackDiff
				return
			elseif(canjoin == 7) then
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s bot joined to alien (7)", playerskill)
				end
				return
			elseif(canjoin == 8) then
			    if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to alien: NO (8=teams are balanced, joining any team will make it worse)", playerskill)
				end
				self.NotifyPrefixColour=self.NotifyBad
			    self:NotifyTranslated(Player, "ERROR_0")
			    return false
			else --6
				if self.Config.Debug then
				    Print("Fairplay DEBUG: %s to alien: (%s)THIS SHOULD NOT HAPPEN", playerskill, canjoin)
				end
			    return
			end
		end
		
		Print("%s JoinTeam function error", self.tag)
		return   
	else
		if self.Config.Debug then
		    Print("Fairplay DEBUG: plugin is NOT live")
		end
		return
	end
end

function Plugin:CheckLimit( Gamerules )
    --if not self.Config.CheckLimit or not self.dt.ShowStatus then return end
    
    local Team1Players, _, Team1Bots = Gamerules:GetTeam1():GetNumPlayers()
    local Team2Players, _, Team2Bots = Gamerules:GetTeam2():GetNumPlayers()

    local PlayerCount = Team1Players + Team2Players - Team1Bots - Team2Bots

    local toogle = GetGameInfoEntity():GetWarmUpActive()

    if ( (PlayerCount >= self.Config.MinPlayers) and (self.dt.seedingphase == true) )then
        if not self:GetTimer( "Countdown" ) then
            --Print("CheckLimit: warmupactive? %s",GetGameInfoEntity():GetWarmUpActive() and "no" or "yes" )
            --self.dt.CountdownText = StringFormat( "%s\n%s\n%s", StringFormat( self.Config.Strings.Status,
            --    not GetGameInfoEntity():GetWarmUpActive()  and "disabled" or "enabled" ), StringFormat( self.Config.Strings.Countdown,
            --    not GetGameInfoEntity():GetWarmUpActive() and "on" or "off", "%s"), self.Config.ExtraMessageLine )
            if self.Config.Debug then
	            Print("Fairplay DEBUG: CheckLimit: Seeding phase is over, Game will reset.")
	        end
            self:SendNetworkMessage( Client, "DisplayResetinfo", { show = true }, true )
            --self:CreateTimer( "Countdown", self.dt.StatusDelay, 1, function()
            self:CreateTimer( "Countdown", 10, 1, function()
                if self.Config.Debug then
                    Print("Fairplay DEBUG: CheckLimit: reset done.")
                end
                self.dt.seedingphase = false
                self:SendNetworkMessage( Client, "DisplayResetinfo", { show = true }, true )
                Gamerules:ResetGame()
            end)
        end
    elseif self:TimerExists( "Countdown" ) then
        if self.Config.Debug then
            Print("Fairplay DEBUG: CheckLimit: countdown exists")
        end
        self:DestroyTimer( "Countdown" )
        self:SendNetworkMessage( Client, "DisplayResetinfo", { show = true }, true )
    end
end

function Plugin:PostJoinTeam( Gamerules, Player, OldTeam, NewTeam, Force, ShineForce )
	self:updateValues()
	self:CheckLimit( Gamerules )
end

function Plugin:ClientConfirmConnect( Client )
	if self.Config.Debug then
	    Print("Fairplay DEBUG: ClientConfirmConnect - update AVG values")
	end
	Shine.Timer.Simple( 4, function (Timer ) --Delayed because sometimes skill values are not yet initialized//
		self:updateValues()
	    self:SendNetworkMessage( Client, "DisplayScreenText", { show = true }, true )
	end)
end

function Plugin:ClientDisconnect( Client )
	if self.Config.Debug then
	    Print("Fairplay DEBUG: Player disconnect - update AVG values")
	end
	self:updateValues()
end

function Plugin:updateValues()
	playersinfo = Shared.GetEntitiesWithClassname("PlayerInfoEntity")
	--first create an Array with the skills values and teams associate
	local totPlayer=playersinfo:GetSize()
	local skills = {}
	local teams = {}
	for i, Ent in ientitylist( playersinfo ) do
		local playerskill=Ent.playerSkill
		if(Ent.teamNumber ~= 3 ) then --not spectating
			table.insert(teams, Ent.teamNumber)
			table.insert(skills, playerskill)
			--if self.Config.Debug then
			--    Print(string.format("Fairplay DEBUG: name: '%s' ID: '%s TEAM: %s SKILL: %d", Ent.playerName,  tostring( Ent.steamId ), Shine:GetTeamName( Ent.teamNumber, true ), Ent.playerSkill))
			--end
		end
	end
	
	self:RefreshGlobalsValues(teams, skills, totPlayer)
end

--Refresh the AVG skill of the connected players, the marines, the aliens and ignore spectators skill
function Plugin:RefreshGlobalsValues(teams, skills, totPlayer)
	local totPlayersMarines=0
	local totPlayersAliens=0
	local avg=0
	local avgt1=0
	local avgt2=0
		
	for key,teamNumber in ipairs(teams) do
		if(skills[key] ~= nil and skills[key] ~= -1) then   --ignore bots and players without skill
			if(teamNumber == 1 ) then --Marines 
				totPlayersMarines=totPlayersMarines+1
				avgt1=avgt1+skills[key]
				avg=avg+skills[key]
			elseif (teamNumber == 2 ) then --Aliens
				totPlayersAliens=totPlayersAliens+1
				avgt2=avgt2+skills[key]
				avg=avg+skills[key]
			elseif (teamNumber ==  3) then --Spectate
				--Ignore the players in spectators
				totPlayer=totPlayer-1
			else --ReadyRoom (4)
				avg=avg+skills[key]
			end
		end
	end

    if totPlayer ~= 0 then
		avg=avg/totPlayer
	end
	if totPlayersMarines ~= 0 then
		avgt1=avgt1/totPlayersMarines
	end
	if totPlayersAliens ~= 0 then
		avgt2=avgt2/totPlayersAliens
	end
	self.avgglobal = avg
	self.avgteam1 = avgt1
	self.avgteam2 = avgt2
	self.totPlayersMarines=totPlayersMarines
	self.totPlayersAliens=totPlayersAliens
	
		
	--Update datatable values
	self.dt.avgteam1=avgt1
	self.dt.avgteam2=avgt2
	self.dt.totPlayersMarines=totPlayersMarines
	self.dt.totPlayersAliens=totPlayersAliens
	self.dt.triggertextupdate=(self.dt.triggertextupdate+1)%10
	if self.Config.Debug then
	    Print("Fairplay DEBUG: RefreshGlobalsValues(): G: %d - %d M: %d - %d A: %d - %d Gamestate: %d", totPlayer, self.avgglobal, totPlayersMarines, avgt1, totPlayersAliens, avgt2, self.gamestate)
	end
	
	if ( self.dt.seedingphase==false) and ((totPlayersMarines + totPlayersAliens) < self.Config.MinPlayers) and (self.gamestate ~= 5) then
	    self.dt.seedingphase=true
    	if self.Config.Debug then
	        Print("Fairplay DEBUG: not enough players -> setting seedingphase to true")
	    end
	elseif ( (totPlayersMarines + totPlayersAliens) == 0) then
		self.dt.seedingphase=true
    	if self.Config.Debug then
	        Print("Fairplay DEBUG: 0 players -> setting seedingphase to true")
	    end
	end
	
	
	
	if self.Config.Munin and (self.dt.seedingphase == false) and self.gamestate == 5 then
	    local curSkillAvgM=0
	    local curSkillAvgA=0
	    if totPlayersMarines >= totPlayersAliens then
	        curSkillAvgM=avgt1
	        curSkillAvgA=avgt2*totPlayersAliens/totPlayersMarines
	    else
	        curSkillAvgA=avgt2
	        curSkillAvgM=avgt1*totPlayersMarines/totPlayersAliens
	    end
	    local curSkillDiff=curSkillAvgM-curSkillAvgA
	    Print("FairplayPluginMuninData(MP,AP,MSA,ASA,SD);%d;%d;%d;%d;%d", totPlayersMarines, totPlayersAliens, curSkillAvgM, curSkillAvgA, curSkillDiff  )
	elseif self.Config.Munin then
	    Print("FairplayPluginMuninData(MP,AP,MSA,ASA,SD);%d;%d;0;0;0", totPlayersMarines, totPlayersAliens)
	end
end

