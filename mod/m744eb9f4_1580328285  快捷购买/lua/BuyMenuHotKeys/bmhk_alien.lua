--=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
--
-- BuyMenuHotKeys\bmhk_alien.lua
--
--    Created by:   Chris Baker (chris.l.baker@gmail.com)
--    License:      Public Domain
--
-- Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
-- Worlds Entertainment, Inc. Natural Selection 2, its Assets, Source Code, Documentation, and
-- Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
-- ========= For more information, visit http:--www.unknownworlds.com ============================

local gabm_patched = false


--[[ CLB-
 * This function duplicated from GUIAlienBuyMenu.lua verbatim
 --]]
local function GetUpgradeCostForLifeForm(player, alienType, upgradeId)

    if player then
    
        local alienTechNode = GetAlienTechNode(alienType, true)
        if alienTechNode then

            if player:GetTechId() == alienTechNode:GetTechId() and player:GetHasUpgrade(upgradeId) then
                return 0
            end    
        
            return LookupTechData(alienTechNode:GetTechId(), kTechDataUpgradeCost, 0)
            
        end
    
    end
    
    return 0

end

--[[ CLB-
 * This function duplicated from GUIAlienBuyMenu.lua verbatim
 --]]
local function MarkAlreadyPurchased( self )
    local isAlreadySelectedAlien = not self:GetNewLifeFormSelected()
    for i, currentButton in ipairs(self.upgradeButtons) do
        currentButton.Purchased = isAlreadySelectedAlien and AlienBuy_GetUpgradePurchased( currentButton.TechId )
    end
end

