-- twiliteblue

local function ModLoader_SetupFileHook(file, replace_type)
    local load_file = string.gsub(file, "lua/", "lua/ClogBalance/", 1)

    ModLoader.SetupFileHook(file,  load_file, replace_type)
end

ModLoader_SetupFileHook( "lua/BalanceHealth.lua", "post" )
ModLoader_SetupFileHook( "lua/Clog.lua", "post" )
ModLoader_SetupFileHook( "lua/Weapons/Alien/ClogAbility.lua", "post" )
--ModLoader_SetupFileHook( "lua/Weapons/Alien/DropStructureAbility.lua", "post" )

if AddModPanel then
    local kClogBalanceMaterial = PrecacheAsset("materials/clogbalance/clogbalance.material")
    AddModPanel(kClogBalanceMaterial, "http://steamcommunity.com/sharedfiles/filedetails/?id=1934484465")

end