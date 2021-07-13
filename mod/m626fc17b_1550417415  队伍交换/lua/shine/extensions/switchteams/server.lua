--[[
Switch Teams

Players locked onto a team because of shuffle rules
can request consideration to switch teams before the
game starts by typing !switch in chat. If a player
from both teams request to switch and if the average
team hive skill difference improves or remains the same
two players will be switched.

The mod also monitors team size and allows a 'random'
requesting player to switch teams if the other team's
player count is down a number of players (default = three).

Requires SHINE administration.


]]

local Plugin = Plugin
Plugin.Version = "1.0"
Plugin.HasConfig = true
Plugin.ConfigName = "switchteams.json"
Plugin.DefaultConfig = {
    teamgaplimit = 3,
}
Plugin.CheckConfig = true
Plugin.CheckConfigTypes = true

function Plugin:Initialise()
  self:CreateCommands()
	self.Enabled = true
	return true
end

local SwitchActiveState = true
local playersinfo
local MarineCount
local AlienCount
local MarineTeamSkillAVG
local AlienTeamSkillAVG
local TeamSkillAVGGap
local CURRENTALIENTEAMSKILL
local CURRENTMARINETEAMSKILL
local MarineList = {} -- List SteamIDKEY and skill of Marine that wants to switch teams
local AlienList = {} -- List SteamIDKEY and skill of Alien that wants to switch teams
local teamgaplimit

function Switch( Client )

	if not Client then return end

	-- only proceed if game is not Started
	if SwitchActiveState ~= true then
		Plugin:NotifyTranslated( Client, "GAMESTARTED" )
		return
	end

	-- only proceed if Client is on a team
	local Player = Client:GetControllingPlayer()
	local playerteam = Player:GetTeamNumber()

  if playerteam ~= 1 and playerteam ~= 2 then
 		Plugin:NotifyTranslated( Client, "NOTONTEAM" )
		return
	end

	-- Add players SteamIDKEY & Skill to team table
	local SteamIDKEY = Client:GetUserId()
	local playerskill = Player:GetPlayerSkill()


  if MarineList[SteamIDKEY] == playerskill and Player:GetTeamNumber() == 1 or AlienList[SteamIDKEY] == playerskill and Player:GetTeamNumber() == 2 then
    Plugin:NotifyTranslated( Client, "CONFIRMMESSAGE" )
    return
  end




  if playerteam == 1 then
		MarineList[SteamIDKEY] = playerskill
	end

  if playerteam == 2 then
		AlienList[SteamIDKEY] = playerskill
	end

  Plugin:SendTranslatedNotify( nil, "FEEDBACKMESSAGE1", {
    RequestName = Player:GetName()
  } )
  Plugin:NotifyTranslated( nil, "FEEDBACKMESSAGE2" )

  checkforswitch()
end


function checkforswitch()
  -- Called everytime someone disconnects, joins a team, switches one or two players

  -- How many players currently in each team
	local Marines = Shine.GetTeamClients( 1 )
	local Aliens = Shine.GetTeamClients( 2 )
	local MarineTeamCount = 0
	local AlienTeamCount = 0

	for i = 1, #Marines do --
		MarineTeamCount = MarineTeamCount + 1
	end

	for i = 1, #Aliens do
		AlienTeamCount = AlienTeamCount + 1
	end

