Hydra.kNearSpread = Math.Radians(1)
Hydra.kFarSpread = Math.Radians(3)  -- always use this
Hydra.kNearDistance = 2
Hydra.kFarDistance = 12

--Hydra.kSpread = Math.Radians(4)
Hydra.kRateOfFire = 0.775
Hydra.kUpdateInterval = 0.74 --0.09
Hydra.kTargetVelocityFactor = 0.4
Hydra.kDamage = kHydraDamage
Hydra.kMaxUseableRange = 12

local networkVars =
{
}

local oldOnInitialized = Hydra.OnInitialized
function Hydra:OnInitialized()
    oldOnInitialized(self)
    self.timeOfLastFire = 0
end

function Hydra:GetUseMaxRange()
    return self.kMaxUseableRange
end

if Server then
    function Hydra:OnUpdate(deltaTime)

        PROFILE("Hydra:OnUpdate")
        
        ScriptActor.OnUpdate(self, deltaTime)
        
        if not self.timeLastUpdate then
            self.timeLastUpdate = Shared.GetTime()
        end
                
        --if self.timeLastUpdate + Hydra.kUpdateInterval <= Shared.GetTime() then
            
            if (not self.timeOfNextFire or Shared.GetTime() >= self.timeOfNextFire) and not self:GetIsOnFire() and GetIsUnitActive(self) then
                self.target = self.targetSelector:AcquireTarget()

                -- Check for obstacles between the origin and barrel point of the hydra so it doesn't shoot while sticking through walls
                self.attacking = self.target and not GetWallBetween(self:GetBarrelPoint(), self:GetOrigin(), self) and not GetIsPointInsideClogs(self:GetBarrelPoint())

                if self.attacking then
                    self:AttackTarget()
                elseif not self.target then
                    -- Play alert animation if marines nearby and we're not targeting (ARCs?)
                    if not self.timeLastAlertCheck or Shared.GetTime() > self.timeLastAlertCheck + Hydra.kAlertCheckInterval then
                    
                        self.alerting = false
                        
                        if self:GetIsEnemyNearby() then
                        
                            self.alerting = true
                            self.timeLastAlertCheck = Shared.GetTime()
                            
                        end
                        
                    end
                end

            else
                self.attacking = false
            end
            
            self.timeLastUpdate = Shared.GetTime()
            
        --end
        
    end

    -- Spread changes based on target distance.
    function Hydra:CreateSpikeProjectile()

        -- TODO: make hitscan at account for target velocity (more inaccurate at higher speed)

        local startPoint = self:GetBarrelPoint()
        local directionToTarget = self.target:GetEngagementPoint() - self:GetEyePos()
        local targetDistance = directionToTarget:GetLength()
        local theTimeToReachEnemy = targetDistance / Hydra.kSpikeSpeed
        local engagementPoint = self.target:GetEngagementPoint()
        local trailTargetDistance = Hydra.kTargetVelocityFactor
        
        if self.target.GetVelocity then

            local targetVelocity = self.target:GetVelocity()

            engagementPoint = self.target:GetEngagementPoint() - ((targetVelocity:GetLength() * trailTargetDistance * theTimeToReachEnemy) * GetNormalizedVector(targetVelocity))

        end

        local fireDirection = GetNormalizedVector(engagementPoint - startPoint)
        local fireCoords = Coords.GetLookIn(startPoint, fireDirection)

        local spread = Hydra.kFarSpread

        local spreadDirection = CalculateSpread(fireCoords, spread, math.random)

        local endPoint = startPoint + spreadDirection * Hydra.kRange

        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(self, "Hydra"))

        if trace.fraction < 1 then

            local surface

            -- Disable friendly fire.
            trace.entity = (not trace.entity or GetAreEnemies(trace.entity, self)) and trace.entity or nil

            if not trace.entity then
                surface = trace.surface
            end

            -- local direction = (trace.endPoint - startPoint):GetUnit()
            self:DoDamage(Hydra.kDamage, trace.entity, trace.endPoint, fireDirection, surface, false, true)

            --[[local owner = self.hydraParentId and Shared.GetEntity(self.hydraParentId) or nil
            if trace.entity and HasMixin(trace.entity, "ParasiteAble") then
                trace.entity:SetParasited(owner, 2)
            end--]]

        end

    end
    
    function Hydra:GetRateOfFire()
                                                                               
        return Hydra.kRateOfFire
    end
    
    function Hydra:AttackTarget()

        self:TriggerUncloak()

        self:CreateSpikeProjectile()
        self:TriggerEffects("hydra_attack")

        --Log("time since last spike fired : %f", Shared.GetTime() - (self.timeOfLastFire or 0))
        
        self.timeOfLastFire = Shared.GetTime()
        self.timeOfNextFire = Shared.GetTime() + self:GetRateOfFire()

    end
end

--Shared.LinkClassToMap("Hydra", Hydra.kMapName, networkVars)