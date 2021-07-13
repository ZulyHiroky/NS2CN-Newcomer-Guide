--=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
--
-- BuyMenuHotKeys\bmhk_ClientHooks.lua
--
--    Created by:   Chris Baker (chris.l.baker@gmail.com)
--    License:      Public Domain
--
-- Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
-- Worlds Entertainment, Inc. Natural Selection 2, its Assets, Source Code, Documentation, and
-- Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
-- ========= For more information, visit http:--www.unknownworlds.com ============================

if Client then

local function BMHK_Process_Hooks()
    --HPrint("Buy Menu Hotkeys mod -- processing file hooks")
    local ret,err = ModLoader.SetupFileHook("lua/menu/main_menu.css", "lua/BuyMenuHotKeys/bmhk_Client.lua", "post")
	ModLoader.SetupFileHook("lua/menu2/NavBar/Screens/Options/Mods/ModsMenuData.lua", "lua/BuyMenuHotKeys/ModsMenuData.lua", "post")
    if not ret then
        HPrint("Buy Menu Hotkeys mod -- failed: %s", err)
    end
end

BMHK_Process_Hooks()

end -- Client

--=== Change Log =================================================================================
--
-- 2.30
-- - Initial revision
-- - Very basic functionality, loads the entire mod after the main menu has loaded its css file.
--
--================================================================================================