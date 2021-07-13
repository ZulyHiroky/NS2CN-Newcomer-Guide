local Plugin = Plugin
local Shine = Shine
local Hook = Shine.Hook
local Time = os.time
local AdvancedServerOptions = AdvancedServerOptions

Script.Load("lua/shine/extensions/tier_info/shared_net.lua")
Script.Load("lua/shine/extensions/tier_info/server_net.lua")
Script.Load("lua/shine/extensions/tier_info/server_utils.lua")
Script.Load("lua/shine/extensions/tier_info/server_stats.lua")

Plugin.HasConfig = true
Plugin.ConfigName = "TierInfo.json"
Plugin.PrintName = "TierInfo"

Plugin.DefaultConfig = {
  EnableEncryptedIps = true,
  EnableTeamAvgSkill = false,
  EnableTeamAvgSkillPregame = false,
  EnableScorePerHour = true,
  EnableAccuracy2 = true,
  EnableKillDeathRatio = true,
  EnableTierSkill = true,
  EnableTime = true,
  EnableTimeComm = true,
  EnableTimeTeam = true,
  EnableAntiSmurf = true,
  EnableCountry = true,
  EnableBanCount = true,
  EnableHiveBackupServer = true,
  EnableHiveBackupServerMessage = true,
  AntiSmurfSkillRange = 450,
  EnableNsl = ""
}

-- Defines
function Plugin:Initialise()
  -- Update changed config fields (add & remove fields)
  if self.TableKeyDiff(Plugin.DefaultConfig, self.Config) then -- Change to default config
    self.Config = self.TableBaseCopy(Plugin.DefaultConfig, self.Config);
		self:SaveConfig();
  end

  self.queryUrl = 'http://ns2.ocservers.com:4000/';
  
  AdvancedServerOptions["savestats"].currentValue = true; -- Force enable stats saving

  self:CreateHooks();
  self:CreateCommands();
  
  self.dt.EnableTeamAvgSkill = self.Config.EnableTeamAvgSkill or Plugin.DefaultConfig.EnableTeamAvgSkill;
  self.dt.EnableTeamAvgSkillPregame = self.Config.EnableTeamAvgSkillPregame or Plugin.DefaultConfig.EnableTeamAvgSkillPregame;
  self.dt.EnableTierSkill = self.Config.EnableTierSkill or Plugin.DefaultConfig.EnableTierSkill;
  self.dt.EnableNsl = (self.Config.EnableNsl and self.Config.EnableNsl ~= "") and true or false;

  self.QueueIndex = {};
  
  self.lastBanCount = 0;
  self.lastServerName = '';

  self:InitReplace();

  self.Enabled = true;
	return true;
end

function Plugin:InitReplace()
  self:InitReplaceStats()
end