-- check the teamgaplimit again in teamgapmonitor after some time in case some other plugin is moving players around for shuffle
  if math.abs( MarineTeamCount - AlienTeamCount) >= teamgaplimit then
    Plugin:SimpleTimer( ( 4 ), function()
      teamgapmonitor()
    end )
  end

  -- Check for qualifying players that can switch
  local breakflag = true
	while breakflag == true do -- loop - see if any two players in the lists are"switch worthy"
		breakflag = false -- breakflag will set back to true if a switch occurs so it will loop again - TIAFC

		-- update current TEAMSKILLs & TeamSkillAVGGap
		MarineCount = 0
		AlienCount = 0
		MarineTeamSkillAVG = 0
		AlienTeamSkillAVG = 0
		TeamSkillAVGGap = 0
		CURRENTALIENTEAMSKILL = 0
		CURRENTMARINETEAMSKILL = 0

		-- Get current reaL players skill average per team
		playersinfo = Shared.GetEntitiesWithClassname("PlayerInfoEntity")
		for i, Ent in ientitylist( playersinfo ) do
			if Ent.teamNumber == 1 then
				if Ent.playerSkill ~= nil and Ent.playerSkill ~= -1 then -- Ignore bots and players without skill to get a more accurate avg
					CURRENTMARINETEAMSKILL  = CURRENTMARINETEAMSKILL + Ent.playerSkill
					MarineCount = MarineCount + 1
				end
			end

			if Ent.teamNumber == 2 then
				if Ent.playerSkill ~= nil and Ent.playerSkill ~= -1 then -- Ignore bots and players without skill
					CURRENTALIENTEAMSKILL = CURRENTALIENTEAMSKILL + Ent.playerSkill
					AlienCount = AlienCount + 1
				end
			end
		end

		-- Figure out averages for both teams and "TeamSkillAVGGap"
		if MarineCount > 0 then
			MarineTeamSkillAVG = CURRENTMARINETEAMSKILL / MarineCount
		end

		if AlienCount > 0 then
			AlienTeamSkillAVG = CURRENTALIENTEAMSKILL / AlienCount
		end

		TeamSkillAVGGap = math.abs(MarineTeamSkillAVG - AlienTeamSkillAVG )

		-- loop through lists to see if anyone can switch
		for MARINEID, MARINESKILL in pairs(MarineList) do

			for ALIENID, ALIENSKILL in pairs(AlienList) do
			-- goal is to allow a switch if it reduces TeamSkillAVGGap

				if math.abs( ( ( CURRENTALIENTEAMSKILL - ALIENSKILL + MARINESKILL ) / AlienCount ) - ( ( CURRENTMARINETEAMSKILL - MARINESKILL + ALIENSKILL ) / MarineCount ) ) <= TeamSkillAVGGap then
					local MClient = Shine.GetClientByNS2ID( MARINEID )
					local AClient = Shine.GetClientByNS2ID( ALIENID )

          if MClient or AClient == nil then --reset and skip becase of fail when identifying player
            if AClient == nil then
	             AlienList[ALIENID]= nil
            end

            if MClient == nil then
              MarineList[MARINEID] = nil
            end
          else

            local SwitchingFromMarinePlayer = MClient:GetControllingPlayer()
  					local SwitchingFromAlienPlayer = AClient:GetControllingPlayer()

            --one last check that players exist on expected teams
            if SwitchingFromMarinePlayer:GetTeamNumber() == 1 and SwitchingFromAlienPlayer:GetTeamNumber() == 2 then
              GetGamerules():JoinTeam( SwitchingFromAlienPlayer, 1, true )
              GetGamerules():JoinTeam( SwitchingFromMarinePlayer, 2, true )
              MarineList[MARINEID] = nil
      			  AlienList[ALIENID]= nil

    					Plugin:SendTranslatedNotify( nil, "SWITCHINGPLAYERS", {
    	    			SwitchName_1 = SwitchingFromMarinePlayer:GetName(),
    						SwitchName_2 = SwitchingFromAlienPlayer:GetName()
    					} )

            else
                  -- clean up whater failed
                  if SwitchingFromMarinePlayer:GetTeamNumber() ~= 1 then
                    MarineList[MARINEID] = nil
                  end

                  if SwitchingFromAlienPlayer:GetTeamNumber() ~= 2 then
                    AlienList[ALIENID]= nil
                  end
            end

            breakflag = true -- Flag to force break out of outer (MarineList) loop -  is time is a flat circle?
  					break
          end
        end
			end

      if breakflag == true then
				 break -- Break out of outer (MarineList) loop because switch happened and time is a flat circle.
			end
		end
	end
end


