-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Mixins\LadderMoveMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

LadderMoveMixin = CreateMixin( LadderMoveMixin )
LadderMoveMixin.type = "LadderMove"

LadderMoveMixin.networkVars =
{
    onLadder = "private boolean",
}

LadderMoveMixin.expectedCallbacks =
{
    GetCrouchSpeedScalar = ""
}

local kLadderAcceleration = 25
local kLadderFriction = 9
local kLadderMaxSpeed = 5

function LadderMoveMixin:__initmixin()

    self.onLadder = false

end

function LadderMoveMixin:SetIsOnLadder(onLadder)
    self.onLadder = onLadder    
end

function LadderMoveMixin:GetIsOnLadder()
    return self.onLadder
end

function LadderMoveMixin:ModifyGravityForce(gravityTable)

    if self.onLadder and not self.jetpacking then
        gravityTable.gravity = 0
    end

end


function LadderMoveMixin:ModifyVelocity(input, velocity, deltaTime)

    if self.onLadder and not self.jetpacking then
        
        -- super duper hacky schmacky
        if not self.jetpacking then
        
            local wishDir = self:GetViewCoords():TransformVector(input.move)
            if wishDir:GetLength() <= 0 then
                -- apply friction
                local newVelocity = SlerpVector(velocity, Vector(0,0,0), -velocity:GetLength() * deltaTime * kLadderFriction)
                if newVelocity:GetLength() <= BaseMoveMixin.kMinimumVelocity then
                    newVelocity:Scale(0)
                end
                newVelocity.x = 0
                newVelocity.z = 0
                VectorCopy(newVelocity, velocity)
            end
            if wishDir.y ~= 0 then     
                wishDir.y = GetSign(wishDir.y)            
            end
            
            local currentSpeed = velocity:DotProduct(wishDir)
            local addSpeed = math.max(0, kLadderMaxSpeed - currentSpeed)
            if addSpeed > 0 then
            
                local accelSpeed = math.min(addSpeed, deltaTime * kLadderAcceleration)
                velocity:Add(accelSpeed * wishDir)
            
            end
            if velocity:GetLength() > self:GetMaxSpeed() then
                
                velocity:Normalize()
                velocity:Scale(self:GetMaxSpeed())
            end
        end
    
    end

end
--[[
function LadderMoveMixin:OnUpdateAnimationInput(modelMixin)

    PROFILE("LadderMoveMixin:OnUpdateAnimationInput")
    
    if self.onLadder then
        modelMixin:SetAnimationInput("move", "climb")
    end
    
end    
--]]