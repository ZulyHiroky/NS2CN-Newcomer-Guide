
local oldOnCreate = Alien.OnCreate
function Alien:OnCreate()
	oldOnCreate(self)
	self:SetDarkVision(true)
end