function Plugin:PostJoinTeam( Gamerules, Player, OldTeam, NewTeam, Force, ShineForce )

  if SwitchActiveState == true then

		local Client = Player:GetClient()
		local SteamIDKEY = Client:GetUserId()

		if MarineList[SteamIDKEY] then
			MarineList[SteamIDKEY] = nil
      Plugin:NotifyTranslated(Client, "FORGETMESSAGE")
		end

		if AlienList[SteamIDKEY] then
			AlienList[SteamIDKEY]= nil
      Plugin:NotifyTranslated(Client, "FORGETMESSAGE")
		end

		checkforswitch()
	end
end




function Plugin:ClientDisconnect( Client )

	if SwitchActiveState == true then

    local SteamIDKEY = Client:GetUserId()

		if MarineList[SteamIDKEY] then
			MarineList[SteamIDKEY] = nil
		end

		if AlienList[SteamIDKEY] then
			AlienList[SteamIDKEY]= nil
		end

		checkforswitch()
	end
end


function Plugin:CheckGameStart( Gamerules )

	local GameState = Gamerules:GetGameState()

  if GameState == kGameState.Started and SwitchActiveState == false then return end

  if GameState ~= kGameState.Started and SwitchActiveState == false then
		SwitchActiveState = true
	end

	if GameState == kGameState.Started and SwitchActiveState == true then
		for k, v in pairs( MarineList ) do
		  MarineList[k] = nil
		end

  	for k, v in pairs( AlienList ) do
  		AlienList[k] = nil
		end

  	SwitchActiveState = false
	end
end


function teamgapmonitor()

  if SwitchActiveState ~= true then return end

  local Marines = Shine.GetTeamClients( 1 )
  local Aliens = Shine.GetTeamClients( 2 )
  local MarineTeamCount = 0
  local AlienTeamCount = 0

  for i = 1, #Marines do --
    MarineTeamCount = MarineTeamCount + 1
  end

  for i = 1, #Aliens do
    AlienTeamCount = AlienTeamCount + 1
  end

  if math.abs( MarineTeamCount - AlienTeamCount) >= teamgaplimit then
    -- first count how many players currently in each switch list team table
  	local LastMarineKey
    local LastAlienKey
  	local MarineListCount = 0
  	local AlienListCount = 0

  	for k, v in pairs(MarineList) do
  		MarineListCount = MarineListCount + 1
  		LastMarineKey = k -- Store the last valid Marine key
  	end

  	for k, v in pairs(AlienList) do
  	 	AlienListCount = AlienListCount + 1
  		LastAlienKey = k -- Store the last valid Alien key
  	end

    if (AlienTeamCount - MarineTeamCount ) >= teamgaplimit then
      if AlienListCount > 0 then -- skip if no Alien asked to switch

				local Client = Shine.GetClientByNS2ID( LastAlienKey )
				local Player = Client:GetControllingPlayer()

        if Client == nil or Player:GetTeamNumber() ~= 2 then --reset and skip becase of fail when identifying player or is not on that team now
             AlienList[LastAlienKey]= nil

        else

          GetGamerules():JoinTeam( Player, 1, true )
          Plugin:SendTranslatedNotify( nil, "SWITCHPLAYER", {
            SwitchName = Player:GetName()
          } )
        end
      end
    end


    if ( MarineTeamCount - AlienTeamCount) >= teamgaplimit then
      if MarineListCount > 0 then -- skip if no Marine asked to switch

  			local Client = Shine.GetClientByNS2ID( LastMarineKey )
  			local Player = Client:GetControllingPlayer()

        if Client == nil or Player:GetTeamNumber() ~= 1 then --reset and skip becase of fail when identifying player or is not on that team now
             MarineList[LastMarineKey]= nil
        else
          GetGamerules():JoinTeam( Player, 2, true )
  		    Plugin:SendTranslatedNotify( nil, "SWITCHPLAYER", {
            SwitchName = Player:GetName(),
            } )
  			end
  		end
    end
  end

  checkforswitch()
end




function Plugin:CreateCommands()

  teamgaplimit = self.Config.teamgaplimit

  local SwitchCommand = self:BindCommand( "sh_switch", "switch", Switch, true )
		SwitchCommand:Help( "Switch Teams." )
end
