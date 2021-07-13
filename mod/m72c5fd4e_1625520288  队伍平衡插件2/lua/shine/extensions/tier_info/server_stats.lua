-- This script is modelled from eBrute's wonitor script, for stats gathering. All credits go to him.
-- https://github.com/eBrute/wonitor-mod/blob/master/source/lua/shine/extensions/wonitor/server.lua

local Plugin = Plugin;

local function BoolToInt( bool )
  if bool then
    return 1
  else
    return 0
  end
end

local function Round(num, n)
  local mult = 10^(n or 0)
  return math.floor(num * mult + 0.5) / mult
end

function generate_key_list(t)
  local keys = {}
  for k, v in pairs(t) do
    keys[#keys+1] = k
  end
  return keys
end

function Plugin:StatsUI_MaybeInitClientStats(steamId, wTechId, teamNumber)
  if steamId > 0 and (teamNumber == 1 or teamNumber == 2) then
    if not STATS_ClientStats[steamId] then
      STATS_ClientStats[steamId].hiveAdagradSum = -1
      STATS_ClientStats[steamId].hiveCommAdagradSum = -1
    end
  end
end

function Plugin:StatsUI_SetBaseClientStatsInfo(steamId, playerName, playerSkill, isRookie)
  local stat = StatsUI_GetStatForClient(steamId)

  if stat then
    stat.hiveAdagradSum = hiveAdagradSum
    stat.hiveCommAdagradSum = hiveCommAdagradSum
  end
end

function Plugin:GetOnEndGameStats( Gamerules, WinningTeam )
  if not CHUDGetLastRoundStats or Shared.GetCheatsEnabled() or not Shine then
    return nil;
  end -- NS2+ mod not loaded

  -- Print(Plugin.Dump(generate_key_list(Shine.Plugins.wonitor)))

  local NS2PlusStats = CHUDGetLastRoundStats();
  if (next(NS2PlusStats) == nil) then
    return nil;
  end

  local data = {}
  data.RoundInfo       = NS2PlusStats.RoundInfo
  data.Locations       = NS2PlusStats.Locations
  data.MarineCommStats = NS2PlusStats.MarineCommStats
  data.ServerInfo      = NS2PlusStats.ServerInfo
  data.PlayerStats     = NS2PlusStats.PlayerStats
  local KillFeed       = NS2PlusStats.KillFeed

  data.KillFeed = {}
  if type(NS2PlusStats.KillFeed) == "table" then
    for _ , killEvent in ipairs( NS2PlusStats.KillFeed ) do
      -- compress the data for transmission
      table.insert(data.KillFeed, {
        killEvent.victimClass,
        killEvent.victimSteamID,
        killEvent.killerWeapon,
        killEvent.killerTeamNumber,
        killEvent.killerClass,
        killEvent.killerSteamID,
        math.round(killEvent.gameTime),
        Plugin.FormatCoordinates(killEvent.victimPosition),
        Plugin.FormatCoordinates(killEvent.killerPosition),
        Plugin.FormatCoordinates(killEvent.doerPosition)
      })
    end
  end

  if (Shine.Plugins.wonitor == nil) or (not Shine.Plugins.wonitor.Enabled) then
    local function compressPlayerRoundStats(pStats)
      return {
        pStats.timePlayed,
        pStats.timeBuilding,
        pStats.commanderTime,
        pStats.kills,
        pStats.assists,
        pStats.deaths,
        pStats.killstreak,
        pStats.hits,
        pStats.onosHits,
        pStats.misses,
        pStats.playerDamage,
        pStats.structureDamage,
        pStats.score,
      }
    end

    local function compressPlayerClassStats(cStats)
      local status = {}
      for _ , classStat in ipairs( cStats ) do
        table.insert(status, {
          classStat.statusId,
          classStat.classTime,
        })
      end
      return status
    end

    local function compressPlayerWeaponStats(wStats)
      return {
        wStats.teamNumber,
        wStats.hits,
        wStats.onosHits,
        wStats.misses,
        wStats.playerDamage,
        wStats.structureDamage,
        wStats.kills,
      }
    end

    if type(data.PlayerStats == "table") then
      for _ , playerStat in pairs( data.PlayerStats ) do
        -- compress the data for transmission
        playerStat[1] = compressPlayerRoundStats(playerStat[1])
        playerStat[2] = compressPlayerRoundStats(playerStat[2])
        playerStat.status = compressPlayerClassStats(playerStat.status)

        for weapon , weaponStat in pairs( playerStat.weapons ) do
          playerStat.weapons[weapon] = compressPlayerWeaponStats(weaponStat)
        end
      end
    end
  end

  local Research = NS2PlusStats.Research
  data.Research = {}
  if type(Research == "table") then
    for _ , researchEvent in ipairs( Research ) do
      -- compress the data for transmission
      table.insert(data.Research, {
        Round(researchEvent.gameTime, 2),
        researchEvent.teamNumber,
        researchEvent.researchId,
      })
    end
  end

  local Buildings = NS2PlusStats.Buildings
  data.Buildings = {}
  if type(Buildings == "table") then
    for _ , buildingEvent in ipairs( Buildings ) do
      -- compress the data for transmission
      if buildingEvent.techId ~= "Cyst" then
        table.insert(data.Buildings, {
          Round(buildingEvent.gameTime, 2),
          buildingEvent.teamNumber,
          buildingEvent.techId,
          BoolToInt(buildingEvent.destroyed),
          BoolToInt(buildingEvent.built),
          BoolToInt(buildingEvent.recycled),
        })
      end
    end
  end

  return data;
end

--
function Plugin:InitReplaceStats()
--hivedebug
--[[
  Plugin._PlayerRankingEndGame = Shine.ReplaceClassMethod("PlayerRanking", "EndGame", self.PlayerRankingEndGame);
  Plugin._PlayerRankingLogPlayer = Shine.ReplaceClassMethod("PlayerRanking", "LogPlayer", self.PlayerRankingLogPlayer);
  Plugin._PlayerRankingInsertPlayerData = Shine.ReplaceClassMethod("PlayerRanking", "InsertPlayerData", self.PlayerRankingInsertPlayerData);
--]]
end

--
--hivedebug
--[[
local steamIdToClientIdMap = {}
function Plugin.PlayerRankingLogPlayer( self, player )
  if gRankingDisabled then
    return
  end

  if not self.capturedPlayerData then
    return
  end

  local client = player:GetClient()
  -- only consider players who are connected to the server and ignore any uncontrolled players / ragdolls
  if client then  --Includes Bots
    local steamId = client:GetUserId()

    if steamId > 0 then
      steamIdToClientIdMap[steamId] = client:GetId()
    end

    local playerData =
    {
      steamId = steamId,  --Note: Bots are determined by this value being 0
      nickname = player:GetName() or "",
      playTime = player:GetPlayTime(),
      marineTime = player:GetMarinePlayTime(),
      alienTime = player:GetAlienPlayTime(),
      commanderTime = player:GetCommanderTime(),
      teamNumber = player:GetTeamNumber(),
      kills = player:GetKills(),
      deaths = player:GetDeaths(),
      assists = player:GetAssistKills(),
      score = player:GetScore(),
      weightedTimeTeam1 = player:GetWeightedPlayTime( kTeam1Index ),
      weightedTimeTeam2 = player:GetWeightedPlayTime( kTeam2Index ),
      weightedTimeCommTeam1 = player:GetWeightedCommanderPlayTime( kTeam1Index ),
      weightedTimeCommTeam2 = player:GetWeightedCommanderPlayTime( kTeam2Index ),
      --
      playerSkill = player:GetPlayerSkill(),
      playerSkillOffset = player:GetPlayerSkillOffset(),
      playerSkillAdagradSum = player:GetAdagradSum(),
      commSkill = player:GetCommanderSkill(),
      commSkillOffset = player:GetCommanderSkillOffset(),
      commSkillAdagradSum = player:GetCommanderAdagradSum(),
    }

    table.insert( self.capturedPlayerData, playerData )
  end
end

function Plugin.PlayerRankingInsertPlayerData(self, playerTable, recordedData, winningTeam, gameTime, marineSkill, alienSkill, roundTimeWeighted)
  PROFILE("PlayerRanking:InsertPlayerData")

  -- Can't calculate isCommander or weightedTimeTeam values until the game is over, which is why this part is deferred
  local playerData =
  {
    steamId = recordedData.steamId, --Note: will be 0 for Bots
    nickname = recordedData.nickname or "",
    playTime = recordedData.playTime,
    marineTime = recordedData.marineTime,
    alienTime = recordedData.alienTime,
    teamNumber = recordedData.teamNumber,
    kills = recordedData.kills,
    deaths = recordedData.deaths,
    assists = recordedData.assists,
    score = recordedData.score or 0,
    commanderTime = recordedData.commanderTime,
    weightedTimeTeam1 = recordedData.weightedTimeTeam1 / roundTimeWeighted,
    weightedTimeTeam2 = recordedData.weightedTimeTeam2 / roundTimeWeighted,

    weightedTimeCommTeam1 = recordedData.weightedTimeCommTeam1 / roundTimeWeighted,
    weightedTimeCommTeam2 = recordedData.weightedTimeCommTeam2 / roundTimeWeighted,
    --
    playerSkill = recordedData.playerSkill,
    playerSkillOffset = recordedData.playerSkillOffset,
    playerSkillAdagradSum = recordedData.playerSkillAdagradSum,
    commSkill = recordedData.commSkill,
    commSkillOffset = recordedData.commSkillOffset,
    commSkillAdagradSum = recordedData.commSkillAdagradSum,
  }

  table.insert(playerTable, playerData)
end


--
local debug = false
local kMinMatchTime = 60    --TODO Move to global (or Engine def)
local kRoundRankingUrl = "http://hive2.ns2cdt.com/api/post/matchEnd"
function Plugin.PlayerRankingEndGame(self, winningTeam)
  if debug then
    gRankingDisabled = false
  end

  if gRankingDisabled then
    return
  end

  local roundLength = math.max(0, Shared.GetTime() - self.gameStartTime)

  if (self.gameStarted and ( self:GetTrackServer() or gDumpRoundStats ) and (roundLength >= kMinMatchTime or debug)) then
    local marineSkill, alienSkill = self:GetAveragePlayerSkill(kMarineTeamType), self:GetAveragePlayerSkill(kAlienTeamType)

    local gameEndTime = self:GetRelativeRoundTime()
    local aT = math.pow( 2, 1 / 40 )
    local sT = 1 -- start time is always 0 = math.pow( aT, self.gameStartTime * -1 )
    local eT = math.pow( aT, gameEndTime * -1 )
    self.roundTimeWeighted = sT - eT

    local LogPlayer = Closure [=[
      self this gameEndTime
      args player
      player:SetExitTime( player:GetTeamNumber(), gameEndTime )
      this:LogPlayer( player )
    ]=]{self, gameEndTime}

    GetGamerules():GetTeam1():ForEachPlayer(LogPlayer)
    GetGamerules():GetTeam2():ForEachPlayer(LogPlayer)
    GetGamerules():GetWorldTeam():ForEachPlayer(LogPlayer)
    GetGamerules():GetSpectatorTeam():ForEachPlayer(LogPlayer)

    -- dont send data of games lasting shorter than a minute. Those are most likely over because of players leaving the server / team.
    local gameInfo =
    {
      serverIp = Server.GetIpAddress(),
      dns = Server.GetConfigSetting("dyndns") or nil,
      port = Server.GetPort(),
      name = Server.GetName(),
      host_os = jit.os,
      mapName = Shared.GetMapName(),
      player_slots = Server.GetMaxPlayers(),
      build = Shared.GetBuildNumber(),
      tournamentMode = GetTournamentModeEnabled(),
      rookie_only = ( Server.GetConfigSetting("rookie_only") == true ),
      conceded = ( GetGamerules():GetTeam1():GetHasConceded() or GetGamerules():GetTeam2():GetHasConceded() ),
      gameMode = GetGamemode(),
      gameTime = roundLength,
      winner = winningTeam:GetTeamNumber(),
      marineTeamSkill = marineSkill or 0,
      alienTeamSkill = alienSkill or 0,
      numBots = GetGameInfoEntity():GetNumBots(),
      roundTimeWeighted = self.roundTimeWeighted,
      players = {}
    }

    for _, playerData in ipairs(self.capturedPlayerData) do
      self:InsertPlayerData(gameInfo.players, playerData, winningTeam, roundLength, marineSkill, alienSkill, self.roundTimeWeighted)
    end

    if gDumpRoundStats then
      Log("RoundEnd Data-----------------------------")
      Log("%s", gameInfo)
    end

    -- Shared.SendHTTPRequest( Plugin.queryUrl .. "post/matchEnd", "POST", { data = json.encode(gameInfo) }, function(data) end) --hivedebug

    if not gDumpRoundStats and (not debug) then
    --Only send when stats dumping NOT enabled

      Shared.SendHTTPRequest( kRoundRankingUrl, "POST", { data = json.encode(gameInfo) }, function(data)
        local obj = json.decode(data, 1, nil)

        --local newHive = {}

        if obj and obj.status == true then
          if obj.recorded then
            for _,v in ipairs(obj.players) do
              local steamId = v.steamid
              local pd = GetHiveDataBySteamId(steamId)
              --local pd = gPlayerData[steamId]

              if pd then
                pd.level = obj.level
                pd.xp = obj.xp
                pd.skill = obj.skill
                pd.skill_offset = obj.skill_offset
                pd.comm_skill = obj.comm_skill
                pd.comm_skill_offset = obj.comm_skill_offset
                pd.adagrad_sum = obj.adagrad_sum
                pd.comm_adagrad_sum = obj.comm_adagrad_sum

                local clientId = steamIdToClientIdMap[steamId]
                local client = clientId and Server.GetClientById(clientId)

                if client then
                  PlayerRanking_SetPlayerParams(client, pd)
                end

                --newHive[tostring(steamId)] = pd
              end
            end

            -- Pipe the data
            --gameInfo.newHive = newHive;
            --Shared.SendHTTPRequest( Plugin.queryUrl .. "post/matchEnd", "POST", { data = json.encode(gameInfo) }, function(data) end)
          end
        end
      end)
    end
  end

  self.roundTimeWeighted = 0
  self.gameStarted = false
end
--]]