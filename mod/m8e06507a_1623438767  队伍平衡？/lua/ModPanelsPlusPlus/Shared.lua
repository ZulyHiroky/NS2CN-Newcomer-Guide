Script.Load("lua/ModPanelsPlusPlus/ModPanel.lua")

if Server then
	function InitializeModPanels()
		Log "Creating mod panels"

		local spawnpoints = Server.readyRoomSpawnList

		local config = LoadConfigFile("ModPanels.json", {})
		local config_changed  = false

		for index, values in ipairs(kModPanels) do
			local name = values.name

			if config[name] == nil then
				config[name] = true
				config_changed  = true
			end

			if config[name] then
				local spawnpoint = spawnpoints[
					(index - 1) % #spawnpoints + 1
				]:GetOrigin()

				local panel = CreateEntity(
					ModPanel.kMapName,
					spawnpoint
				)

				panel:SetModPanelId(index)
				panel:ReInitialize()
				panel:SetOrigin(spawnpoint)

				Print("Mod panel '%s' created", panel.name)
			end
		end

		if config_changed  then
			SaveConfigFile("ModPanels.json", config, true)
		end
	end
end