function Plugin:CreateHooks()
  -- Game Countdown
  local first = true;
  Shine.Hook.Add("UpdatePregame", "TierInfo_UpdatePregame", function(gamerules, timePassed)
    if (first and gamerules:GetGameState() == kGameState.Countdown) then
      self:Query(true);
      
      first = false;
    end
  end);
  
  function Plugin:OnEndGame( gamerules, winningTeam )
    first = true;
    
    local Gamemode = Shine.GetGamemode()
    if Gamemode ~= "ns2" and Gamemode ~= "mvm" then return; end

    Shine.Timer.Simple(5, function()
      local round = Plugin:GetOnEndGameStats(gamerules, winningTeam);
      -- table.Count(round.PlayerStats) >= 10
      if (round ~= nil and round.PlayerStats) then
        round.ServerInfo.nsl_pass = Plugin.Config.EnableNsl;

        self:Query(false, {
          round = round
        });
      end
    end);
  end

  Shine.Hook.SetupClassHook("NS2Gamerules", "EndGame", "OnEndGame", "PassivePost");

  function Plugin:ClientConnect( client )
    if (Shine:IsValidClient(client) and client:GetUserId() ~= 0) then
      if Shine:GetUserImmunity(client) > 0 or Shine:HasAccess(client, "sh_tierinfo") then
        Plugin.SendTierInfo_Perm(client, "sh_tierinfo");
      end
    
      if Shine.Plugins.ban and Shine.ExternalAPIHandler:HasAPIKey("Steam") then
        Shine.Plugins.ban:CheckFamilySharing(client:GetUserId(), false, function(result, sharer)
          if Shine:IsValidClient(client) then
            Plugin.familyInfo[client:GetId()] = result;
          end
        end)
      end
    end
  end
  
  -- Update tier info server and retrieve updated data (hive often fails to respond)
  Shine.Hook.Add("OnReceiveHiveData", "TierInfo_OnReceiveHiveData", function(client, data)
    if (not data) or (not Shine:IsValidClient(client)) then return end;
    
    self:RecHiveData(client, nil, data);
  end);
  
  Plugin.userId2ClientId = {};
  Shine.Hook.Add("ClientConnect", "TierInfo_ClientConnect", function(client)
    if (Shine:IsValidClient(client) and client:GetUserId() ~= 0) then
      Plugin.userId2ClientId[client:GetUserId()] = client:GetId();
    end
  end)
  
  Shine.Hook.Add("ClientConfirmConnect", "TierInfo_ClientConfirmConnect", function(client)
    if (Shine:IsValidClient(client)) then
      Plugin.SendTierInfo_Data(nil, true);
    
      --if (GetGamerules():GetGameState() == kGameState.Started) then
      self:Query(true, nil, nil);
      --end
    end
  end)

  Shine.Hook.Add("PostJoinTeam", "TierInfo_PostJoinTeam", function(Gamerules, Player, NewTeam, Force)
    --Shine.Timer.Simple(1, function()
      Plugin.SendTierInfo_TeamSkills()
    --end)
  end)
  
  local plugin = self;
  local RRQ = Shine.Plugins.readyroomqueue;
  if (RRQ) then
    local RRQDequeue = RRQ.Dequeue;
    function RRQ:Dequeue( client )
      if (RRQDequeue(self, client)) then
        for sid, index in self.PlayerQueue:Iterate() do
          local tempClient = Shine.GetClientByNS2ID(sid);
          if (tempClient) then
            plugin.QueueIndex[tostring(tempClient:GetId())] = index;
          end
        end
        
        plugin.QueueIndex[tostring(client:GetId())] = nil;
        
        plugin.dt.QueueIndex = json.encode(plugin.QueueIndex);
        plugin.dt.QueueIndexId = plugin.dt.QueueIndexId + 1;
        
        return true;
      end
      
      return false;
    end
    
    local RRQEnqueue = RRQ.Enqueue;
    function RRQ:Enqueue( client )
      RRQEnqueue(self, client);
      
      for sid, index in self.PlayerQueue:Iterate() do
        local tempClient = Shine.GetClientByNS2ID(sid);
        if (client == tempClient) then
          plugin.QueueIndex[tostring(client:GetId())] = index;
        end
      end
      
      plugin.dt.QueueIndex = json.encode(plugin.QueueIndex);
      plugin.dt.QueueIndexId = plugin.dt.QueueIndexId + 1;
    end
  end
end

function Plugin:CreateCommands()
  local function fLastRound(client)
    local params = { port = Server.GetPort() };
    Shared.SendHTTPRequest( "http://ns2panel.ocservers.com:4000/getLastRound", "POST", params, 
      function(data)
        data = json.decode(data);
        if (data.result) then
          Plugin.SendTierInfo_LastRound(client, data.result.id);
        end
      end
    )
  end
  local cLastRound = self:BindCommand("sh_lastround", "lastround", fLastRound);
  cLastRound:Help("Display last round stats from https://ns2panel.ocservers.com");
  
  --[[self.muteAll = false;
  local function cToggleMuteAll(client, muteCommander)
    Plugin.muteAll = (not self.muteAll);
    Plugin.muteCommander = muteCommander or false;
  end
  self:BindCommand("sh_muteall", "muteall", cToggleMuteAll)
    :AddParam{Type = "Boolean"}
    :Help("Mutes all (excl commander), during a round")--]]
end

