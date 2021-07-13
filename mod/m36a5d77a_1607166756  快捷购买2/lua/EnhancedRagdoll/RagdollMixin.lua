local kRagdollTime = 10.0
local kDiscolorTime = 4.0
local kRagdollEndDelay = 0

function RagdollMixin:SetIsHighlightEnabled()
	-- can't use self:GetIsRagdoll() here if physics group changes
    return ConditionalValue(self:GetIsAlive(), nil, 0.5)
end

local function DisablePhysics(self)

	self:SetPhysicsGroup(PhysicsGroup.WeaponGroup)
	self:SetPhysicsGroupFilterMask(PhysicsMask.None)
	
	if self.physicsModel ~= nil then

		Shared.DestroyCollisionObject(self.physicsModel)
		self.physicsModel = nil

	end
	
	return false
end
	
if Server then

	local function SetRagdoll(self, deathTime)

		if Server then

			if self:GetPhysicsGroup() ~= PhysicsGroup.RagdollGroup then

				self:SetPhysicsType(PhysicsType.Dynamic)

				self:SetPhysicsGroup(PhysicsGroup.RagdollGroup)

				-- Apply landing blow death impulse to ragdoll (but only if we didn't play death animation).
				if self.deathImpulse and self.deathPoint and self:GetPhysicsModel() and self:GetPhysicsType() == PhysicsType.Dynamic then

				   self:GetPhysicsModel():AddImpulse(self.deathPoint, self.deathImpulse)
				   self.deathImpulse = nil
				   self.deathPoint = nil
				   self.doerClassName = nil

				end

				if deathTime then
				   self.timeToDestroy = deathTime
				end

			end
			
			--self:AddTimedCallback(DisablePhysics, kRagdollEndDelay)
		end

    end

    function RagdollMixin:OnTag(tagName)

		PROFILE("RagdollMixin:OnTag")

		if not self.GetHasClientModel or not self:GetHasClientModel() then

		 if tagName == "death_end" then

			if self.bypassRagdoll then
			   self:SetModel(nil)
			else
			   SetRagdoll(self, kRagdollTime)
			end

		 elseif tagName == "destroy" then
			DestroyEntitySafe(self)
		 end

		end

    end

end

if Client then
	function RagdollMixin:OnKillClient()
		self.timeRagdollInit = Shared.GetTime()
	end
	
	PrecacheAsset("cinematics/vfx_materials/deadplayer.surface_shader")
	local kRagdollMaterial = PrecacheAsset("cinematics/vfx_materials/deadplayer.material")

	function RagdollMixin:OnUpdateRender()

		PROFILE("RagdollMixin:OnUpdateRender")
		
		if not self:GetIsAlive() and self._renderModel then
			
			local dissolveAmount = (self.dissolveAmount ~= nil) and (1 - self.dissolveAmount) or 1

			if self.ragdollMaterial then
				
				self.ragdollMaterial:SetParameter("fadeAmount", dissolveAmount)

			end
			
			--local decayScalar = Clamp(self.timeRagdollInit and ((Shared.GetTime() - self.timeRagdollInit)/kRagdollTime) or 0, 0, 1)
			local decayScalar = 0.7 * (1 - Clamp(self.timeRagdollInit and ((Shared.GetTime() - self.timeRagdollInit)/kDiscolorTime) or 0, 0, 0.75))
			self._renderModel:SetMaterialParameter("glowIntensity", decayScalar)
			self._renderModel:SetMaterialParameter("colorIntensity", decayScalar)
			self._updateHighlight = true
		end

	end
	
--[[	function RagdollMixin:_UpdateDeathEffect()
		if not self:GetIsAlive() and self._renderModel then

			if self.ragdollMaterial then
				local dissolveAmount = (self.dissolveAmount ~= nil) and (1 - self.dissolveAmount) or 1
				self.ragdollMaterial:SetParameter("fadeAmount", dissolveAmount)
				self._renderModel:SetMaterialParameter("glowIntensity", dissolveAmount)
				self._renderModel:SetMaterialParameter("colorIntensity", 0.5)
			else
				local material = Client.CreateRenderMaterial()
				material:SetMaterial(kRagdollMaterial)
				self._renderModel:AddMaterial(material)
				self.ragdollMaterial = material
				self._updateHighlight = true
			end
		end
	end--]]
	
end

local function UpdateTimeToDestroy(self, deltaTime)

    if self.timeToDestroy then

        self.timeToDestroy = self.timeToDestroy - deltaTime

        if self.timeToDestroy <= 0 then

            self:SetModel(nil)

            local destructionAllowedTable = { allowed = true }
            if self.GetDestructionAllowed then
                self:GetDestructionAllowed(destructionAllowedTable)
            end

            if destructionAllowedTable.allowed then

                DestroyEntitySafe(self)
                self.timeToDestroy = nil

            end

        end

    end

end

local function SharedUpdate(self, deltaTime)

    if Server then
        UpdateTimeToDestroy(self, deltaTime)
	--[[elseif Client then
		self:_UpdateDeathEffect()--]]
    end

end

function RagdollMixin:OnUpdate(deltaTime)
    PROFILE("RagdollMixin:OnUpdate")
    SharedUpdate(self, deltaTime)
end

function RagdollMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end
