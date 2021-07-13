--=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
--
-- BuyMenuHotKeys\bmhk_marine.lua
--
--    Created by:   Chris Baker (chris.l.baker@gmail.com)
--    License:      Public Domain
--
-- Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
-- Worlds Entertainment, Inc. Natural Selection 2, its Assets, Source Code, Documentation, and
-- Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
-- ========= For more information, visit http:--www.unknownworlds.com ============================

-- Source the constants used in the key mapping table below
Script.Load("lua/TechTreeConstants.lua")

local gmbm_patched = false

-- This list maps keybind names to TechId values
local techid_to_keybind =
{
    [kTechId.LayMines]             = kBMHKMinesKey,
    [kTechId.Shotgun]              = kBMHKShotgunKey,
    [kTechId.Welder]               = kBMHKWelderKey,
    [kTechId.ClusterGrenade]       = kBMHKClusterKey,
    [kTechId.GasGrenade]           = kBMHKNervegasKey,
    [kTechId.PulseGrenade]         = kBMHKPulseKey,
    [kTechId.GrenadeLauncher]      = kBMHKGLKey,
    [kTechId.Flamethrower]         = kBMHKFlamethrowerKey,
    [kTechId.HeavyMachineGun]      = kBMHKHMGKey,

    [kTechId.Jetpack]              = kBMHKJetpackKey,
    [kTechId.Exosuit]              = kBMHKExominiKey,
    [kTechId.ClawRailgunExosuit]   = kBMHKExorailKey,
    [kTechId.DualMinigunExosuit]   = kBMHKExominiKey,
    [kTechId.DualRailgunExosuit]   = kBMHKExorailKey,

    -- if they ever add this feature back in it should "just work"
    [kTechId.UpgradeToDualMinigun] = kBMHKExodualKey,
    [kTechId.UpgradeToDualRailgun] = kBMHKExodualKey,
}

local function BMHK_Check_Keybinds(self, key, down)
    local retval = false

    -- Iterate through available purchases
    for _, item in ipairs(self.itemButtons) do
        if techid_to_keybind[item.TechId] and GetIsBinding(key, techid_to_keybind[item.TechId]) then
            retval = true

            -- Attempt Purchase
            if not down then 
                local researched = MarineBuy_IsResearched(item.TechId)
                local itemCost = MarineBuy_GetCosts(item.TechId)
                local canAfford = PlayerUI_GetPlayerResources() >= itemCost
                local hasItem = PlayerUI_GetHasItem(item.TechId)
                if researched and canAfford and not hasItem then
                    --Print("Purchasing %s", EnumToString(kTechId, item.TechId))   
                    MarineBuy_PurchaseItem(item.TechId)
                    MarineBuy_OnClose()
                    self.closingMenu = true
                    MarineBuy_Close()
                end
            end -- if not down
            
            break
        end -- if key matches itemButton binding
    end -- for each itemButton

    return retval
end -- BMHK_Check_Keybinds

local function BMHK_Update_Button_Labels(self)
    local fullhud = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
    local uiscale = Client.GetOptionFloat("bmhk_ui_scale", kBMHKDefaultUIScale)
    local vuiscale = Vector(uiscale, uiscale, 0)
	local uishow = Client.GetOptionBoolean("bmhk_showlabels", true)

    -- Iterate through available purchase buttons
    for i, item in ipairs(self.itemButtons) do
        if (nil == item.bmhk_hotkey_graphic) then
            local keybind_name = techid_to_keybind[item.TechId]
            if (nil == keybind_name) then
                Print("BMHK: TechId %d [%s] not matched in keybinds list", item.TechId, Locale.ResolveString(LookupTechData(item.TechId, kTechDataDisplayName, "")))
                item.bmhk_hotkey_graphic = 1
            elseif "None" == BindingsUI_GetInputValue(keybind_name) then
                --Print("BMHK: TechId %d [%s] is not bound", item.TechId, Locale.ResolveString(LookupTechData(item.TechId, kTechDataDisplayName, "")))
                item.bmhk_hotkey_graphic = 1
            else
                -- create a new button
                item.bmhk_hotkey_graphic, item.bmhk_hotkey_text = GUICreateButtonIcon(keybind_name, false)
                item.bmhk_hotkey_graphic:SetAnchor(GUIItem.Left, GUIItem.Center)
                item.Button:AddChild(item.bmhk_hotkey_graphic)
            end -- keybind_name...

        else
            -- item.bmhk_hotkey_graphic not nil
            if (item.bmhk_hotkey_graphic ~= 1) then
                -- disable the button graphic if HUD is set below full
                if fullhud and uishow then
                    -- scale the button and text label
                    item.bmhk_hotkey_text:SetScale(vuiscale)
                    item.bmhk_hotkey_graphic:SetScale(vuiscale)

                    -- update the position
                    local size = item.bmhk_hotkey_graphic:GetSize()
                    local scaledsize = item.bmhk_hotkey_graphic:GetScaledSize()
                    local xcorr = (size.x-scaledsize.x)*.5
                    local ycorr = (size.y-scaledsize.y)*.5
                    item.bmhk_hotkey_graphic:SetPosition(Vector(-(size.x+GUIScale(16)-xcorr),-(size.y/2),0))
                    item.bmhk_hotkey_text:SetPosition(Vector(xcorr,ycorr,0))

                    -- set visible
                    item.bmhk_hotkey_graphic:SetIsVisible(true)
                else
                    item.bmhk_hotkey_graphic:SetIsVisible(false)
                end
            end -- item.bmhk_hotkey_graphic valid

        end -- item.bmhk_hotkey_graphic...
    end -- for item
end -- BMHK_Update_Button_Labels

-- We will extend MarineBuy_OnOpen in order to patch GUIMarineBuyMenu
local originalMBOnOpen = MarineBuy_OnOpen
function MarineBuy_OnOpen()
    -- GUIMarineBuyMenu should now be loaded -- commence patching functions
    if (not gmbm_patched) and GUIMarineBuyMenu then
        --Print("Patching GUIMarineBuyMenu")

        -- We will extend GUIMarineBuyMenu:SendKeyEvent
        local originalGMBMSendKeyEvent = GUIMarineBuyMenu.SendKeyEvent
        function GUIMarineBuyMenu:SendKeyEvent(key, down)
            local stop = false

            stop = BMHK_Check_Keybinds(self, key, down)

            if not stop then
                stop = originalGMBMSendKeyEvent(self, key, down)
            end
            return stop
        end -- GUIMarineBuyMenu:SendKeyEvent

        -- We will extend GUIMarineBuyMenu:_UpdateItemButtons
        local originalGMBM_UpdateButtons = GUIMarineBuyMenu._UpdateItemButtons
        function GUIMarineBuyMenu:_UpdateItemButtons(deltaTime)
            originalGMBM_UpdateButtons(self, deltaTime)
            BMHK_Update_Button_Labels(self)
        end

        gmbm_patched = true
    end -- if not gmbm_patched

    originalMBOnOpen()
end -- MarineBuy_OnOpen

--=== Change Log =================================================================================
--
-- 2.00
-- - Initial revision
--
-- 2.02
-- - Check that GUIMarineBuyMenu actually exists before dereferencing
--
-- 2.10
-- - Button labels will be hidden if Minimal-HUD mode is enabled
-- - Button labels will be scaled based on bmhk_ui_scale option
--
-- 2.30
-- - Fix protolab lockup
-- - Add support for new dual exo protolab purchases
--
-- 2.40
-- - Add support for HMG
-- - Don't show label if key doesn't have a valid binding
-- - Correct the label graphic's text and background position
--
--================================================================================================