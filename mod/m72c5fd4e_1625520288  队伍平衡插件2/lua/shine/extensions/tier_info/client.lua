local Shine = Shine
local Plugin = Plugin

Script.Load("lua/shine/extensions/tier_info/client_utils.lua")
Script.Load("lua/shine/extensions/tier_info/shared_net.lua")
Script.Load("lua/shine/extensions/tier_info/client_net.lua")

local hideTextShadowIds = {19849485, 68118554};

function Plugin:Initialise()
  self.QueueIndexIdLast = 0;
  self.QueueIndex = {};
  self:InitReplace();
  self:CreateCommands();
  
  self.hideTextShadow = table.contains(hideTextShadowIds, Client.GetSteamId());

  self.Enabled = true;
  return true;
end

-- Open webpage with steam overlay fallback
local function openUrl(url, title)
  if (not Shine.Config.DisableWebWindows) then
    Shine:OpenWebpage(url, title);
  else
    Client.ShowWebpage(url);
  end
end

local function openUrlNs2Panel(steam_id)
  openUrl(string.format('https://ns2panel.ocservers.com/%s/%s', 'player', steam_id), 'Tier Info - NS2 Panel');
end

local function openUrlObservatory(steam_id)
  openUrl(string.format('https://observatory.morrolan.ch/player?steam_id=%s', steam_id), 'Observatory');
end

local function openUrlNs2PanelRound(round_id)
  openUrl(string.format('https://ns2panel.ocservers.com/round/%s', round_id), 'Tier Info - NS2 Panel');
end

function Plugin:CreateCommands()
  local function fLastRound(round_id)
    openUrlNs2PanelRound(round_id);
  end
  local cLastRound = self:BindCommand("cl_lastround", fLastRound)
  cLastRound:AddParam{ Type = "string", Help = "round_id" }
end

function Plugin:Cleanup()
  self.BaseClass.Cleanup(self);
end

function Plugin:InitReplace()
  Plugin._GUIScoreboardUpdateTeam = Shine.ReplaceClassMethod("GUIScoreboard", "UpdateTeam", self.GUIScoreboardUpdateTeam);
  
  if table.contains(hideTextShadowIds, Client.GetSteamId()) then
    -- Fix linux performance - test
    Plugin._GUIItemSetDropShadowEnabled = Shine.ReplaceClassMethod("GUIItem", "SetDropShadowEnabled", function(self, value) end);
    Plugin._FireMixinUpdateFireMaterial = Shine.ReplaceClassMethod("FireMixin", "UpdateFireMaterial", function() end);
  end
  
  Plugin.oldGUIScoreboardSendKeyEvent = Shine.ReplaceClassMethod("GUIScoreboard", "SendKeyEvent", Plugin.GUIScoreboardSendKeyEvent);
end

