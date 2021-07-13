

if Server then
	local function AddModPanel() error "Can't add mod panels after the map has loaded!" end

	local old = Gamerules.OnMapPostLoad
	function Gamerules:OnMapPostLoad()
		old(self)
		InitializeModPanels()
		_G.AddModPanel = AddModPanel
	end
end
