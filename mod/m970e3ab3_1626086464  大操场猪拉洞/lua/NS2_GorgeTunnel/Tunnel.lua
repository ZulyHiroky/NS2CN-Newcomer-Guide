-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Tunnel.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Tunnel entity, connection between 2 gorge tunnel entrances!
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TunnelProp.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EffectsMixin.lua")
Script.Load("lua/MinimapConnectionMixin.lua")

kTunnelExitSide = enum({'A', 'B'})

-- So tunnels don't ever overlap in world-space, keep track of which "slots" have tunnels in them.
local tunnelSlots = {}
function GetNextAvailableTunnelSlot() -- reserves and returns the next available "tunnel slot" index.
    local index = 1;
    while tunnelSlots[index] ~= nil do
        index = index + 1
    end
    tunnelSlots[index] = true
    return index
end

-- Frees up the given "tunnel slot" index, so a new tunnel can be created there.
function FreeTunnelSlot(index)
    assert(tunnelSlots[index] == true)
    tunnelSlots[index] = nil
end


class 'Tunnel' (Entity)

local kTunnelLoopingSound = PrecacheAsset("sound/NS2.fev/alien/structures/tunnel/loop")
local kTunnelCinematic = PrecacheAsset("cinematics/alien/tunnel/tunnel_ambient.cinematic")

local kTunnelLightA = PrecacheAsset("cinematics/alien/tunnel/tunnel_ambient_a.cinematic")
local kTunnelLightB = PrecacheAsset("cinematics/alien/tunnel/tunnel_ambient_b.cinematic")

local kTunnelSpacing = Vector(160, 0, 0)
local kTunnelStart = Vector(-1600, 200, -1600)

local kTunnelLength = 27

local kEntranceAPos = Vector(3, 0.5, -11)
local kEntranceBPos = Vector(3, 0.5, 11)

local kExitAPos = Vector(3.75, 0.15, -15)
local kExitBPos = Vector(3.75, 0.15, 15)

Tunnel.kModelName = PrecacheAsset("models/alien/tunnel/tunnel.model")
local kAnimationGraph = PrecacheAsset("models/alien/tunnel/tunnel.animation_graph")

local kTunnelPropAttachPoints =
{
    { "Tunnel_attachPointCeiling_00", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_02", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_03", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_04", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_05", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_06", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_07", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_08", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_09", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_10", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_11", kTunnelPropType.Ceiling },
    
    { "Tunnel_attachPointGrnd_00", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_01", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_02", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_03", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_04", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_05", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_06", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_07", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_08", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_09", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_10", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_11", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_12", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_13", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_14", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_15", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_16", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_17", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_18", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_19", kTunnelPropType.Floor },
}

local networkVars =
{
    exitAConnected = "boolean",
    exitBConnected = "boolean",
    exitAEntityPosition = "vector",
    exitBEntityPosition = "vector",
    exitAUsed = "boolean",
    exitBUsed = "boolean",
    collapsing = "boolean",
    flinchAAmount = "float (0 to 1 by 0.05)",
    flinchBAmount = "float (0 to 1 by 0.05)",
    flinchTotalAmount = "float (0 to 1 by 0.05)",
}

Tunnel.kMapName = "tunnel"

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

-- Returns the number of non-collapsing tunnels active for the given team (assumes alien team if none specified).
function Tunnel.GetLivingTunnelCount(teamNumber)
    
    -- Default to alien team.
    if not teamNumber then
        teamNumber = kTeam2Index
    end
    
    local markedEntrances = {}
    local entrances = GetEntitiesForTeam("TunnelEntrance", teamNumber)
    
    local count = 0
    for i = 1, #entrances do
        local entrance = entrances[i]
        if not entrance:GetGorgeOwner() then
            local otherEntrance = entrance:GetOtherEntrance()
            if otherEntrance and not markedEntrances[otherEntrance:GetId()] then
                markedEntrances[entrance:GetId()] = true
                
                count = count + 1
            end
        end
    end
    
    return count
end

function Tunnel:OnCreate()
    
    Entity.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, EffectsMixin)
    
    if Server then
        
        InitMixin(self, EntityChangeMixin)
        
        self.exitAId = Entity.invalidId
        self.exitBId = Entity.invalidId
        
        self.exitAConnected = false
        self.exitBConnected = false
        
        self:SetPropagate(Entity.Propagate_Always)
        self:SetRelevancyDistance(kMaxRelevancyDistance)
        
        self.collapsing = false
        
        self.loopingSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingSound:SetAsset(kTunnelLoopingSound)
        self.loopingSound:SetParent(self)
        self.loopingSound:SetPositional(false)
        
        self.timeExitAUsed = 0
        self.timeExitBUsed = 0
        
        self.flinchAAmount = 0
        self.flinchBAmount = 0
        self.flinchTotalAmount = 0
        
        self.tunnelContentsActive = true
        
        self.slotIndex = GetNextAvailableTunnelSlot()
    
    end
    
    self:SetUpdates(true, kDefaultUpdateRate)

