local Plugin = Plugin

function Plugin.SendTierInfo_TeamSkills()
  if Shine.Plugins.voterandom then
    local voterandom = Shine.Plugins.voterandom;
    local teamStats = voterandom:GetTeamStats()
    
    Plugin.dt.marine_skill = teamStats[1].Average;
    Plugin.dt.alien_skill = teamStats[2].Average;
  end
end

function Plugin.SendTierInfo_Perm(client, perm)
  Server.SendNetworkMessage(client, Plugin.kMsgPermName, {perm = perm}, true)
end

function Plugin.GenTierInfo_Data_Client(client)
  --local player = client:GetPlayer();
  local result = ''; 
  local smurfs = '';
  
  -- Smurf
  if client._smurfs and table.getn(client._smurfs) > 0 then
    local firstSmurf = true;
    for _, smurf in ipairs(client._smurfs) do
      if (not firstSmurf) then
        smurfs = smurfs .. ';';
      else
        firstSmurf = false;
      end
      
      if (not smurf.skill) and (smurf.skill == nil) then
        Print('Error: Tier Info Debug: ' .. tostring(client:GetId()))
      else
        smurfs = string.format('%s%s:%i:%i:%i:%i:%i', smurfs,
          string.ToBase64(smurf.alias),
          smurf.skill,
          smurf.sph,
          smurf.bans,
          smurf.sph_marine or 0,
          smurf.sph_alien or 0
        );
      end
    end 
  end
  

  -- Client data
  if (client._time_played ~= 0) then -- Has data
    result = string.format('%s%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%s,%i,%s,%i,%.2f,%.2f,%.2f,%.2f,%i', result,
      client:GetId(),
      (Plugin.Config.EnableTime) and client._time_played or 0,
      (Plugin.Config.EnableTimeComm) and client._commander_time or 0,
      (Plugin.Config.EnableTimeTeam) and client._marine_playtime or 0,
      (Plugin.Config.EnableTimeTeam) and client._alien_playtime or 0,
      (Plugin.familyInfo[client:GetId()]) and 1 or 0,
      (Plugin.Config.EnableScorePerHour) and client._sph or 0,
      (Plugin.Config.EnableScorePerHour) and client._sph_marine or 0,
      (Plugin.Config.EnableScorePerHour) and client._sph_alien or 0,
      client._skill_offset or 0,
      client._comm_skill or 0,
      client._comm_skill_offset or 0,
      client._comm_adagrad_sum or 0,
      client._country or ' ',
      client._bans or 0,
      (smurfs ~= '') and smurfs or ' ',
      client._vpn or 0,
      (Plugin.Config.EnableAccuracy2) and client._accuracy_marine or 0,
      (Plugin.Config.EnableAccuracy2) and client._accuracy_alien or 0,
      (Plugin.Config.EnableKillDeathRatio) and client._kdr_marine or 0,
      (Plugin.Config.EnableKillDeathRatio) and client._kdr_alien or 0,
      client._isAdmin and 1 or 0
    );
  end

  return result;
end

function Plugin.SendTierInfo_Data(to, force)
  local message = {p = ''};
  
  local firstClient = true;
  for client in Shine.IterateClients() do
    local sid = client:GetUserId(); -- Steamid
    
    if (sid ~= 0) and (force or Plugin.GetClientSentLevel(client) < Plugin.GetClientDataLevel(client)) then
      if (not firstClient) then
        message.p = message.p .. '|';
      else
        firstClient = false;
      end
      
      message.p = message.p .. Plugin.GenTierInfo_Data_Client(client);
      Plugin.SetClientSentLevel(client, Plugin.GetClientDataLevel(client));
    end
  end

  if (to) then
    Server.SendNetworkMessage(to, Plugin.kMsgDataName, message, true)
  else
    Server.SendNetworkMessage(Plugin.kMsgDataName, message, true)
  end
end

function Plugin.SendTierInfo_LastRound(client, round_id)
  Shine.SendNetworkMessage(Client, Plugin.kMsgLastRoundName, {
    round_id = round_id
  }, true)
end
---- End Server -----
