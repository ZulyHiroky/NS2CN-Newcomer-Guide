--=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
--
-- BuyMenuHotKeys\bmhk_Client.lua
--
--    Created by:   Chris Baker (chris.l.baker@gmail.com)
--    License:      Public Domain
--
-- Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
-- Worlds Entertainment, Inc. Natural Selection 2, its Assets, Source Code, Documentation, and
-- Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
-- ========= For more information, visit http:--www.unknownworlds.com ============================

kBMHKVersion = "2.40"

local verstring = "Buy Menu Hotkeys Mod version "
HPrint(verstring .. kBMHKVersion)

-- Source the common mod code
Script.Load("lua/BuyMenuHotKeys/bmhk_common.lua")

-- Source the Alien Buy Menu code
Script.Load("lua/BuyMenuHotKeys/bmhk_alien.lua")

-- Source the Marine Buy Menu code
Script.Load("lua/BuyMenuHotKeys/bmhk_marine.lua")

--
--if AddModPanel then
--    local kbhkmMaterial = PrecacheAsset("materials/bmhk/bmhk.material")
--    AddModPanel(kbhkmMaterial, "http://steamcommunity.com/sharedfiles/filedetails/?id=1951316468")
--end

--=== Change Log =================================================================================
--
-- 0.80
-- - Initial revision
--
-- 1.10
-- - Reorganized Files
-- - Moved version string to this file
--
-- 2.00
-- - New version adds Marine hotkeys
--
-- 2.01
-- - New version avoids marking key conflicts in menu
--
-- 2.02
-- - New version avoids interfering too much with combat mode
--
-- 2.10
-- - New version adds support for Minimal-HUD mode and scaled button labels
--
-- 2.20
-- - Update for Build 263
--
-- 2.21
-- - Update for compatibility with new MainMenuModLoader
--
-- 2.21
-- - Update for Build 274
--
-- 2.30
-- - Update for Build 297
-- - Fixes lockup with protolab due to new Exo TechIds
-- - Change DebugPrint to HPrint
-- - Adds support for new ModLoader hook functionality
--
-- 2.40
-- - Update for Build 299
-- - Add keybinding for HMG
-- - Reset keybinding defaults and order
-- - Replace phantom ability with new abilities: camouflage, vampirism, crush, and focus
-- - Update to match new game rules for which abilities correspond to which hives
-- - Don't show label if key doesn't have a valid binding
-- - Correct the label graphic's text and background position
--
--================================================================================================