function Plugin:RecHiveData(client, data, hive)
  local result = 0;

  if (data) then
    hive = data; -- Accepts input directly hive or from the TI server
  
    client._sph_marine = data.sph_marine;
    client._sph_alien = data.sph_alien;
    client._accuracy_marine = data.accuracy_marine;
    client._accuracy_alien = data.accuracy_alien;
    client._kdr_marine = data.kdr_marine;
    client._kdr_alien = data.kdr_alien;
  end
  
  if (not hive) or (not hive.time_played) then return result; end;

  Plugin.SetClientDataLevel(client, 1);
  
  local sid = client:GetUserId();

  client._time_played = (hive.time_played / 60 / 60);
  client._commander_time = (hive.commander_time / 60 / 60);
  client._marine_playtime = (hive.marine_playtime / 60 / 60);
  client._alien_playtime = (hive.alien_playtime / 60 / 60);
  client._sph = (data) and data.sph or math.floor(hive.score / client._time_played);
  client._adagrad_sum = hive.adagrad_sum;
  client._skill = hive.skill;
  client._score = hive.score;
  client._skill_offset = hive.skill_offset;
  client._comm_skill = hive.comm_skill;
  client._comm_skill_offset = hive.comm_skill_offset;
  client._comm_adagrad_sum = hive.comm_adagrad_sum;

  -- Hive backup
  local player = client:GetPlayer();

  if (hive.backup and player and player.GetPlayerSkill and player:GetPlayerSkill() == -1 and self.Config.EnableHiveBackupServer) then
    player.totalScore = hive.score or 0; -- Vanilla varname inconsistency
    player.commanderTime = hive.commander_time or 0;
    player.marineTime = hive.marine_playtime or 0;
    player.alienTime = hive.alien_playtime or 0;

    player.playTime = hive.time_played or 0;

    player.skill = hive.skill or -1;
    player.skillOffset = hive.skill_offset or -1;
    player.commSkill = hive.comm_skill or -1;
    player.commSkillOffset = hive.comm_skill_offset or -1;
    player.adagradSum = hive.adagrad_sum or 0;
    player.commAdagradSum = hive.comm_adagrad_sum or 0;
    player.playerLevel = hive.level or -1;
    player.totalXP = hive.xp or -1;
    
    result = 1;
  end

  return result;
end

function Plugin:RecIpData(client, data)
  if (data.country) then
    client._country = data.country;
  end
  
  if (data.vpn) then
    client._vpn = data.vpn;
  end
end

function Plugin:RecSmurfData(client, data)
  if (not data.smurfs) or (not data.smurfs) then return end;

  if Plugin.Config["EnableAntiSmurf"] then
    client._smurfs = {};
    for steam_id, v in pairs(data.smurfs) do
      -- steam_id ~= client:GetUserId() and 
      -- if data.smurf  
        table.insert(client._smurfs, v);
      -- end
    end
  end
end

function Plugin:RecQuery(data)
  -- Players
  if (data and data.players) then
    local count = 0;
    local backup = 0;
    for sid, playerData in pairs(data.players) do
      local clientId = Plugin.userId2ClientId[tonumber(sid)];
      if (clientId) then
        local client = Server.GetClientById(clientId);
        if (Shine:IsValidClient(client)) then
          local playerData = data.players[sid];
          if (playerData) then
            -- Hive
            backup = backup + Plugin:RecHiveData(client, playerData);
            
            -- IP
            Plugin:RecIpData(client, playerData);
            
            -- Smurf
            Plugin:RecSmurfData(client, playerData);
            
            -- Bans
            if (playerData.bans) then
              client._bans = playerData.bans;
            end
            
            -- Other data
            Plugin.SetClientDataLevel(client, 2);
            
            client._isAdmin = playerData.isAdmin;
            
            count = count + 1;
          end
        end
      end
      
      --[[if (backup > 0 and self.Config.EnableHiveBackupServerMessage) then
        local msg = string.format('Hive backup activated for %i player(s).', backup);
        Print(string.format('Tier Info: %s', msg));
        -- Shine:NotifyDualColour(nil, 0, 255, 0, '[Tier Info] ',	255, 255, 255, msg);
      end--]]
    end
    
    if (count > 0) then
      Plugin.SendTierInfo_Data(nil, false);
    end
  end
end