Plugin.GUIScoreboardUpdateTeam = function(scoreboard, updateTeam)
  Plugin._GUIScoreboardUpdateTeam(scoreboard, updateTeam)
  
  if (Plugin.QueueIndexIdLast ~= Plugin.dt.QueueIndexId) then
    Plugin.QueueIndex = json.decode(Plugin.dt.QueueIndex);
    Plugin.QueueIndexIdLast = Plugin.dt.QueueIndexId;
  end
  
  local playerList = updateTeam["PlayerList"]
  local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]
  local teamSkillGUIItem = updateTeam["GUIs"]["TeamSkill"]
  local teamScores = updateTeam["GetScores"]()
  --local numPlayers = 0--table.icount(teamScores)
  local currentPlayerIndex = 1

  --local totalSkill = 0
  local isSpectator, isMarine, isAlien = updateTeam.TeamNumber == 0, updateTeam.TeamNumber == 1, updateTeam.TeamNumber == 2;
  
  -- Update team rows
  for index, player in ipairs(playerList) do
    local playerRecord = teamScores[currentPlayerIndex]
    if playerRecord == nil then return end
    
    local playerName = playerRecord.Name
    local adagradSum = playerRecord.AdagradSum
    local baseSkill = playerRecord.Skill
    local playerTierSkill = Plugin.CalcPlayerSkill(baseSkill, adagradSum)
    local clientIndex = playerRecord.ClientIndex

    local playerData = Plugin.player[tostring(clientIndex)];
    local marineSkill, alienSkill = Plugin.GetTeamSkills(baseSkill, playerData and playerData.skill_offset or 0);
    local playerSkill = (isMarine and marineSkill) or (isAlien and alienSkill) or 0
    local isCommander = playerData and playerData.IsCommander or false;

    --[[if (baseSkill ~= -1) then -- Only count actual players, not bots
      numPlayers = numPlayers + 1;
      totalSkill = totalSkill + playerSkill;
    end--]]

    -- Insert into the badge hover action
    if not scoreboard.hoverMenu.background:GetIsVisible() and not MainMenu_GetIsOpened() then
      if MouseTracker_GetIsVisible() then
        local mouseX, mouseY = Client.GetCursorPosScreen()
        local skillIcon = player.SkillIcon
        if skillIcon:GetIsVisible() and GUIItemContainsPoint(skillIcon, mouseX, mouseY) then
          local _, badgeNames = Badges_GetBadgeTextures(clientIndex, "scoreboard")
          local nextSkill = Plugin.GetPlayerSkillNextSkill(playerTierSkill)
          
          if skillIcon.tooltipText == "Skill Tier: Bot (-1)" then
            scoreboard.badgeNameTooltip:SetText("Bot")
          else
            -- Info
            local description = skillIcon.tooltipText:gsub("Skill Tier:", "Tier:")
            description = string.gsub(description, " %(Team", "\n(Team") -- Place competitive team on a new line, for improved readability

            if playerData ~= nil and playerData.skill_offset ~= nil then
              local marineCommSkill, alienCommSkill = Plugin.GetTeamSkills(playerData.comm_skill, playerData.comm_skill_offset);

              -- Display team skills
              if marineSkill == alienSkill then
                description = description .. string.format("\nSkill: %i", marineSkill)
              else
                if isSpectator or isMarine then
                  description = description .. string.format("\nMarine Skill: %i", marineSkill)
                end

                if isSpectator or isAlien then
                  description = description .. string.format("\nAlien Skill: %i", alienSkill)
                end
              end

              if Plugin.dt.EnableTierSkill and isSpectator then --Plugin:isAdmin() or 
                --description = description .. string.format("\nHive Skill: %i", playerSkill) -- Raw skill
                description = description .. string.format("\nTier Skill: %i", playerTierSkill) -- Tier skill
                
                if playerTierSkill < Plugin.Skill[table.count(Plugin.Skill)] then
                  description = description .. string.format("\nTier Next: %i", nextSkill) -- Next tier skill
                end
              end

              -- Display comm skills
              if marineCommSkill == alienCommSkill and (isSpectator or isCommander) then
                description = description .. string.format("\nComm Skill: %i", marineCommSkill)
              else
                if isSpectator then
                  description = description .. "\n"
                end

                if isSpectator or isMarine or isCommander then
                  description = description .. string.format("\nMarine Comm Skill: %i", marineCommSkill)
                end

                if isSpectator or isAlien or isCommander then
                  description = description .. string.format("\nAlien Comm Skill: %i", alienCommSkill)
                end
              end
            end

            if playerData ~= nil then
              -- Fix missing data
              playerData.kdr_marine = playerData.kdr_marine or 0
              playerData.kdr_alien = playerData.kdr_alien or 0
              playerData.accuracy_marine = playerData.accuracy_marine or 0
              playerData.accuracy_alien = playerData.accuracy_alien or 0
              playerData.sph_marine = playerData.sph_marine or 0
              playerData.sph_alien = playerData.sph_alien or 0

              --
              if playerData.time_played > 0 then
                description = description .. string.format("\n\nPlay Time: %ih", playerData.time_played) -- Hive time
              end
                
              if playerData.time_played > 0 then
                description = description .. string.format("\nMarine Time: %ih", playerData.marine_playtime)
                description = description .. string.format("\nAlien Time: %ih", playerData.alien_playtime)
              end
              
              if playerData.commander_time > 0 then
                description = description .. string.format("\nComm Time: %ih", playerData.commander_time)
                --description = description .. string.format("\nComm Time: %ih [%.2f%%]", playerData.commander_time, (playerData.timeComm / playerData.timeHive) * 100)
              end
              
              if (Plugin.isAdmin() or Plugin.dt.EnableNsl) then
                if (playerData.sph_marine > 0 and playerData.sph_alien > 0) then
                  description = description .. string.format("\n\nScore Per Hour: M %i A %i", playerData.sph_marine, playerData.sph_alien)
                else
                  if (playerData.sph > 0) then
                    description = description .. string.format("\n\nScore Per Hour: %i", playerData.sph)
                  end
                end
              end

              --if (Plugin.isAdmin() or Plugin.dt.EnableNsl) then
                if (playerData.kdr_marine > 0 or playerData.kdr_alien > 0) then
                  description = description .. string.format("\nKill Death Ratio: M %.2f A %.2f", playerData.kdr_marine, playerData.kdr_alien)
                end
  
                if (playerData.accuracy_marine > 0 or playerData.accuracy_alien > 0) then
                  description = description .. string.format("\nAccuracy: M %.2f%% A %.2f%%", playerData.accuracy_marine, playerData.accuracy_alien)
                end
              --end

              if playerData.country and playerData.country ~= ' ' then
                description = description .. string.format("\n\nNat: %s", playerData.country)
              end

              if (clientIndex ~= Client.GetLocalClientIndex() and Plugin.isAdmin()) and (not Plugin.dt.EnableNsl) then --clientIndex ~= Client.GetLocalClientIndex() or 
                if playerData.familyInfo and playerData.familyInfo > 0 then                         
                  description = description .. string.format("\nFamily Sharing: %s", Plugin.familyInfo[clientIndex] and "Yes" or "No") -- Family sharing status (needs testing)
                end
                
                if playerData.vpn and playerData.vpn == 1 then
                  description = description .. string.format("\nVPN: %s", 'Likely')
                end
                
                if playerData.bans and playerData.bans ~= 0 then
                  description = description .. string.format("\nBans: %i", playerData.bans)
                end
                
                local smurfs = playerData.smurfs;
                if smurfs then
                  for _, smurf in ipairs(smurfs) do
                    if (smurf.skill) then -- and (smurf.skill > playerTierSkill or smurf.bans > 0)
                      if (_ == 1) then
                        description = description .. "\n\nAccounts:"
                      end

                      local insertSph = string.format("%s", smurf.sph);
                      if (smurf.sph_marine ~= 0 or smurf.sph_alien ~= 0) then
                        insertSph = string.format("M %s A %s", smurf.sph_marine, smurf.sph_alien);
                      end
                    
                      description = description .. string.format("\n  %s | Skill: %s | SPH: %s", smurf.alias, smurf.skill, insertSph);
                      
                      if (smurf.bans > 0) then
                        description = description .. string.format(" | Bans: %s", smurf.bans);
                      end
                    end
                  end
                end
              end
            end
            
            local queueIndex = Plugin.QueueIndex[tostring(clientIndex)];
            if (queueIndex) then
              description = description .. string.format("\nQueue: %i", queueIndex);
            end
            
            scoreboard.badgeNameTooltip:SetText(description)
          end
        end
      end
    end
    
    currentPlayerIndex = currentPlayerIndex + 1
  end
  
  -- Update team skill header
  if (Plugin.dt.EnableTeamAvgSkill or (Plugin.dt.EnableTeamAvgSkillPregame and (not GetGameInfoEntity():GetGameStarted()))) and (not Plugin.dt.EnableNsl) then -- Display when enabled in pregame or during if configured as such
    if updateTeam.TeamNumber >= 1 and updateTeam.TeamNumber <= 2 then --and numPlayers > 0 then -- Display for only aliens or marines
      local skillAverage = (updateTeam.TeamNumber == 1) and Plugin.dt.marine_skill or Plugin.dt.alien_skill

      --local teamAvgSkill = totalSkill / numPlayers
      local teamHeaderText = teamNameGUIItem:GetText()
      teamHeaderText = string.sub(teamHeaderText, 1, string.len(teamHeaderText) - 1)
      teamHeaderText = teamHeaderText .. string.format(", %i Avg Skill)", skillAverage)

      teamNameGUIItem:SetText( teamHeaderText )
      
      teamSkillGUIItem:SetPosition(Vector(teamNameGUIItem:GetTextWidth(teamNameGUIItem:GetText()) + 20, 5, 0) * GUIScoreboard.kScalingFactor)
    end
  end