end

local function CreateRandomTunnelProps(self)
    
    for i = 1, #kTunnelPropAttachPoints do
        
        local attachPointEntry = kTunnelPropAttachPoints[i]
        local attachPointPosition = self:GetAttachPointOrigin(attachPointEntry[1])
        
        if attachPointPosition then
            
            local tunnelProp = CreateEntity(TunnelProp.kMapName, attachPointPosition)
            tunnelProp:SetParent(self)
            tunnelProp:SetTunnelPropType(attachPointEntry[2], math.max(0, i - 12))
            tunnelProp:SetAttachPoint(attachPointEntry[1])
        
        end
    
    end

end

function Tunnel:GetIsDeadEnd()
    return not self.exitAConnected or not self.exitBConnected
end

function Tunnel:OnInitialized()
    
    self:SetModel(Tunnel.kModelName, kAnimationGraph)
    
    if Server then
        
        self:SetOrigin((self.slotIndex-1) * kTunnelSpacing + kTunnelStart)
        CreateRandomTunnelProps(self)
        
        InitMixin(self, MinimapConnectionMixin)
        self.loopingSound:Start()
        
        self:SetPhysicsType(PhysicsType.Kinematic)
    
    elseif Client then
        
        self.tunnelLightCinematicA = Client.CreateCinematic(RenderScene.Zone_Default)
        self.tunnelLightCinematicA:SetCinematic(kTunnelLightA)
        self.tunnelLightCinematicA:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.tunnelLightCinematicA:SetCoords(self:GetCoords())
        self.tunnelLightCinematicA:SetIsVisible(self.exitAConnected)
        
        self.tunnelLightCinematicB = Client.CreateCinematic(RenderScene.Zone_Default)
        self.tunnelLightCinematicB:SetCinematic(kTunnelLightB)
        self.tunnelLightCinematicB:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.tunnelLightCinematicB:SetCoords(self:GetCoords())
        self.tunnelLightCinematicB:SetIsVisible(self.exitAConnected)
        
        self.tunnelCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.tunnelCinematic:SetCinematic(kTunnelCinematic)
        self.tunnelCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.tunnelCinematic:SetCoords(self:GetCoords())
        --[[
        self.tunnelReverb = Reverb()
        self.tunnelReverb:SetOrigin(self:GetOrigin())
        self.tunnelReverb.minRadius = 27
        self.tunnelReverb.maxRadius = 30
        self.tunnelReverb.reverbType = kReverbNames.hallway
        self.tunnelReverb:OnLoad()
        --]]
    end
    
    self.tunnelContentsActive = true

end

function Tunnel:OnDestroy()
    
    Entity.OnDestroy(self)
    
    if Server then
        
        self.loopingSound = nil
        FreeTunnelSlot(self.slotIndex)
        
        local aEnt = self:GetExitA()
        local bEnt = self:GetExitB()
        
        if aEnt then
            aEnt:SetTunnel(nil)
        end
        
        if bEnt then
            bEnt:SetTunnel(nil)
        end
    
    elseif Client then
        
        if self.tunnelLightCinematicA then
            Client.DestroyCinematic(self.tunnelLightCinematicA)
            self.tunnelLightCinematicA = nil
        end
        
        if self.tunnelLightCinematicB then
            Client.DestroyCinematic(self.tunnelLightCinematicB)
            self.tunnelLightCinematicB = nil
        end
        
        if self.tunnelCinematic then
            Client.DestroyCinematic(self.tunnelCinematic)
            self.tunnelCinematic = nil
        end
    
    end