function Plugin:Query(fetch, base, onSuccess, onFail)
  local request = base or {};
  request.fetch = fetch;
  request.bans = self:GetSendBans();
  
  request.sport = Server.GetPort();
  request.sname = Server.GetName();
  
  if (fetch) then
    --[[if (Server.GetName() ~= self.lastServerName) then
      request.sname = Server.GetName();
      self.lastServerName = Server.GetName();
    end--]]

    local players, count = self:GetSendPlayers();
    if (Plugin.Config.EnableEncryptedIps or Plugin.Config.EnableEncryptionIps) then
      request._players = self.Encrypt(players);
    else
      request.players = players;
    end
    
    if (count == 0) then return; end
  end

  Shared.SendHTTPRequest(self.queryUrl .. "update", "POST", { data = json.encode(request) }, function(raw)
    local data = json.decode(raw, 1, nil);
    
    if (data and data.success) then
      self:RecQuery(data);
      if (onSuccess) then onSuccess(data); end
    else
      if (onFail) then onFail(data); end
    end
  end)
end

function Plugin.HasHive(client)
  return (Plugin.GetClientDataLevel(client) > 0);
end

function Plugin:GetSendPlayers()
  local players = '';
  
  local count = 0;
  for client in Shine.IterateClients() do
    local sid = client:GetUserId();
    if (sid > 0 and Plugin.GetClientDataLevel(client) < 2 and client._sent == nil) then
      local ip = Server.GetClientAddress(client);
      local dataLevel = Plugin.GetClientDataLevel(client);

      client._sent = os.time();
    
      players = players .. '[' .. sid .. ',' .. ip .. ',' .. dataLevel .. '],';
      count = count + 1;
    end
  end

  return '[' .. players .. ']', count;
end

function Plugin:GetSendBans()
  local Ban = Shine.Plugins.ban;
  if (not Ban) or (not Ban.Config) then return end

  if (not self.Config.EnableBanCount) then return 'clear'; end -- Deletes bandata from remote server

  local banCount = table.Count(Ban.Config.Banned);
  if (banCount == self.lastBanCount) then return; end;
  self.lastBanCount = banCount;
  
  local bans = '';
  for sid, banData in pairs(Ban.Config.Banned) do
    if (banData.Reason ~= 'banned by VoteKick') then
      local reason = string.lower(banData.Reason); -- To respect server owners privacy, we only check for keywords (troll, smurf, etc)
      local isTemp = (banData['UnbanTime'] ~= 0) and '1' or ''; -- Whether the user has an unban time
      local reasonId = '';
      
      -- Work out reason
      if (string.find(reason, 'trol')) then reasonId = '1'; end
      if (string.find(reason, 'smurf')) then reasonId = '2'; end
      if (string.find(reason, 'spam') or string.find(reason, 'mic')) then reasonId = '3'; end
      
      bans = bans .. string.format(',%s:%s:%s', sid, isTemp, reasonId);
    end
  end

  return bans;
end

function Plugin:SaveConfig()
  local Path = Server and Shine.Config.ExtensionDir..self.ConfigName or ClientConfigPath..self.ConfigName;
  local Success, Err = Shine.SaveJSONFile( self.Config, Path );
  if not Success then
    PrintToLog( "[Error] Error writing %s config file: %s", self.__Name, Err );
    return false;
  end
end

local dataLevels = {};
function Plugin.SetClientDataLevel(client, value)
  local uid = client:GetId();
  dataLevels[uid] = value;
end

function Plugin.GetClientDataLevel(client)
  local uid = client:GetId();
  return dataLevels[uid] or 0;
end

local sentLevels = {};
function Plugin.SetClientSentLevel(client, value)
  local uid = client:GetId();
  sentLevels[uid] = value;
end

function Plugin.GetClientSentLevel(client)
  local uid = client:GetId();
  return sentLevels[uid] or 0;
end

function Plugin.FormatCoordinates( coordsString )
    if type(coordsString) ~= "string" then return coordsString end
    local result = ""
    local coords = StringSplit(coordsString, " ")
    for i , coord in ipairs( coords ) do
        local decpointpos = string.find(coord, ".", 1, true) or #coord
        result = result .. string.sub(coord, 1, decpointpos+2)
        if i < 3 then
             result = result .. ","
        end
    end
    return result
end