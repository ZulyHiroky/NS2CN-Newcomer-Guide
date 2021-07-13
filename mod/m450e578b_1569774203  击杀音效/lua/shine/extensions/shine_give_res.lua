-- Kill Clogs Commands
-- Adds a command that allows you to kill clogs within a radius.
-- Useful for dealing with griefing (especially in game modes like Siege)
-- sh_killclogs <radius> or !killclogs <radius>
-- Radius parameter is a number between 1 and 10 and is optional (Default: 5).
local Shine = Shine
local Plugin = {}
Plugin.Version = "1.0"
Plugin.Author = "tachi"
Plugin.PrintName = "Give Res"

Plugin.HasConfig = false
Plugin.CheckConfig = false
Plugin.CheckConfigTypes = false
Plugin.NotifyPrefixColour = { 255, 50, 0 }
local COMMAND_ID = "sh_giveres"
local CHAT_COMMAND = "giveres"

local DEBUG = false

-- Initialize Plugin
function Plugin:Initialise()
    self:setup_command()
	  return true
end

-- Adds amount resources to target res pool if the owner has enough.
local function transfer_resources_to_target(owner, target, amount)
    local maxDiff = kMaxPersonalResources - target.resources
    amount = math.min(amount, maxDiff)
    target.resources = target.resources + amount
    return amount
end

-- Reduces the owners res pool by amount
local function reduce_resources_of_owner(owner, amount)
    owner.resources = owner.resources - amount
end

-- Ensures that owner and target are on the same team
local function check_teams(targetPlayer, teamNumber)
    return targetPlayer:GetTeamNumber() == teamNumber
end

-- Ensures that a player is not a commander
local function check_status(targetPlayer)
    Shared.Message("Checking " .. ToString(targetPlayer:GetName()))
    return not targetPlayer:GetIsCommander()
end

local function filterList(targets, fn)
    local newTargetList = {}
    for i = 1, #targets do
        if targets[i] and targets[i] ~= client then
            local targetPlayer = targets[i]:GetControllingPlayer()
            if fn(targetPlayer) then
              table.insert(newTargetList, targetPlayer)
            end
        end
    end
    return newTargetList
end

-- Sets up the sh_giveres command
function Plugin:setup_command()
    local function give_res(client, resourceAmount, targets)
        -- Grabs the player who initiated the command
        local localPlayer = client:GetControllingPlayer()
        -- Ensures the local player can actually do this
        if localPlayer and check_status(localPlayer) then
            local targetCount = #targets
            -- Shine SHOULD NOT give us an empty list here as it is required
            -- but it doesn't hurt to ensure this
            if targetCount == 0 then return end

            -- If the player specified more resources than he has
            -- we will end up just going to up the current resources he has
            if resourceAmount > localPlayer.resources then
                resourceAmount = localPlayer.resources
            end

            -- Keeps track of how much res to remove from our local player
            -- We remove all res from the res owner at once in case any extra
            -- network traffic might happen every time we reduce it
            local totalToTransferFromOwner = 0
            targets = filterList(targets, function (targetPlayer)
                -- ensure same team
                return check_teams(targetPlayer, localPlayer:GetTeamNumber())
                    -- Ensure status is okay
                    and check_status(targetPlayer)
                    -- Ensure target player can get resources still
                    and targetPlayer.resources < kMaxPersonalResources
            end)
            targetCount = #targets
            -- Get an amount of res per target to give
            resourceAmount = resourceAmount / targetCount
            Shared.Message(ToString(targetCount))
            for i = 1, targetCount do
                local targetPlayer = targets[i]
                local amountToGive = math.min(resourceAmount, (kMaxPersonalResources - targetPlayer.resources))
                local amountGiven = transfer_resources_to_target(localPlayer, targetPlayer, amountToGive)
                Shared.Message(ToString(amountGiven))
                totalToTransferFromOwner = totalToTransferFromOwner + amountGiven
                Plugin:Notify(targets[i], ToString(localPlayer:GetName()) .. " gave you " .. ToString(amountToGive) .. " res." )
                if DEBUG then
                    Shared.Message("Processed: " .. ToString(targetPlayer:GetName()))
                end
            end
            reduce_resources_of_owner(localPlayer, totalToTransferFromOwner)
            Plugin:Notify(localPlayer, "Give Res Succeeded.")
        end
    end
    local killClogsCommand = self:BindCommand(COMMAND_ID, {CHAT_COMMAND}, give_res, false)
    killClogsCommand:AddParam({ Type = "number", Help = "Resource Amount" })
    killClogsCommand:AddParam({ Type = "clients", Help = "Player(s)" })

    killClogsCommand:Help("Give Res")
end

Shine:RegisterExtension( "shine_give_res", Plugin)