-- TODO: This function probably needs some refactoring...
local function BMHK_Check_Keybinds(self, key, down)
    local crushbutton = nil
    local carabutton = nil
    local regenbutton = nil
    --local phantombutton = nil
    local focusbutton = nil
    local vampbutton = nil
    local aurabutton = nil
    local adrenbutton = nil
    local celeritybutton = nil
    local camouflagebutton = nil
    local prevselection = nil
    local retval = false
    local combat_mode_not_active = true

    -- check whether Combat Mode is active
    if (kCombatModActive ~= nil) and (kCombatModActive == true) then
        combat_mode_not_active = false
    end

    -- get current lifeform status
    if (self.selectedAlienType) then
        prevselection = self.selectedAlienType
    end

    -- get current upgrade status
    for _, currentButton in ipairs(self.upgradeButtons) do
        if currentButton.TechId == kTechId.Vampirism then
            vampbutton = currentButton
        elseif currentButton.TechId == kTechId.Carapace then
            carabutton = currentButton
        elseif currentButton.TechId == kTechId.Regeneration then
            regenbutton = currentButton
        --[[elseif currentButton.TechId == kTechId.Phantom then
            phantombutton = currentButton--]]
        elseif currentButton.TechId == kTechId.Focus then
            focusbutton = currentButton
        elseif currentButton.TechId == kTechId.Camouflage then
            camouflagebutton = currentButton
        elseif currentButton.TechId == kTechId.Aura then
            aurabutton = currentButton
        elseif currentButton.TechId == kTechId.Adrenaline then
            adrenbutton = currentButton
        elseif currentButton.TechId == kTechId.Celerity then
            celeritybutton = currentButton
		elseif currentButton.TechId == kTechId.Crush then
            crushbutton = currentButton  
		--[[elseif currentButton.TechId == kTechId.Camouflage then
            camouflagebutton = currentButton--]]
        end -- currentButton.TechId...
    end -- for upgradeButtons

    -- check upgrade keys
    if GetIsBinding(key, kBMHKCrushKey) then
        if not down then
            --Print("--Toggle Crush")
            if crushbutton and not crushbutton.Selected and AlienBuy_GetTechAvailable(kTechId.Crush) then
                if combat_mode_not_active then
                    if adrenbutton and adrenbutton.Selected then
                        adrenbutton.Selected = false
                        adrenbutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Adrenaline)
                        AlienBuy_OnUpgradeDeselected()
                    end
                    if celeritybutton and celeritybutton.Selected then
                        celeritybutton.Selected = false
                        celeritybutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Celerity)
                        AlienBuy_OnUpgradeDeselected()
                    end
                end
                crushbutton.Selected = true
                crushbutton.Purchased = false
                table.insertunique(self.upgradeList, kTechId.Crush)
                AlienBuy_OnUpgradeSelected()
            elseif crushbutton and crushbutton.Selected then
                crushbutton.Selected = false
                crushbutton.Purchased = false
                table.removevalue(self.upgradeList, kTechId.Crush)
                AlienBuy_OnUpgradeDeselected()
            end -- if crushbutton...
        end -- if not down
        retval = true
    end -- if key == bmhk_crush

    if GetIsBinding(key, kBMHKCarapaceKey) then
        if not down then
            --Print("--Toggle Carapace")
            if carabutton and not carabutton.Selected and AlienBuy_GetTechAvailable(kTechId.Carapace) then
                if combat_mode_not_active then
                    if regenbutton and regenbutton.Selected then
                        regenbutton.Selected = false
                        regenbutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Regeneration)
                        AlienBuy_OnUpgradeDeselected()
                    end
                    if vampbutton and vampbutton.Selected then
                        vampbutton.Selected = false
                        vampbutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Vampirism)
                        AlienBuy_OnUpgradeDeselected()
                    end
                end
                carabutton.Selected = true
                carabutton.Purchased = false
                table.insertunique(self.upgradeList, kTechId.Carapace)
                AlienBuy_OnUpgradeSelected()
            elseif carabutton and carabutton.Selected then
                carabutton.Selected = false
                carabutton.Purchased = false
                table.removevalue(self.upgradeList, kTechId.Carapace)
                AlienBuy_OnUpgradeDeselected()
            end -- if carabutton...
        end -- if not down
        retval = true
    end -- if key == bmhk_carapace

    if GetIsBinding(key, kBMHKRegenerationKey) then
        if not down then
            --Print("--Toggle Regeneration")
            if regenbutton and not regenbutton.Selected and AlienBuy_GetTechAvailable(kTechId.Regeneration) then
                if combat_mode_not_active then
                    if carabutton and carabutton.Selected then
                        carabutton.Selected = false
                        carabutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Carapace)
                        AlienBuy_OnUpgradeDeselected()
                    end
                    if vampbutton and vampbutton.Selected then
                        vampbutton.Selected = false
                        vampbutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Vampirism)
                        AlienBuy_OnUpgradeDeselected()
                    end
                end
                regenbutton.Selected = true
                regenbutton.Purchased = false
                table.insertunique(self.upgradeList, kTechId.Regeneration)
                AlienBuy_OnUpgradeSelected()
            elseif regenbutton and regenbutton.Selected then
                regenbutton.Selected = false
                regenbutton.Purchased = false
                table.removevalue(self.upgradeList, kTechId.Regeneration)
                AlienBuy_OnUpgradeDeselected()
            end -- if regenbutton...
        end -- if not down
        retval = true
    end -- if key == bmhk_regeneration

    --[[if GetIsBinding(key, kBMHKPhantomKey) then
        if not down then
            --Print("--Toggle Phantom")
            if phantombutton and not phantombutton.Selected and AlienBuy_GetTechAvailable(kTechId.Phantom) then
                if combat_mode_not_active and aurabutton and aurabutton.Selected then
                    aurabutton.Selected = false
                    aurabutton.Purchased = false
                    table.removevalue(self.upgradeList, kTechId.Aura)
                    AlienBuy_OnUpgradeDeselected()
                end
                phantombutton.Selected = true
                phantombutton.Purchased = false
                table.insertunique(self.upgradeList, kTechId.Phantom)
                AlienBuy_OnUpgradeSelected()
            elseif phantombutton and phantombutton.Selected then
                phantombutton.Selected = false
                phantombutton.Purchased = false
                table.removevalue(self.upgradeList, kTechId.Phantom)
                AlienBuy_OnUpgradeDeselected()
            end -- if phantombutton...
        end -- if not down
        retval = true
    end -- if key == bmhk_phantom--]]

    if GetIsBinding(key, kBMHKFocusKey) then
        if not down then
            --Print("--Toggle Focus")
            if focusbutton and not focusbutton.Selected and AlienBuy_GetTechAvailable(kTechId.Focus) then
                --[[if combat_mode_not_active and phantombutton and phantombutton.Selected then
                    phantombutton.Selected = false
                    phantombutton.Purchased = false
                    table.removevalue(self.upgradeList, kTechId.Phantom)
                    AlienBuy_OnUpgradeDeselected()
                end--]]
                if combat_mode_not_active then
                    if camouflagebutton and camouflagebutton.Selected then
                        camouflagebutton.Selected = false
                        camouflagebutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Camouflage)
                        AlienBuy_OnUpgradeDeselected()
                    end
                    if aurabutton and aurabutton.Selected then
                        aurabutton.Selected = false
                        aurabutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Aura)
                        AlienBuy_OnUpgradeDeselected()
                    end
                end
                focusbutton.Selected = true
                focusbutton.Purchased = false
                table.insertunique(self.upgradeList, kTechId.Focus)
                AlienBuy_OnUpgradeSelected()
            elseif focusbutton and focusbutton.Selected then
                focusbutton.Selected = false
                focusbutton.Purchased = false
                table.removevalue(self.upgradeList, kTechId.Focus)
                AlienBuy_OnUpgradeDeselected()
            end -- if focusbutton...
        end -- if not down
        retval = true
    end -- if key == bmhk_focus

    if GetIsBinding(key, kBMHKVampirismKey) then
        if not down then
            --Print("--Toggle Vampirism")
            if vampbutton and not vampbutton.Selected and AlienBuy_GetTechAvailable(kTechId.Vampirism) then
                --[[if combat_mode_not_active and phantombutton and phantombutton.Selected then
                    phantombutton.Selected = false
                    phantombutton.Purchased = false
                    table.removevalue(self.upgradeList, kTechId.Phantom)
                    AlienBuy_OnUpgradeDeselected()
                end--]]
                if combat_mode_not_active then
                    if regenbutton and regenbutton.Selected then
                        regenbutton.Selected = false
                        regenbutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Regeneration)
                        AlienBuy_OnUpgradeDeselected()
                    end
                    if carabutton and carabutton.Selected then
                        carabutton.Selected = false
                        carabutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Carapace)
                        AlienBuy_OnUpgradeDeselected()
                    end
                end
                vampbutton.Selected = true
                vampbutton.Purchased = false
                table.insertunique(self.upgradeList, kTechId.Vampirism)
                AlienBuy_OnUpgradeSelected()
            elseif vampbutton and vampbutton.Selected then
                vampbutton.Selected = false
                vampbutton.Purchased = false
                table.removevalue(self.upgradeList, kTechId.Vampirism)
                AlienBuy_OnUpgradeDeselected()
            end -- if vampbutton...
        end -- if not down
        retval = true
    end -- if key == bmhk_vampirism

    if GetIsBinding(key, kBMHKAuraKey) then
        if not down then
            --Print("--Toggle Aura")
            if aurabutton and not aurabutton.Selected and AlienBuy_GetTechAvailable(kTechId.Aura) then
                --[[if combat_mode_not_active and phantombutton and phantombutton.Selected then
                    phantombutton.Selected = false
                    phantombutton.Purchased = false
                    table.removevalue(self.upgradeList, kTechId.Phantom)
                    AlienBuy_OnUpgradeDeselected()
                end--]]
                if combat_mode_not_active then
                    if camouflagebutton and camouflagebutton.Selected then
                        camouflagebutton.Selected = false
                        camouflagebutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Camouflage)
                        AlienBuy_OnUpgradeDeselected()
                    end
                    if focusbutton and focusbutton.Selected then
                        focusbutton.Selected = false
                        focusbutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Focus)
                        AlienBuy_OnUpgradeDeselected()
                    end
                end
                aurabutton.Selected = true
                aurabutton.Purchased = false
                table.insertunique(self.upgradeList, kTechId.Aura)
                AlienBuy_OnUpgradeSelected()
            elseif aurabutton and aurabutton.Selected then
                aurabutton.Selected = false
                aurabutton.Purchased = false
                table.removevalue(self.upgradeList, kTechId.Aura)
                AlienBuy_OnUpgradeDeselected()
            end -- if aurabutton...
        end -- if not down
        retval = true
    end -- if key == bmhk_aura
    
    if GetIsBinding(key, kBMHKAdrenalineKey) then
        if not down then
            --Print("--Toggle Adrenaline")
            if adrenbutton and not adrenbutton.Selected and AlienBuy_GetTechAvailable(kTechId.Adrenaline) then
                if combat_mode_not_active then
                    if celeritybutton and celeritybutton.Selected then
                        celeritybutton.Selected = false
                        celeritybutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Celerity)
                        AlienBuy_OnUpgradeDeselected()
                    end
                    if crushbutton and crushbutton.Selected then
                        crushbutton.Selected = false
                        crushbutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Crush)
                        AlienBuy_OnUpgradeDeselected()
                    end
                end
                adrenbutton.Selected = true
                adrenbutton.Purchased = false
                table.insertunique(self.upgradeList, kTechId.Adrenaline)
                AlienBuy_OnUpgradeSelected()
            elseif adrenbutton and adrenbutton.Selected then
                adrenbutton.Selected = false
                adrenbutton.Purchased = false
                table.removevalue(self.upgradeList, kTechId.Adrenaline)
                AlienBuy_OnUpgradeDeselected()
            end -- if adrenbutton...
        end -- if not down
        retval = true
    end -- if key == bmhk_adrenaline
    
    if GetIsBinding(key, kBMHKCelerityKey) then
        if not down then
            --Print("--Toggle Celerity")
            if celeritybutton and not celeritybutton.Selected and AlienBuy_GetTechAvailable(kTechId.Celerity) then
                if combat_mode_not_active then
                    if adrenbutton and adrenbutton.Selected then
                        adrenbutton.Selected = false
                        adrenbutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Adrenaline)
                        AlienBuy_OnUpgradeDeselected()
                    end
                    if crushbutton and crushbutton.Selected then
                        crushbutton.Selected = false
                        crushbutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Crush)
                        AlienBuy_OnUpgradeDeselected()
                    end
                end
                celeritybutton.Selected = true
                celeritybutton.Purchased = false
                table.insertunique(self.upgradeList, kTechId.Celerity)
                AlienBuy_OnUpgradeSelected()
            elseif celeritybutton and celeritybutton.Selected then
                celeritybutton.Selected = false
                celeritybutton.Purchased = false
                table.removevalue(self.upgradeList, kTechId.Celerity)
                AlienBuy_OnUpgradeDeselected()
            end -- if celeritybutton...
        end -- if not down
        retval = true
    end -- if key == bmhk_celerity

    if GetIsBinding(key, kBMHKCamouflageKey) then
        if not down then
            --Print("--Toggle Camouflage")
            if camouflagebutton and not camouflagebutton.Selected and AlienBuy_GetTechAvailable(kTechId.Camouflage) then
                if combat_mode_not_active then
                    if aurabutton and aurabutton.Selected then
                        aurabutton.Selected = false
                        aurabutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Aura)
                        AlienBuy_OnUpgradeDeselected()
                    end
                    if focusbutton and focusbutton.Selected then
                        focusbutton.Selected = false
                        focusbutton.Purchased = false
                        table.removevalue(self.upgradeList, kTechId.Focus)
                        AlienBuy_OnUpgradeDeselected()
                    end
                end
                camouflagebutton.Selected = true
                camouflagebutton.Purchased = false
                table.insertunique(self.upgradeList, kTechId.Camouflage)
                AlienBuy_OnUpgradeSelected()
            elseif camouflagebutton and camouflagebutton.Selected then
                camouflagebutton.Selected = false
                camouflagebutton.Purchased = false
                table.removevalue(self.upgradeList, kTechId.Camouflage)
                AlienBuy_OnUpgradeDeselected()
            end -- if camouflagebutton...
        end -- if not down
        retval = true
    end -- if key == bmhk_camouflage

    -- check lifeform keys
    if GetIsBinding(key, kBMHKSkulkKey) then
        if not down then
            self.selectedAlienType = AlienTechIdToIndex(kTechId.Skulk)
            if self.selectedAlienType ~= prevselection then
                AlienBuy_OnSelectAlien("Skulk")
                if combat_mode_not_active then
                    MarkAlreadyPurchased(self)
                    self:SetPurchasedSelected()
                end
                --Print("--Selected Skulk")
            end
        end
        retval = true
    end -- if key == bmhk_skulk

    if GetIsBinding(key, kBMHKGorgeKey) then
        if not down then
            self.selectedAlienType = AlienTechIdToIndex(kTechId.Gorge)
            if self.selectedAlienType ~= prevselection then
                AlienBuy_OnSelectAlien("Gorge")
                if combat_mode_not_active then
                    MarkAlreadyPurchased(self)
                    self:SetPurchasedSelected()
                end
                --Print("--Selected Gorge")
            end
        end
        retval = true
    end -- if key == bmhk_gorge

    if GetIsBinding(key, kBMHKLerkKey) then
        if not down then
            self.selectedAlienType = AlienTechIdToIndex(kTechId.Lerk)
            if self.selectedAlienType ~= prevselection then
                AlienBuy_OnSelectAlien("Lerk")
                if combat_mode_not_active then
                    MarkAlreadyPurchased(self)
                    self:SetPurchasedSelected()
                end
                --Print("--Selected Lerk")
            end
        end
        retval = true
    end -- if key == bmhk_lerk

    if GetIsBinding(key, kBMHKFadeKey) then
        if not down then
            self.selectedAlienType = AlienTechIdToIndex(kTechId.Fade)
            if self.selectedAlienType ~= prevselection then
                AlienBuy_OnSelectAlien("Fade")
                if combat_mode_not_active then
                    MarkAlreadyPurchased(self)
                    self:SetPurchasedSelected()
                end
                --Print("--Selected Fade")
            end
        end
        retval = true
    end -- if key == bmhk_fade

    if GetIsBinding(key, kBMHKOnosKey) then
        if not down then
            self.selectedAlienType = AlienTechIdToIndex(kTechId.Onos)
            if self.selectedAlienType ~= prevselection then
                AlienBuy_OnSelectAlien("Onos")
                if combat_mode_not_active then
                    MarkAlreadyPurchased(self)
                    self:SetPurchasedSelected()
                end
                --Print("--Selected Onos")
            end
        end
        retval = true
    end -- if key == bmhk_onos

    -- last, check evolve key
    if GetIsBinding(key, kBMHKEvolveKey) then
        if not down then
            if PlayerUI_GetHasGameStarted() then
                local purchases = { }
                local upgradeCost = 0
                local newUpgrades = 0
                local player = Client.GetLocalPlayer()

                -- Add the selected lifeform
                if self.selectedAlienType ~= AlienBuy_GetCurrentAlien() then
                    upgradeCost = AlienBuy_GetAlienCost(self.selectedAlienType, false)
                    --Print("--Alien %s selected", EnumToString(kTechId, IndexToAlienTechId(self.selectedAlienType)))
                    if (combat_mode_not_active) then
                        table.insert(purchases, { Type = "Alien", Alien = self.selectedAlienType })
                        newUpgrades = newUpgrades + 1
                    else
                        -- in combat mode, only buy another class when you're a skulk
                        if AlienBuy_GetCurrentAlien() == AlienTechIdToIndex(kTechId.Skulk) then
                            table.insert(purchases, AlienBuy_GetTechIdForAlien(self.selectedAlienType))
                            newUpgrades = newUpgrades + 1
                        end
                    end
                end

                -- Add all selected upgrades
                for _, currentButton in ipairs(self.upgradeButtons) do
                    if currentButton.Selected then
                        upgradeCost = upgradeCost + GetUpgradeCostForLifeForm(player, self.selectedAlienType, currentButton.TechId)
                        if not player:GetHasUpgrade(currentButton.TechId) then
                            newUpgrades = newUpgrades + 1
                        end
                        if (combat_mode_not_active) then
                            table.insert(purchases, { Type = "Upgrade", Alien = self.selectedAlienType, UpgradeIndex = currentButton.Index, TechId = currentButton.TechId })
                        else
                            table.insert(purchases, currentButton.TechId)
                        end
                    end
                end

                -- Check purchases against available PRes
                if (newUpgrades > 0) and (PlayerUI_GetPlayerResources() >= upgradeCost)  then
                    --Print("--purchasing upgrades for %d", upgradeCost)
                    AlienBuy_Purchase(purchases)
                    AlienBuy_OnPurchase()
                end
            end -- if PlayerUI_GetHasGameStarted
            self.closingMenu = true
            AlienBuy_Close()
        end -- if not down
        retval = true
    end -- if key == bmhk_evolve
    
    return retval
