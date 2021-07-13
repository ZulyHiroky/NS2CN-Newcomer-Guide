-- Kill Clogs Commands
-- Adds a command that allows you to kill clogs within a radius.
-- Useful for dealing with griefing (especially in game modes like Siege)
-- sh_killclogs <radius> or !killclogs <radius>
-- Radius parameter is a number between 1 and 10 and is optional (Default: 5).
local Shine = Shine
local Plugin = {}
Plugin.Version = "1.0"
Plugin.PrintName = "Kill Clogs"
Plugin.HasConfig = false
Plugin.CheckConfig = false
Plugin.CheckConfigTypes = false

local COMMAND_ID = "sh_killclogs"
local CHAT_COMMAND = "killclogs"

function Plugin:Initialise()
    self:SetupCommand()
	return true
end

function Plugin:SetupCommand()
    local function KillClogs(client, radius)
        local localPlayer = client:GetControllingPlayer()
        if localPlayer ~= nil then
            for _, clogEnt in ipairs(GetEntitiesWithinRange("Clog", localPlayer:GetOrigin(), radius)) do
                clogEnt:Kill()
            end
        end
    end
    local killClogsCommand = self:BindCommand(COMMAND_ID, {CHAT_COMMAND}, KillClogs, false)
    killClogsCommand:AddParam{ Type = "number", Optional = true, Default = 5, Min = 1, Max = 10, Help = "Supply an optional radius (meters) between 1 and 20 inclusive.  Defaults to 5." }
    killClogsCommand:Help("Kills all clogs within the radius specified.")
end

Shine:RegisterExtension( "shine_kill_clogs", Plugin)
