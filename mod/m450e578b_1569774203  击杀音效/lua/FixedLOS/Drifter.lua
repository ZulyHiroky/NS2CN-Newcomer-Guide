if not Server then return end

local kPhysicsMask = 0 -- What can we not see through?
for _, v in ipairs {
	"Default",
	"BigStructures",
	"MediumStructures",
	"SmallStructures",
	"Whip",
	"CommanderProps",
	"CommanderUnit",
	"CommanderBuild",
} do
	kPhysicsMask = bit.bor(kPhysicsMask, PhysicsGroup[v .. "Group"])
end

local function Iterate(entities, time, origin, team)
	for i = 1, #entities do
		local ent = entities[i]
		if ent:GetTeamNumber() ~= team and not ent.fullyCloaked and time - ent.timeSighted > 1 then
			local ent_origin = ent.GetModelOrigin and ent:GetModelOrigin() or ent:GetOrigin()
			local trace = Shared.TraceRay(origin, ent_origin, CollisionRep.LOS, kPhysicsMask)
			if trace.entity == ent or trace.fraction == 1 then
				ent:SetIsSighted(true)
			end
		end
	end
end

local function Check(self)
	local time = Shared.GetTime()
	local coords = self:GetCoords()
	local origin = coords.origin
	local team   = self:GetTeamNumber()

	Iterate(
		Shared.GetEntitiesWithTagInRange("LOS", origin, 15),
		time,
		origin,
		team
	)

	return true
end

local old = Drifter.OnCreate
function Drifter:OnCreate()
	old(self)

	self:AddTimedCallback(Check, 0.5)
end
