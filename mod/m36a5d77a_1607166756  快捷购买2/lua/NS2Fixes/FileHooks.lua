
-- Setup Filehooks based on the folder structure inside the FileHooks folder
-- Warning: Paths are case sensitive at Linux
local function SetupFilehookFolder(folderPath, modPath, hookType)
	local files = {}
	local path = string.format("%s*.lua", folderPath)
	Shared.GetMatchingFileNames(path, true, files)

	--Log("Loading %s Filehooks: %s", hookType, files)

	for i = 1, #files do
		local filePath = files[i]
		local vanillaFilePath = string.gsub(filePath, modPath, "")
		ModLoader.SetupFileHook(vanillaFilePath, filePath, hookType)
	end

end

local function SetupFilehookFolders(modPath)
	if Server then
		Server.AddRestrictedFileHashes(modPath .. "/*")
	end
	local folders = { "Halt", "Post", "Pre", "Replace" }
	for i = 1, #folders do
		local hookType = folders[i]
		local modPath = string.format("%s/%s/", modPath, hookType)
		local folderPath = string.format("lua/%s", modPath)
		SetupFilehookFolder(folderPath, modPath, string.lower(hookType))
	end
end

local fixes = { 
--"BotBrain",
"CommanderSensor",
--"DamageIndicator",
"DoorsByDragon",
"Hallucinations",
"Ladder",
"Railgun",
"Robotics",
"Cheats",
--"Xenocide",
"OnosCrouch",
"ArmorFix",
"Voting",
"ForceEvenTeams",
"SetPoseParam",
--"IPSpawn",
"SpecAlien"
}

for i = 1, #fixes do

	local fix = fixes[i]
	local hookedFolder = string.format("NS2Fixes/%s", fix)
	SetupFilehookFolders(hookedFolder)
	
end