end

-- Add mute all button
function Plugin.GUIScoreboardSendKeyEvent(self, key, down)
  Plugin._GUIScoreboard = self
  local _backgroundGetIsVisible = self.hoverMenu.background:GetIsVisible()
  local result = Plugin.oldGUIScoreboardSendKeyEvent(self, key, down)
  
  if ChatUI_EnteringChatMessage() then
    return false
  end
  
  if not self.visible then
    return false
  end

  if key == InputKey.MouseButton0 then -- and self.mousePressed["LMB"]["Down"] ~= down and down and not MainMenu_GetIsOpened() 
    --local steamId = GetSteamIdForClientIndex(self.hoverPlayerClientIndex)
    if _backgroundGetIsVisible then
        return false
    elseif true then --steamId ~= 0 or self.hoverPlayerClientIndex ~= 0 and Shared.GetDevMode()
      local isVoiceMuted = ChatUI_GetClientMuted(self.hoverPlayerClientIndex)
      
      local teamColorBg
      local teamColorHighlight
      local playerName = Scoreboard_GetPlayerData(self.hoverPlayerClientIndex, "Name")
      local teamNumber = Scoreboard_GetPlayerData(self.hoverPlayerClientIndex, "EntityTeamNumber")
      local isCommander = Scoreboard_GetPlayerData(self.hoverPlayerClientIndex, "IsCommander")-- and GetIsVisibleTeam(teamNumber)
      
      local textColor = Color(1, 1, 1, 1)
      
      if isCommander then
          teamColorBg = GUIScoreboard.kCommanderFontColor
      elseif teamNumber == 1 then
          teamColorBg = GUIScoreboard.kBlueColor
      elseif teamNumber == 2 then
          teamColorBg = GUIScoreboard.kRedColor
      else
          teamColorBg = GUIScoreboard.kSpectatorColor
      end
      
      teamColorHighlight = teamColorBg * 0.75
      teamColorBg = teamColorBg * 0.5
      
      local steamId = GetSteamIdForClientIndex(self.hoverPlayerClientIndex)
      self.hoverMenu:AddButton('Observatory profile', teamColorBg, teamColorHighlight, textColor, function()
        openUrlObservatory(steamId);
      end);
      
      self.hoverMenu:AddButton('NS2 Panel profile', teamColorBg, teamColorHighlight, textColor, function()
        openUrlNs2Panel(steamId);
      end);
    end
  end
      
  return false;
end
