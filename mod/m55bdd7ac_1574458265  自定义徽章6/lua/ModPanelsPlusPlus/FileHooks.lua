ModLoader.SetupFileHook("lua/Gamerules.lua", "lua/ModPanelsPlusPlus/Gamerules.lua", "post")

if Shared.GetBuildNumber() < 315 then
	ModLoader.SetupFileHook("lua/ReadyRoomPlayer.lua", "lua/ModPanelsPlusPlus/ReadyRoomPlayer.lua", "replace")
	ModLoader.SetupFileHook("lua/Player.lua", "lua/ModPanelsPlusPlus/Player.lua", "post")
end

kModPanels = {}

local dot = string.byte('.')
local slash = string.byte('/')

local function parse_path(path)
	local start, stop = 1, #path
	repeat
		stop = stop - 1
	until path:byte(stop+1) == dot
	repeat
		start = start + 1
	until path:byte(start-1) == slash
	return path:sub(start, stop)
end

function AddModPanel(values, maybe_url)
	assert(#kModPanels < 255, "Can not add more mod panels! Max: 255")
	if type(values) == "string" then
		values = {
			material = values,
			url      = maybe_url
		}
	end
	assert(values.material, "Material file required!")
	if not values.name then
		values.name = parse_path(values.material)
	end
	PrecacheAsset(values.material)
	table.insert(kModPanels, values)
end

local panels = {}
Shared.GetMatchingFileNames("modpanels/*.material", true, panels)
for _, file in ipairs(panels) do
	local data = {}
	setfenv(assert(loadfile(file)), data)()
	data.panel = nil
	data.material = file
	local name = parse_path(file)
	local lua_file = "modpanels/" .. name .. ".lua"
	if GetFileExists(lua_file) then
		assert(loadfile(lua_file))(data)
	end
	data.name = data.name or name
	Log("Mod panel %s detected", data.name)
	AddModPanel(data)
end
