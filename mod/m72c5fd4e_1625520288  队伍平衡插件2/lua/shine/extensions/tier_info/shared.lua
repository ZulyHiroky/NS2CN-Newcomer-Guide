-- It is the job of shared.lua to create the plugin table.
local Plugin = {
  player = {},
  familyInfo = {},
  perm = ""
}

local Shine = Shine;
local InfoHub = Shine.PlayerInfoHub;
local Max = math.max;

-- Debug
function Plugin.Dump(o)
  if type(o) == 'table' then
    local s = '{ ';
    for k,v in pairs(o) do
      --if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '"'..k..'": ' .. Plugin.Dump(v) .. ',';
    end
    return s .. '} ';
  else
    return tostring(o);
  end
end

function Plugin.Split(str, sep)
  local array = {};
  local reg = string.format("([^%s]+)",sep);
  for mem in string.gmatch(str,reg) do
    table.insert(array, mem);
  end
  return array;
end

function Plugin.GetTeamSkills(skill, skillOffset)
  return Max(0, skill + skillOffset), Max(0, skill - skillOffset); -- Marine, Alien
end

-- Fix base ns2 bug
function BindingsUI_GetInputValue(controlId)
    if (not controlId) then return ''; end

    local value = Client.GetOptionString( "input/" .. controlId, "" )

    local rc = ""
    
    if(value ~= "") then
        rc = value
    else
        rc = GetDefaultInputValue(controlId)
        if (rc ~= nil) then
            Client.SetOptionString( "input/" .. controlId, rc )
        end
        
    end
    
    return rc
end

--This table will be passed into server.lua and client.lua as the global value "Plugin".
Shine:RegisterExtension("tier_info", Plugin)