end

local function GetEntitiesWithTagInTunnel(self, tag)
    return Shared.GetEntitiesWithTagInRange(tag, self:GetOrigin(), (kTunnelLength + 1))
end

function Tunnel:GetIsCollapsing()
    return self.collapsing
end

if Server then
    
    function Tunnel:SetExits(exitA, exitB)
        
        assert(exitA)
        assert(exitB)
        
        self.exitAId = exitA:GetId()
        self.exitAEntityPosition = exitA:GetOrigin()
        self.timeExitAChanged = Shared.GetTime()
        
        self.exitBId = exitB:GetId()
        self.exitBEntityPosition = exitB:GetOrigin()
        self.timeExitBChanged = Shared.GetTime()
    
    end
    
    function Tunnel:GetConnectionStartPoint()
        
        if self.exitAConnected then
            return self.exitAEntityPosition
        end
    
    end
    
    function Tunnel:GetConnectionEndPoint()
        
        if self.exitBConnected then
            return self.exitBEntityPosition
        end
    
    end
    
    function Tunnel:UpdateExit(exit)
        
        local exitId = exit:GetId()
        if self.exitAId == exitId then
            self.exitAEntityPosition = exit:GetOrigin()
        elseif self.exitBId == exitId then
            self.exitBEntityPosition = exit:GetOrigin()
        end
    
    end
    
    local function RemoveExitIdFromTunnel(self, id)
        
        if self.exitAId == id then
            self.exitAId = Entity.invalidId
            self.exitAConnected = false
            --Print("A%s B%s removed %s",ToString(self.exitAId),ToString(self.exitBId),ToString(id))
        elseif self.exitBId == id then
            self.exitBId = Entity.invalidId
            self.exitBConnected = false
            --Print("A%s B%s removed %s",ToString(self.exitAId),ToString(self.exitBId),ToString(id))
        else
            return false
        end
        
        return true
    
    end
    
    -- Makes the given TunnelEntrance entity no longer an exit of the tunnel.  The given entity
    -- must be an exit of the tunnel.
    function Tunnel:RemoveExit(exit)
        
        assert(exit)
        assert(exit:isa("TunnelEntrance"))
        
        local id = exit:GetId()
        
        if not RemoveExitIdFromTunnel(self, id) then
            assert(false) -- RemoveExit called with entity that wasn't either of the two exits!
        end
    
    end
    
    function Tunnel:OnEntityChange(oldId)
        
        if oldId ~= Entity.invalidId then
            RemoveExitIdFromTunnel(self, oldId)
        end
    
    end
    
    -- Makes the given TunnelEntrance entity an exit of the tunnel.  The tunnel must not already
    -- have both entrances set.
    function Tunnel:AddExit(exit)
        
        assert(exit)
        assert(exit:isa("TunnelEntrance"))
        
        local id = exit:GetId()
        assert(self.exitAId ~= id)
        assert(self.exitBId ~= id)
        
        -- Assign this exit to whichever end is free.
        if self.exitAId == Entity.invalidId then
            self.exitAId = id
            self.exitAEntityPosition = exit:GetOrigin()
            self.exitAConnected = true
        elseif self.exitBId == Entity.invalidId then
            self.exitBId = id
            self.exitBEntityPosition = exit:GetOrigin()
            self.exitBConnected = true
        else
            assert(false) -- AddExit called when both ends were already set!
        end
        
        self:StopCollapse()
    
    end
    
    local function DestroyAllUnitsInside(self)
        
        local entities = GetEntitiesWithTagInTunnel(self, "Live")
        for i = 1, #entities do
            local unit = entities[i]
            unit:Kill()
        end
    
    end
    
    local kExitOffset = Vector(0, 0.3, 0)
    
    function Tunnel:UseExit(entity, exit, exitSide)
        
        local destinationOrigin = exit:GetOrigin() + kExitOffset
        
        if entity.OnUseGorgeTunnel then
            entity:OnUseGorgeTunnel(destinationOrigin)
        end
        
        self:TriggerEffects("tunnel_exit_3D", { effecthostcoords = entity:GetCoords() })
        
        --Required to call effects manager due to sound-parenting behaviors, otherwise sound doesn't play INSIDE tunnels
        self:TriggerEffects("tunnel_exit_3D", { effecthostcoords = entity:GetCoords() })
        
        entity:SetOrigin(destinationOrigin)
        
        if entity:isa("Player") then
            
            local newAngles = entity:GetViewAngles()
            newAngles.pitch = 0
            newAngles.roll = 0
            newAngles.yaw = newAngles.yaw + self:GetMinimapYawOffset()
            entity:SetOffsetAngles(newAngles)
        
        end
        
        exit:OnEntityExited(entity)
        
        if exitSide == kTunnelExitSide.A then
            self.timeExitAUsed = Shared.GetTime()
        elseif exitSide == kTunnelExitSide.B then
            self.timeExitBUsed = Shared.GetTime()
        end
    
    end
    
    local function ApplyDOTToEntity(ent, dps, deltaTime)
        
        if not ent:GetIsAlive() then
            return
        end
        
        if ent:isa("Exo") then
            ent:TakeDamage(dps * deltaTime, nil, nil, nil, nil, dps * deltaTime, 0, kDamageType.Normal)
        else
            ent:TakeDamage(dps * deltaTime, nil, nil, nil, nil, 0, dps * deltaTime, kDamageType.Normal)
        end
    
    end
    
    -- Checks if the tunnel is vacated, and if so, destroys it.
    function Tunnel:UpdateTunnelDestruction()
        
        if not self.destroyingWhenVacant then
            return false
        end
        
        local ents = GetEntitiesWithTagInTunnel(self, "Live");
        if #ents > 0 then
            return 1 -- check again later
        end
        
        DestroyEntity(self)
        
        return false
    
    end
    
    -- Sets up a callback that checks if the tunnel is empty (all entities living or dead) and if
    -- so, destroys the tunnel and any remaining tunnel entrances.
    function Tunnel:DestroyAsSoonAsVacant()
        
        if self.destroyingWhenVacant then return end -- already set to destroy self
        
        self.destroyingWhenVacant = true
        self:AddTimedCallback(Tunnel.UpdateTunnelDestruction, 1)
    
    end
    
    -- Apply a DOT on all the players left inside the tunnel.
    function Tunnel:UpdateCollapseDoT()
        
        if not self.collapsing then
            return false
        end
        
        if not self.timeLastDotApplied then
            self.timeLastDotApplied = Shared.GetTime()
            return 0 -- apply dot next update
        end
        
        local now = Shared.GetTime()
        local deltaTime = now - self.timeLastDotApplied
        self.timeLastDotApplied = now
        
        local ents = GetEntitiesWithTagInTunnel(self, "Live");
        local entCount = #ents
        for i = entCount, 1, -1 do
            ApplyDOTToEntity(ents[i], kTunnelCollapseDPS, deltaTime)
        end
        
        -- If none of the players are left inside the tunnel (not just dead, but the entities are
        -- gone), then destroy the tunnel.
        if #ents == 0 then
            return false
        end
        
        -- Repeat this callback next update, so we can apply the dot again.
        return 0
    
    end
    
    function Tunnel:BeginCollapseDoT()
        
        self:AddTimedCallback(Tunnel.UpdateCollapseDoT, 0)
        
        return false -- don't repeat
    
    end
    
    function Tunnel:BeginCollapse()
        
        if self.collapsing then
            -- Other entrance already died, causing it to start collapsing.  Last remaining
            -- entrance just died too, so kill everything in the tunnel instantly, and set the
            -- tunnel to self destruct.
            
            DestroyAllUnitsInside(self)
            
            self:DestroyAsSoonAsVacant()
            
            return
        end
        
        self.collapsing = true
        
        self.timeCollapseStart = Shared.GetTime()
        
        -- Start a DoT after a certain amount of time to force those players to vamoose.
        self:AddTimedCallback(Tunnel.BeginCollapseDoT, kTunnelCollapseWarningDuration)
        
        -- Tunnel entities are destroyed after a collapse (and during a collapse, players cannot
        -- reenter the tunnel).
        self:DestroyAsSoonAsVacant()
    
    end
    
    function Tunnel:TriggerCollapse()
        self.collapsing = true
    end
    
    function Tunnel:StopCollapse()
        self.collapsing = false
        self.destroyingWhenVacant = false
    end
    
    function Tunnel:GetExitA()
        return self.exitAId ~= Entity.invalidId and Shared.GetEntity(self.exitAId)
    end
    
    function Tunnel:GetExitB()
        return self.exitBId ~= Entity.invalidId and Shared.GetEntity(self.exitBId)
    end
    
    function Tunnel:UpdateFlinchAmount()
        
        local exitA = self:GetExitA()
        local exitB = self:GetExitB()
        
        self.flinchAAmount = exitA and exitA:GetFlinchIntensity() or 0
        self.flinchBAmount = exitB and exitB:GetFlinchIntensity() or 0
        
        if self.collapsing then
            local normalizedTimeDiff = math.min(math.max((Shared.GetTime() - self.timeCollapseStart) / kTunnelCollapseWarningDuration, 0.0), 1.0)
            self.flinchTotalAmount = normalizedTimeDiff
        end
    
    end
    
    function Tunnel:SetActiveTunnelContents(active)
        
        local props = GetEntitiesWithTagInTunnel(self, "class:TunnelProp")
        for index = 1, #props do
            local prop = props[index]
            prop:SetUpdates(active)
        end
        self.tunnelContentsActive = active
        -- Log("%s: %s tunnel props %s", self, #props, active and "activated" or "deactivated")
    
    end
    
    function Tunnel:UpdateActivityStatus()
        -- Turn on/off update status for tunnels depending on if they contain players
        local containsPlayers = #GetEntitiesWithTagInTunnel(self, "class:Player") > 0
        if containsPlayers and not self.tunnelContentsActive then
            self:SetActiveTunnelContents(true)
        end
        if not containsPlayers and self.tunnelContentsActive then
            self:SetActiveTunnelContents(false)
        end
    
    end
    
    function Tunnel:OnUpdate()
        
        self.exitAUsed = self.timeExitAUsed + 0.2 > Shared.GetTime()
        self.exitBUsed = self.timeExitBUsed + 0.2 > Shared.GetTime()
        
        self:UpdateFlinchAmount()
        
        self:UpdateActivityStatus()
    
    end
    
    function Tunnel:GetOwnerClientId()
        return self.ownerClientId
    end
    
    function Tunnel:SetOwnerClientId(clientId)
        self.ownerClientId = clientId
    end
    
    function Tunnel:MovePlayerToTunnel(player, entrance)
        
        assert(player)
        assert(entrance)
        
        local entranceId = entrance:GetId()
        
        local newAngles = player:GetViewAngles()
        newAngles.pitch = 0
        newAngles.roll = 0
        
        --Two sound effects required here for inside and outside a tunnel
        --Required to call effects manager due to sound-parenting behaviors
        if entranceId == self.exitAId then
            
            player:SetOrigin(self:GetEntranceAPosition())
            newAngles.yaw = GetYawFromVector(self:GetCoords().zAxis)
            player:SetOffsetAngles(newAngles)
            self:TriggerEffects("tunnel_enter_3D", { effecthostcoords = player:GetCoords() })
            self:TriggerEffects("tunnel_enter_3D", { effecthostcoords = entrance:GetCoords() })
            self.timeExitAUsed = Shared.GetTime()
        
        elseif entranceId == self.exitBId then
            
            player:SetOrigin(self:GetEntranceBPosition())
            newAngles.yaw = GetYawFromVector(-self:GetCoords().zAxis)
            player:SetOffsetAngles(newAngles)
            self:TriggerEffects("tunnel_enter_3D", { effecthostcoords = player:GetCoords() })
            self:TriggerEffects("tunnel_enter_3D", { effecthostcoords = entrance:GetCoords() })
            self.timeExitBUsed = Shared.GetTime()
        
        end
    
    end

else
    -- Predict or Client
    
    function Tunnel:OnUpdateRender()
        
        self.tunnelLightCinematicA:SetIsVisible(self.exitAConnected)
        self.tunnelLightCinematicB:SetIsVisible(self.exitBConnected)
    
    end

end

function Tunnel:GetExitAPosition()
    return self:GetOrigin() + self:GetCoords():TransformVector(kExitAPos)
end

function Tunnel:GetExitBPosition()
    return self:GetOrigin() + self:GetCoords():TransformVector(kExitBPos)
end

function Tunnel:GetEntranceAPosition()
    return self:GetOrigin() + self:GetCoords():TransformVector(kEntranceAPos)
end

function Tunnel:GetEntranceBPosition()
    return self:GetOrigin() +  self:GetCoords():TransformVector(kEntranceBPos)
end

function Tunnel:GetFractionalPosition( position )
    return ( (-self:GetCoords().zAxis):DotProduct( self:GetOrigin() - position ) + kTunnelLength *.5) / kTunnelLength
end

function Tunnel:GetRelativePosition(position)
    
    local fractionPos = ( (-self:GetCoords().zAxis):DotProduct( self:GetOrigin() - position ) + kTunnelLength *.5) / kTunnelLength
    return (self.exitBEntityPosition - self.exitAEntityPosition) * fractionPos + self.exitAEntityPosition

end

function Tunnel:GetMinimapYawOffset()
    
    if self.exitAEntityPosition == self.exitBEntityPosition then
        return 0
    end
    
    local tunnelDirection = GetNormalizedVector( self.exitBEntityPosition - self.exitAEntityPosition )
    return math.atan2(tunnelDirection.x, tunnelDirection.z)

end

function Tunnel:OnUpdatePoseParameters()
    
    self:SetPoseParam("intensity_yn", self.flinchBAmount)
    self:SetPoseParam("intensity_yp", self.flinchAAmount)
    self:SetPoseParam("intensity", self.flinchTotalAmount)

end

function Tunnel:OnUpdateAnimationInput(modelMixin)
    
    PROFILE("Tunnel:OnUpdateAnimationInput")
    
    modelMixin:SetAnimationInput("entrance_A_opened", self.exitAConnected)
    modelMixin:SetAnimationInput("entrance_B_opened", self.exitBConnected)
    
    modelMixin:SetAnimationInput("exit_A", self.exitAUsed)
    modelMixin:SetAnimationInput("exit_B", self.exitBUsed)

end

Shared.LinkClassToMap("Tunnel", Tunnel.kMapName, networkVars)

local function GetClosestLivingEntityWithClassToPoint(entClass, pt)
    local ents = EntityListToTable(Shared.GetEntitiesWithClassname(entClass))
    local closest
    local closestDist
    
    for i=1, #ents do
        local dist = (pt - ents[i]:GetOrigin()):GetLengthSquared()
        if (not closest or closestDist > dist) and ents[i]:GetIsAlive() then
            closest = ents[i]
            closestDist = dist
        end
    end
    
    return closest
end

if Server then
    
    Event.Hook("Console_tunnel_collapse", function(client)
        
        -- Cheats must be enabled to test tunnel collapse.
        if not Shared.GetCheatsEnabled() and not Shared.GetDevMode() then
            return
        end
        
        local player = client:GetControllingPlayer()
        if not player then return end
        
        local entranceToKill
        
        -- If the player is in a gorge tunnel, kill one of the two entrances.
        local tunnel = GetIsPointInGorgeTunnel(player:GetOrigin())
        
        if tunnel then
            local a = tunnel:GetExitA()
            local b = tunnel:GetExitB()
            if a and a:GetIsAlive() then
                entranceToKill = a
            elseif b and b:GetIsAlive() then
                entranceToKill = b
            end
        end
        
        -- Just pick the closest entrance to kill if we don't have one already.
        if not entranceToKill then
            entranceToKill = GetClosestLivingEntityWithClassToPoint("TunnelEntrance", player:GetOrigin())
        end
        
        -- No entrances were present, apparently.
        if not entranceToKill then
            return
        end
        
        entranceToKill:Kill()
    
    end)

end
