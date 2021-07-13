--[[
  All Talk Reset
  Uses the spooky "Do Not Use" RunCommand to keep AllTalk settings in sync.
  Will find better alternate in future if possible.
--]]
local Shine = Shine
local Plugin = {}
Plugin.Version = "1.0"
Plugin.PrintName = "All Talk Reset"
Plugin.HasConfig = false
Plugin.CheckConfig = false
Plugin.CheckConfigTypes = false

function Plugin:Initialise()
	return true
end

local function DisableAllTalk()
    Shine:RunCommand(nil, "sh_alltalk", false, "false")
end

-- For multiple rounds on a map
function Plugin:EndGame()
    DisableAllTalk()
end

-- Disables before map changes (done via Admin Menu or sh map change commands)
function Plugin:MapChange()
    DisableAllTalk()
end

-- Catch all in case the MapChange isn't triggered.
-- This might happen if the server crashes before it can do the change for example.
function Plugin:MapPostLoad()
    DisableAllTalk()
end

Shine:RegisterExtension( "shine_alltalk_reset", Plugin)
