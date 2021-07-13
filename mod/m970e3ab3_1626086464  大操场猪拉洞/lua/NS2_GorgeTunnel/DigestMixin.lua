local kDefaultDigestDuration = 2
local kAllowedReleaseTimeBeforeReset = 0.3

local function GetEffectiveDigestDuration(self)

    if self.GetDigestDuration then
        return self:GetDigestDuration()
    else
        return kDefaultDigestDuration
    end
 
end

local function Digest(self)

    local digestDuration = GetEffectiveDigestDuration(self)
    
    -- Reset the digest timer if this entity hasn't been
    -- digested in a while.
    local now = Shared.GetTime()
    if now - self.lastDigestUseTime > kAllowedReleaseTimeBeforeReset then
        self.digestDoneTime = Shared.GetTime()+digestDuration
    end
    
    -- Are we done??
    if Server and now >= self.digestDoneTime then
    
        self:TriggerEffects("digest", {effecthostcoords = self:GetCoords()} )
        self.consumed = true
        self:Kill()
        
    end
    
    -- update
    self.lastDigestUseTime = now
    
end

function DigestMixin:OnUse(player, elapsedTime, useSuccessTable)

    local canDigest = false
    if self.GetCanDigest then
        canDigest = self:GetCanDigest(player)
    else
        canDigest = player == self:GetOwner() and (not HasMixin(self, "Live") or self:GetIsAlive())
    end
    
    if canDigest then
        Digest(self)
    end
    
    useSuccessTable.useSuccess = useSuccessTable.useSuccess and canDigest
    
end