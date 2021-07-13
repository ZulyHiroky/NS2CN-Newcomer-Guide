local Plugin = Plugin;

local Build = Shared.GetBuildNumber();
--322

-- Tier skill lookup
Plugin.Skill = { -- New
  [1] = 300,
  [2] = 750,
  [3] = 1400,
  [4] = 2100,
  [5] = 2900,
  [6] = 4100
};

-- Defines
function Plugin.CalcPlayerSkill(skill, adagradSum)
  if not skill or skill <= 0 then return 0 end

  if adagradSum then
    -- capping the skill values using sum of squared adagrad gradients
    -- This should stop the skill tier from changing too often for some players due to short term trends
    -- The used factor may need some further adjustments
    if adagradSum <= 0 then
      skill = 0
    else
      skill = math.max(skill - 25 / math.sqrt(adagradSum), 0)
    end
  end
  
  return skill
end

function Plugin.GetPlayerSkillNextSkill(skill)
  if not skill or skill < 1 then return Plugin.Skill[1] end

  if skill > Plugin.Skill[table.count(Plugin.Skill)] then return 0 end

  local lastValue = 0
  for i, value in ipairs(Plugin.Skill) do
    if skill > lastValue and skill <= value then
      return value
    end
    
    lastValue = value
  end
end

local admins = {19849485, 89160056, 77470693}; -- Test
function Plugin.isAdmin()
  local playerData = Plugin.player[tostring(Client.GetLocalClientIndex())];
  local isAdmin = playerData and playerData.isAdmin or 0;

  return (isAdmin > 0) or table.contains(admins, Client.GetSteamId()); -- Whether to display tier info stats -- string.find(Plugin.perm, "sh_tierinfo")
end