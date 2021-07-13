local kSlapAfterBombardTimeout = Shared.GetAnimationLength(Whip.kModelName, "attack")
local kSlapAnimationHitTagAt      = kSlapAfterBombardTimeout / 2.5

function Whip:SlapTarget(target)
    self:FaceTarget(target)
    -- where we hit
    local now = Shared.GetTime()
    local targetPoint = target:GetEngagementPoint()
    local attackOrigin = self:GetEyePos()
    local hitDirection = targetPoint - attackOrigin
    hitDirection:Normalize()
    -- fudge a bit - put the point of attack 0.5m short of the target
    local hitPosition = targetPoint - hitDirection * 0.5
    local damage = self:isa("GorgeWhip") and kGorgeWhipSlapDamage or Whip.kDamage
    
    self:DoDamage(damage, target, hitPosition, hitDirection, nil, true)
    self:TriggerEffects("whip_attack")

    local nextSlapStartTime    = now + (kSlapAfterBombardTimeout - kSlapAnimationHitTagAt)
    local nextBombardStartTime = now + (kSlapAfterBombardTimeout - kSlapAnimationHitTagAt)

    self.nextSlapStartTime    = math.max(nextSlapStartTime,    self.nextSlapStartTime)
    self.nextBombardStartTime = math.max(nextBombardStartTime, self.nextBombardStartTime)
end
