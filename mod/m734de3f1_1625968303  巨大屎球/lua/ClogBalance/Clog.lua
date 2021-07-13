kClogDigestDuration = 0.3
Clog.kRadius = 0.8911 --0.938
Clog.kMaxUseableRange = 3.5

Script.Load("lua/Mixins/BaseModelMixin.lua")
local networkVars =
{
}
AddMixinNetworkVars(BaseModelMixin, networkVars)

local ClogOnCreate = Clog.OnCreate
function Clog:OnCreate()
    ClogOnCreate(self)
    InitMixin(self, BaseModelMixin)
end

local ClogOnInit = Clog.OnInitialized
function Clog:OnInitialized()

    ClogOnInit(self)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
end

function Clog:GetDigestDuration()
    return kClogDigestDuration
end

local kModelScale = 1.33
function Clog:OnAdjustModelCoords(modelCoords)
    
    local coords = modelCoords
    coords.xAxis = modelCoords.xAxis * kModelScale
    coords.yAxis = modelCoords.yAxis * kModelScale
    coords.zAxis = modelCoords.zAxis * kModelScale
        
    return coords
    
end


function Clog:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint, weapon)
    
    -- grenade launcher deals reduced damage to clogs
    if doer and doer:GetClassName() == "Grenade" then
        damageTable.damage = damageTable.damage * 0.82
    end
    

end

function Clog:GetIsFlameableMultiplier()
    return 3
end

function Clog:GetUseMaxRange()
    return self.kMaxUseableRange
end

local kMaxClogHeightDiff = 0.0
function Clog:OnCapsuleTraceHit(entity)
    if entity:isa("Onos") and not entity.isHallucination and entity.GetIsCharging and entity:GetIsCharging() then
        if (entity:GetOrigin() - self:GetOrigin()).y < kMaxClogHeightDiff then
            self:Kill()
        end
        --DebugPrint("Clog Onos height diff:"..ToString((entity:GetOrigin() - self:GetOrigin()).y))
    end
end

Shared.LinkClassToMap("Clog", Clog.kMapName, networkVars, true)