end -- BMHK_Check_Keybinds

-- Helper function to create hotkey labels for each button based on TechId
local function BMHK_Create_Button_Label(TechId)
    local hotkey_graphic=nil
    local hotkey_text=nil

    -- Lifeform Tech IDs
    if (TechId == kTechId.Skulk) and ("None" ~= BindingsUI_GetInputValue(kBMHKSkulkKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKSkulkKey, true)
    elseif (TechId == kTechId.Gorge) and ("None" ~= BindingsUI_GetInputValue(kBMHKGorgeKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKGorgeKey, true)
    elseif (TechId == kTechId.Lerk) and ("None" ~= BindingsUI_GetInputValue(kBMHKLerkKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKLerkKey, true)
    elseif (TechId == kTechId.Fade) and ("None" ~= BindingsUI_GetInputValue(kBMHKFadeKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKFadeKey, true)
    elseif (TechId == kTechId.Onos) and ("None" ~= BindingsUI_GetInputValue(kBMHKOnosKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKOnosKey, true)

    -- Upgrade Tech IDs
    elseif (TechId == kTechId.Regeneration) and ("None" ~= BindingsUI_GetInputValue(kBMHKRegenerationKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKRegenerationKey, true)
        hotkey_graphic:SetAnchor(GUIItem.Right, GUIItem.Center)
    elseif (TechId == kTechId.Carapace) and ("None" ~= BindingsUI_GetInputValue(kBMHKCarapaceKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKCarapaceKey, true)
        hotkey_graphic:SetAnchor(GUIItem.Right, GUIItem.Center)
	elseif (TechId == kTechId.Vampirism) and ("None" ~= BindingsUI_GetInputValue(kBMHKVampirismKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKVampirismKey, true)
        hotkey_graphic:SetAnchor(GUIItem.Right, GUIItem.Center)
		
	elseif (TechId == kTechId.Adrenaline) and ("None" ~= BindingsUI_GetInputValue(kBMHKAdrenalineKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKAdrenalineKey, true)
        hotkey_graphic:SetAnchor(GUIItem.Left, GUIItem.Center)
    elseif (TechId == kTechId.Celerity) and ("None" ~= BindingsUI_GetInputValue(kBMHKCelerityKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKCelerityKey, true)
        hotkey_graphic:SetAnchor(GUIItem.Left, GUIItem.Center)
	elseif (TechId == kTechId.Crush) and ("None" ~= BindingsUI_GetInputValue(kBMHKCrushKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKCrushKey, true)
        hotkey_graphic:SetAnchor(GUIItem.Left, GUIItem.Center)	
		
	elseif (TechId == kTechId.Camouflage) and ("None" ~= BindingsUI_GetInputValue(kBMHKCamouflageKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKCamouflageKey, true)
        hotkey_graphic:SetAnchor(GUIItem.Left, GUIItem.Center)
    elseif (TechId == kTechId.Focus) and ("None" ~= BindingsUI_GetInputValue(kBMHKFocusKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKFocusKey, true)
        hotkey_graphic:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    elseif (TechId == kTechId.Aura) and ("None" ~= BindingsUI_GetInputValue(kBMHKAuraKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKAuraKey, true)
        hotkey_graphic:SetAnchor(GUIItem.Right, GUIItem.Center)
		
    --[[elseif (TechId == kTechId.Phantom) and ("None" ~= BindingsUI_GetInputValue(kBMHKPhantomKey)) then
        hotkey_graphic, hotkey_text = GUICreateButtonIcon(kBMHKPhantomKey, true)
        hotkey_graphic:SetAnchor(GUIItem.Left, GUIItem.Middle)--]]
    

    -- Else, return nil
    else
        Print("BMHK: TechId %d [%s] unrecognized or unbound", TechId, Locale.ResolveString(LookupTechData(TechId, kTechDataDisplayName, "")))
    end -- TechId...
    
    return hotkey_graphic, hotkey_text
end -- BMHK_Create_Button_Label

-- Helper function to adjust the hotkey label position for each button based on TechId
local function BMHK_Set_Label_Position(label, TechId, xcorr, ycorr)
    -- quick sanity check
    if label and (label ~= 1) then
        local size = label:GetSize()
        local newpos = nil

        -- Lifeform Tech IDs
        if TechId == kTechId.Skulk then
            newpos = Vector(-(size.x/2),0,0)
        elseif TechId == kTechId.Gorge then
            newpos = Vector(-(size.x/2),0,0)
        elseif TechId == kTechId.Lerk then
            newpos = Vector(-(size.x/2),-(size.y/2) - GUIScale(16),0)
        elseif TechId == kTechId.Fade then
            newpos = Vector(-(size.x/2),0,0)
        elseif TechId == kTechId.Onos then
            newpos = Vector(-(size.x/2),0,0)
        
        -- Upgrade Tech IDs
        --[[elseif TechId == kTechId.Phantom then
            label:SetPosition(Vector(-size.x,0,0))--]]
        
        elseif TechId == kTechId.Regeneration then
            newpos = Vector(-xcorr,0,0)
		elseif TechId == kTechId.Carapace then
            newpos = Vector(-xcorr,0,0)
		elseif TechId == kTechId.Vampirism then
            newpos = Vector(-xcorr,0,0)
          --  newpos = Vector(-size.x/2,-(size.y/2)-ycorr,0)
		
        elseif TechId == kTechId.Adrenaline then
            newpos = Vector(-size.x+xcorr,0,0)
        elseif TechId == kTechId.Celerity then
            newpos = Vector(-size.x+xcorr,0,0)
		elseif TechId == kTechId.Crush then
            newpos = Vector(-size.x+xcorr,0,0)
           -- newpos = Vector(-xcorr,0,0)

        elseif TechId == kTechId.Camouflage then
            newpos = Vector(-size.x+xcorr,0,0)
		elseif TechId == kTechId.Focus then
            --newpos = Vector(0,0,0)
            --newpos = Vector(size.x+xcorr,-ycorr,0)
            newpos = Vector(((math.floor((size.x)/2))*-1)+xcorr+8,-ycorr*2,0)
			-- newpos = Vector(xcorr,-ycorr,0)
        elseif TechId == kTechId.Aura then
            newpos = Vector(-8-xcorr,-ycorr,0)
        -- Else, do nothing
        else
        end -- TechId...

        if newpos then
            label:SetPosition(newpos)
        end
    end -- if label valid
end -- BMHK_Set_Label_Position

local function BMHK_Update_Button_Labels(self)
    local fullhud = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
    local uiscale = Client.GetOptionFloat("bmhk_ui_scale", kBMHKDefaultUIScale)
    local vuiscale = Vector(uiscale, uiscale, 0)
	local uishow = Client.GetOptionBoolean("bmhk_showlabels", true)
    -- Iterate the Lifeform buttons and add hotkey icons
    for _, alienButton in ipairs(self.alienButtons) do
        if alienButton.Button:GetIsVisible() then
            local techId = IndexToAlienTechId(alienButton.TypeData.Index)
            if (nil == alienButton.bmhk_alien_hotkey_graphic) then
                -- create a new button
                alienButton.bmhk_alien_hotkey_graphic, alienButton.bmhk_alien_hotkey_text = BMHK_Create_Button_Label(techId)

                if (alienButton.bmhk_alien_hotkey_graphic == nil) then
                    -- don't process this button in the future
                    alienButton.bmhk_alien_hotkey_graphic = 1
                else
                    -- scale the button and text label
                    --[[alienButton.bmhk_alien_hotkey_text:SetScale(vuiscale)
                    alienButton.bmhk_alien_hotkey_graphic:SetScale(vuiscale)
                    local size = alienButton.bmhk_alien_hotkey_graphic:GetSize()
                    local scaledsize = alienButton.bmhk_alien_hotkey_graphic:GetScaledSize()
                    local xcorr = (size.x-scaledsize.x)*.5
                    local ycorr = (size.y-scaledsize.y)*.5
                    --alienButton.bmhk_alien_hotkey_graphic:SetPosition(Vector(-(size.x+GUIScale(16)-xcorr),-(size.y/2),0))
                    alienButton.bmhk_alien_hotkey_text:SetPosition(Vector(xcorr,ycorr,0))

                    -- apply generic settings to the button
                    BMHK_Set_Label_Position(alienButton.bmhk_alien_hotkey_graphic, techId)--]]
                    alienButton.bmhk_alien_hotkey_graphic:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
                    alienButton.bmhk_alien_hotkey_graphic:SetLayer(kGUILayerPlayerHUDForeground4)
                    alienButton.Button:AddChild(alienButton.bmhk_alien_hotkey_graphic)
                end

            end -- alienButton.bmhk_alien_hotkey_graphic...

            if (alienButton.bmhk_alien_hotkey_graphic ~= 1) then
                -- disable the button graphic if HUD is set below full
                if fullhud and uishow then
                --if fullhud and (uiscale ~= 0) then
                    -- scale the button and text label
                    alienButton.bmhk_alien_hotkey_text:SetScale(vuiscale)
                    alienButton.bmhk_alien_hotkey_graphic:SetScale(vuiscale)
                    local size = alienButton.bmhk_alien_hotkey_graphic:GetSize()
                    local scaledsize = alienButton.bmhk_alien_hotkey_graphic:GetScaledSize()
                    local xcorr = (size.x-scaledsize.x)*.5
                    local ycorr = (size.y-scaledsize.y)*.5
                    alienButton.bmhk_alien_hotkey_text:SetPosition(Vector(xcorr,ycorr,0))

                    -- update the position
                    BMHK_Set_Label_Position(alienButton.bmhk_alien_hotkey_graphic, techId, xcorr, ycorr)

                    -- set visible
                    alienButton.bmhk_alien_hotkey_graphic:SetIsVisible(true)
                else
                    alienButton.bmhk_alien_hotkey_graphic:SetIsVisible(false)
                end -- if fullhud/scale
            end -- if currentButton.bmhk_upgrade_hotkey_graphic valid
        end -- if alienButton visible
    end -- for alienButton
    
    -- Iterate the Upgrade buttons and add hotkey icons
    for _, currentButton in ipairs(self.upgradeButtons) do
        if currentButton.Icon:GetIsVisible() then
            if (nil == currentButton.bmhk_upgrade_hotkey_graphic) then
                -- create a new button
                currentButton.bmhk_upgrade_hotkey_graphic, currentButton.bmhk_upgrade_hotkey_text = BMHK_Create_Button_Label(currentButton.TechId)

                if (currentButton.bmhk_upgrade_hotkey_graphic == nil) then
                    -- don't process this button in the future
                    currentButton.bmhk_upgrade_hotkey_graphic = 1
                else
                    -- scale the button and text label
                    --[[currentButton.bmhk_upgrade_hotkey_text:SetScale(vuiscale)
                    currentButton.bmhk_upgrade_hotkey_graphic:SetScale(vuiscale)

                    -- apply generic settings to the button
                    BMHK_Set_Label_Position(currentButton.bmhk_upgrade_hotkey_graphic, currentButton.TechId)--]]
                    currentButton.bmhk_upgrade_hotkey_graphic:SetLayer(kGUILayerPlayerHUDForeground4)
                    currentButton.Icon:AddChild(currentButton.bmhk_upgrade_hotkey_graphic)
                end
            end -- currentButton.bmhk_upgrade_hotkey_graphic...

            if (currentButton.bmhk_upgrade_hotkey_graphic ~= 1) then
                -- disable the button graphic if HUD is set below full
                if fullhud and uishow then
                --if fullhud and (uiscale ~= 0) then
                    -- scale the button and text label
                    currentButton.bmhk_upgrade_hotkey_text:SetScale(vuiscale)
                    currentButton.bmhk_upgrade_hotkey_graphic:SetScale(vuiscale)
                    local size = currentButton.bmhk_upgrade_hotkey_graphic:GetSize()
                    local scaledsize = currentButton.bmhk_upgrade_hotkey_graphic:GetScaledSize()
                    local xcorr = (size.x-scaledsize.x)*.5
                    local ycorr = (size.y-scaledsize.y)*.5
                    currentButton.bmhk_upgrade_hotkey_text:SetPosition(Vector(xcorr,ycorr,0))

                    -- update the position
                    BMHK_Set_Label_Position(currentButton.bmhk_upgrade_hotkey_graphic, currentButton.TechId, xcorr, ycorr)

                    -- set visible
                    currentButton.bmhk_upgrade_hotkey_graphic:SetIsVisible(true)
                else
                    currentButton.bmhk_upgrade_hotkey_graphic:SetIsVisible(false)
                end -- if fullhud/scale
            end -- if currentButton.bmhk_upgrade_hotkey_graphic valid
        end -- if currentButton.Icon visible
    end -- for upgradeButtons
    
    -- Add hotkey icon to the Evolve button
    if self.evolveButtonBackground:GetIsVisible() then
        if (nil == self.bmhk_evolve_hotkey_graphic) then
            if "None" == BindingsUI_GetInputValue(kBMHKEvolveKey) then
                self.bmhk_evolve_hotkey_graphic = 1
            else
                -- create a new button
                self.bmhk_evolve_hotkey_graphic, self.bmhk_evolve_hotkey_text = GUICreateButtonIcon(kBMHKEvolveKey, true)
                self.bmhk_evolve_hotkey_graphic:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
                self.bmhk_evolve_hotkey_graphic:SetLayer(kGUILayerPlayerHUDForeground4)

                -- scale the button and text label
                --[[self.bmhk_evolve_hotkey_text:SetScale(vuiscale)
                self.bmhk_evolve_hotkey_graphic:SetScale(vuiscale)

                -- apply generic settings to the button
                local size = self.bmhk_evolve_hotkey_graphic:GetSize()
                self.bmhk_evolve_hotkey_graphic:SetPosition(Vector(-(size.x/2), 1, 0))--]]
                self.evolveButtonBackground:AddChild(self.bmhk_evolve_hotkey_graphic)
            end
        end -- self.bmhk_evolve_hotkey_graphic...

        if (self.bmhk_evolve_hotkey_graphic ~= 1) then
            -- disable the button graphic if HUD is set below full
            if fullhud and uishow then
            --if fullhud and (uiscale ~= 0) then
                -- scale the button and text label
                self.bmhk_evolve_hotkey_text:SetScale(vuiscale)
                self.bmhk_evolve_hotkey_graphic:SetScale(vuiscale)
                local size = self.bmhk_evolve_hotkey_graphic:GetSize()
                local scaledsize = self.bmhk_evolve_hotkey_graphic:GetScaledSize()
                local xcorr = (size.x-scaledsize.x)*.5
                local ycorr = (size.y-scaledsize.y)*.5
                self.bmhk_evolve_hotkey_text:SetPosition(Vector(xcorr,ycorr,0))

                -- update the position
                local size = self.bmhk_evolve_hotkey_graphic:GetSize()
                self.bmhk_evolve_hotkey_graphic:SetPosition(Vector(-(size.x/2), 1-ycorr, 0))

                -- set visible
                self.bmhk_evolve_hotkey_graphic:SetIsVisible(true)
            else
                self.bmhk_evolve_hotkey_graphic:SetIsVisible(false)
            end -- if fullhud/scale
        end -- if self.bmhk_evolve_hotkey_graphic valid
    end -- if evolveButtonBackground visible
end -- BMHK_Update_Button_Labels

-- We will extend AlienBuy_OnOpen in order to patch GUIAlienBuyMenu
local originalABOnOpen = AlienBuy_OnOpen
function AlienBuy_OnOpen()
    -- GUIAlienBuyMenu should now be loaded -- commence patching functions
    if (not gabm_patched) and GUIAlienBuyMenu then
        --Print("Patching GUIAlienBuyMenu")
        -- We will extend GUIAlienBuyMenu:SendKeyEvent
        local originalGABMSendKeyEvent = GUIAlienBuyMenu.SendKeyEvent
        function GUIAlienBuyMenu:SendKeyEvent(key, down)
            local stop = false

            stop = BMHK_Check_Keybinds(self, key, down)

            if not stop then
                stop = originalGABMSendKeyEvent(self, key, down)
            end
            return stop
        end -- GUIAlienBuyMenu:SendKeyEvent
        
        -- We will extend GUIAlienBuyMenu:_UpdateUpgrades
        local originalGABM_UpdateUpgrades = GUIAlienBuyMenu._UpdateUpgrades
        function GUIAlienBuyMenu:_UpdateUpgrades(deltaTime)
            originalGABM_UpdateUpgrades(self, deltaTime)
            BMHK_Update_Button_Labels(self)
        end
        
        gabm_patched = true
    end -- if not gabm_patched

    originalABOnOpen()
end -- AlienBuy_OnOpen

--=== Change Log =================================================================================
--
-- 0.80
-- - Initial revision
-- - Added keyhandling for mod-specific keys
-- - Ensure enforcement of game rules
--
-- 1.00
-- - Added hotkey icons to the menu
-- - Removed extra debug printouts
--
-- 1.10
-- - Created this file
-- - Moved alien buy menu code into this file (revision history copied above)
--
-- 2.00
-- - Changed to use global defines for all the key names
-- - Removed remaining debug printouts
-- - Capture and ignore key down to prevent keypresses from being handled twice
--
-- 2.02
-- - Check that GUIAlienBuyMenu actually exists before dereferencing
-- - Remove upgrade swapping behavior if we are in Combat Mode
-- - If Combat Mode is active use their format for purchase list
--
-- 2.10
-- - Button labels will be hidden if Minimal-HUD mode is enabled
-- - Button labels will be scaled based on bmhk_ui_scale option
--
-- 2.21
-- - DeselectAllUpgrades function removed in Build 274--replaced with equivalent functionality
--
-- 2.40
-- - Remove references to phantom ability
-- - Add buttom labeles for Camouflage, Vampirism, Crush, and Focus
-- - Update to match new game rules for which abilities correspond to which hives
-- - Don't show label if key doesn't have a valid binding
-- - Correct the label graphic's text and background position
--
--================================================================================================