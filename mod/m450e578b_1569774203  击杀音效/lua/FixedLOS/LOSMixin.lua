Script.Load "lua/Globals.lua"

LOSMixin = {
	type = "LOS",
	expectedMixins = {
		Team = "Needed for calls to GetTeamNumber().",
	},
	optionalCallbacks = {
		OverrideCheckVision = "Return true if this entity can see, false otherwise"
	},
	networkVars = {
		sighted = "boolean"
	}
}

local kLOSTimeout                = 2
local kLOSMaxDistanceSquared     = 7^2
local kLOSCheckInterval          = 0.2

local rel_mask = "exclude_relevancy_mask_not_sighted"

function LOSMixin:GetIsSighted()
	return self.sighted
end

function LOSMixin:MarkNearbyDirtyImmediately() end

if Server then
	local function LateInit(self)
		local team = self:GetTeamNumber()

		self[rel_mask] = bit.bor(
			kRelevantToTeam1Unit,
			kRelevantToTeam2Unit,
			kRelevantToReadyRoom,

			team == 1 and kRelevantToTeam1Commander or
			team == 2 and kRelevantToTeam2Commander or
			0
		)
		if not self.sighted then
			self:SetExcludeRelevancyMask(self[rel_mask])
		end
	end

	local function Sighted(self)
		self.timeSighted   = Shared.GetTime()
		self.originSighted = self:GetOrigin()

		self:SetExcludeRelevancyMask(0x1F)

		--[[
		if LOSFixDebug then
			Log("Sighted: %s @ %s | %s", self, self:GetLocationName(), self:GetOrigin())
		end
		--]]

		self.sighted = true
		self:OnSighted(true)
	end

	local function NotSighted(self)
		self:SetExcludeRelevancyMask(self[rel_mask] or 3)
		self.sighted = false
		self:OnSighted(false)
	end

	local function CheckIsSighted(self)
		if self.sighted and not self.parasited and (
			Shared.GetTime() - self.timeSighted > kLOSTimeout or
			(self:GetOrigin() - self.originSighted):GetLengthSquared() > kLOSMaxDistanceSquared
		) then
			NotSighted(self)
		end

		return true
	end

	function LOSMixin:__initmixin()
		self.timeSighted      = -1000
		self.originSighted    = Vector(-2^10, -2^10, -2^10)

		LateInit(self)
		NotSighted(self)

		self:AddTimedCallback(LateInit, 0)
		self:AddTimedCallback(CheckIsSighted, kLOSCheckInterval)
	end

	function LOSMixin:OnSighted(sighted)
	end

	function LOSMixin:OnDamageDone(_, target)
		if not HasMixin(target, "LOS") then return end
		if target.GetIsAlive and not target:GetIsAlive() then return end
		if target:GetTeamNumber() == self:GetTeamNumber() then return end

		Sighted(target)
	end

	function LOSMixin:SetIsSighted(sighted)
		if sighted then
			Sighted(self)
		else
			NotSighted(self)
		end
	end

	LOSMixin.SetParasited = Sighted

	LOSMixin.OnKill               = NotSighted
	LOSMixin.OnUseGorgeTunnel     = NotSighted
	LOSMixin.OnPhaseGateEntry     = NotSighted
	LOSMixin.TriggerBeaconEffects = NotSighted
	LOSMixin.OnTeamChange         = NotSighted
	LOSMixin.OnTeleportEnd        = NotSighted

else
	function LOSMixin:__initmixin()
	end
end
