--=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
--
-- BuyMenuHotKeys\bmhk_common.lua
--
--    Created by:   Chris Baker (chris.l.baker@gmail.com)
--    License:      Public Domain
--
-- Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
-- Worlds Entertainment, Inc. Natural Selection 2, its Assets, Source Code, Documentation, and
-- Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
-- ========= For more information, visit http:--www.unknownworlds.com ============================


kBMHKStartMarker     = "bmhk"
kBMHKEvolveKey       = "bmhk_evolve"
kBMHKSkulkKey        = "bmhk_skulk"
kBMHKGorgeKey        = "bmhk_gorge"
kBMHKLerkKey         = "bmhk_lerk"
kBMHKFadeKey         = "bmhk_fade"
kBMHKOnosKey         = "bmhk_onos"

kBMHKCarapaceKey     = "bmhk_carapace"
kBMHKRegenerationKey = "bmhk_regeneration"
kBMHKVampirismKey    = "bmhk_vampirism"
--kBMHKPhantomKey      = "bmhk_phantom"

kBMHKAdrenalineKey   = "bmhk_adrenaline"
kBMHKCelerityKey     = "bmhk_celerity"
kBMHKCrushKey        = "bmhk_crush"

kBMHKCamouflageKey      = "bmhk_camouflage"
kBMHKFocusKey        = "bmhk_focus"
kBMHKAuraKey         = "bmhk_aura"

kBMHKWelderKey       = "bmhk_welder"
kBMHKMinesKey        = "bmhk_mines"
kBMHKShotgunKey      = "bmhk_shotgun"
kBMHKClusterKey      = "bmhk_cluster"
kBMHKNervegasKey     = "bmhk_nervegas"
kBMHKPulseKey        = "bmhk_pulse"
kBMHKGLKey           = "bmhk_gl"
kBMHKFlamethrowerKey = "bmhk_flamethrower"
kBMHKHMGKey          = "bmhk_hmg"
kBMHKJetpackKey      = "bmhk_jetpack"
kBMHKExominiKey      = "bmhk_exomini"
kBMHKExorailKey      = "bmhk_exorail"
kBMHKShowLabels 	 = "bmhk_showlabels"

--kBMHKExodualKey      = "bmhk_exodual"

kBMHKDefaultUIScale = 0.750
--kBMHKDefaultShowLabels = true


-- There is a bug that affects scrolling very long forms due to having a fixed
-- CSS Height attribute. This routine will patch the form height to be
-- ContentSize + 20.
-- It will also export a global variable to prevent the fix from being applied
-- multiple times.
if not kLongFormScrollFix and ContentBox then
    -- Patch ContentBox:OnSlide to correct form height
    local originalCBOnSlide = ContentBox.OnSlide
    function ContentBox:OnSlide(slideFraction, align)
        --Print("ContentBox:OnSlide (%f)", slideFraction)
        for _, child in ipairs(self.children) do
            local desiredconheight = child:GetContentSize().y+20
            if child:isa("Form") and (child:GetHeight() ~= desiredconheight) then
                child:SetHeight(desiredconheight)
            end
        end
        originalCBOnSlide(self, slideFraction, align)
    end
    kLongFormScrollFix = 1
end

-- patch the bindings data (can we do this by using ReplaceLocals?)
local binding_data_patched = false
if (nil ~= BindingsUI_GetBindingsData) then
    local tempbd = BindingsUI_GetBindingsData()
    for i,line in ipairs(tempbd) do
      if (line==kBMHKStartMarker) then
        binding_data_patched = true
        break
      end
    end

    if (not binding_data_patched) then
        local additionalDefaultBindings =
        {
            {kBMHKEvolveKey,       "NumPadEnter"},
            {kBMHKGorgeKey,        "1"},
            {kBMHKSkulkKey,        "2"},
            {kBMHKLerkKey,         "3"},
            {kBMHKFadeKey,         "4"},
            {kBMHKOnosKey,         "5"},
            
			{kBMHKRegenerationKey, "NumPad1"},
            {kBMHKCarapaceKey,     "NumPad2"},
			{kBMHKVampirismKey,    "NumPad3"},
            --{kBMHKPhantomKey,      "NumPad8"},
            {kBMHKAdrenalineKey,   "NumPad4"},
            {kBMHKCelerityKey,     "NumPad5"},
			{kBMHKCrushKey,        "NumPad6"},
            {kBMHKCamouflageKey,   "NumPad7"},
			{kBMHKFocusKey,        "NumPad8"},
            {kBMHKAuraKey,         "NumPad9"},
            {kBMHKWelderKey,       "1"},
            {kBMHKMinesKey,        "2"},
            {kBMHKShotgunKey,      "3"},
            {kBMHKClusterKey,      "4"},
            {kBMHKNervegasKey,     "5"},
            {kBMHKPulseKey,        "6"},
            {kBMHKGLKey,           "7"},
            {kBMHKFlamethrowerKey, "8"},
            {kBMHKHMGKey,          "9"},
            {kBMHKJetpackKey,      "1"},
            {kBMHKExominiKey,      "2"},
            {kBMHKExorailKey,      "3"},
            --{kBMHKExodualKey,      "1"},
        } -- additionalDefaultBindings

        local additionalControlBindings =
        {
            kBMHKStartMarker,     "title", "Buy Menu Hotkeys",          "Key Binding for Buy Menu Hotkeys Mod",
            kBMHKEvolveKey,       "input", "Buy Menu Evolve",           "NumPadEnter",
            kBMHKGorgeKey,        "input", "Select Gorge",              "1",            
            kBMHKSkulkKey,        "input", "Select Skulk",              "2",
            kBMHKLerkKey,         "input", "Select Lerk",               "3",
            kBMHKFadeKey,         "input", "Select Fade",               "4",
            kBMHKOnosKey,         "input", "Select Onos",               "5",
            
			kBMHKRegenerationKey, "input", "Select Regeneration",       "NumPad1",
            kBMHKCarapaceKey,     "input", "Select Carapace",           "NumPad2",
			kBMHKVampirismKey,    "input", "Select Vampirism",          "NumPad3",
            --kBMHKPhantomKey,      "input", "Select Phantom",            "NumPad8",
            kBMHKAdrenalineKey,   "input", "Select Adrenaline",         "NumPad4",
            kBMHKCelerityKey,     "input", "Select Celerity",           "NumPad5",
			kBMHKCrushKey,        "input", "Select Crush",              "NumPad6",
			kBMHKCamouflageKey,   "input", "Select Camouflage",         "NumPad7",
            kBMHKFocusKey,        "input", "Select Focus",              "NumPad8",
            kBMHKAuraKey,         "input", "Select Aura",               "NumPad9",
            
            kBMHKWelderKey,       "input", "Purchase Welder",           "1",
            kBMHKMinesKey,        "input", "Purchase Mines",            "2",
            kBMHKShotgunKey,      "input", "Purchase Shotgun",          "3",
            kBMHKClusterKey,      "input", "Purchase Cluster Grenades", "4",
            kBMHKNervegasKey,     "input", "Purchase Nerve Gas",        "5",
            kBMHKPulseKey,        "input", "Purchase Pulse Grenades",   "6",
            kBMHKGLKey,           "input", "Purchase Grenade Launcher", "7",
            kBMHKFlamethrowerKey, "input", "Purchase Flamethrower",     "8",
            kBMHKHMGKey,          "input", "Purchase HMG",              "9",
            kBMHKJetpackKey,      "input", "Purchase Jetpack",          "1",
            kBMHKExominiKey,      "input", "Purchase Minigun Exo",      "2",
            kBMHKExorailKey,      "input", "Purchase Railgun Exo",      "3",
            --kBMHKExodualKey,      "input", "Purchase Dual-Exo Upgrade", "1",
        } -- additionalControlBindings

        for i,line in ipairs(additionalControlBindings) do
          table.insert(tempbd, line)
        end

        -- We will extend GetDefaultInputValue
        local originalBindingsGetDefault = GetDefaultInputValue
        function GetDefaultInputValue(controlId)
            local rc = nil
            for index, pair in ipairs(additionalDefaultBindings) do
                if(pair[1] == controlId) then
                    rc = pair[2]
                    break
                end
            end
            
            if (rc == nil) then
                rc = originalBindingsGetDefault(controlId)
            end
            return rc
        end -- GetDefaultInputValue
    end -- if binding data not yet patched
 end -- BindingsUI_GetBindingsData not nil

--[[*
 * This table lists the header labels that will be added to the bindings menu.
 * header_rows[].insert_before is the button name for the button that will immediately follow the header label
 * header_rows[].header_text is the text of the label itself
 --]]
 --[[
local header_rows =
{
    {insert_before=kBMHKEvolveKey,  header_text="BMHK Label Scale:", ui_slider=true},
    {insert_before=kBMHKEvolveKey,  header_text="ALIEN BUY MENU HOTKEYS:"},
    {insert_before=kBMHKWelderKey,  header_text="ARMORY BUY MENU HOTKEYS:"},
    {insert_before=kBMHKJetpackKey, header_text="PROTOLAB BUY MENU HOTKEYS:"},
}

-- We will override GUIMainMenu..CheckForConflictedKeys
local originalCheckForConflictedKeys = nil
local function localCheckForConflictedKeys(keyInputs)
    if originalCheckForConflictedKeys then
        local newKeys = {}
        -- remove all BMHK keys from the checklist
        for i,key in ipairs(keyInputs) do
            if key.inputName and (string.sub(key.inputName, 1, 5) == "bmhk_") then
                key:SetCSSClass("option_input") -- reset CSS class
            else
                table.insert(newKeys, key)
            end
        end
        
        originalCheckForConflictedKeys(newKeys)
    end -- if originalCheckForConflictedKeys
end -- localCheckForConflictedKeys

local function Patch_Conflict_Check_Function(key_element)
    if (originalCheckForConflictedKeys == nil) then
        if key_element.inputName and key_element.OnSendKey then
            -- The following code replicates functionality of
            -- ReplaceLocals(key_element.OnSendKey, {"CheckForConflictedKeys"=localCheckForConflictedKeys})
            -- but keeps track of original function
            local index = 1
            local foundIndex = nil
            while true do
                local n, v = debug.getupvalue(key_element.OnSendKey, index)
                if not n then
                    break
                end
                if (n == "CheckForConflictedKeys") then
                    if (v ~= localCheckForConflictedKeys) then
                        originalCheckForConflictedKeys = v
                        debug.setupvalue(key_element.OnSendKey, index, localCheckForConflictedKeys)
                    end
                    break
                end
                index = index + 1
            end -- while true
        end -- if key_element has inputName and OnSendKey
    end -- if not originalCheckForConflictedKeys
end -- Patch_Conflict_Check_Function

local function Insert_Binding_Menu_Header_Rows(self)
    -- Find the key bindings form
    local content = self.optionWindow:GetContentBox()
    for _, form in ipairs(content.children) do
        if (form:GetCSSClassNames() == "keybindings ") then
            -- Iterate through the table of headers
            for i, header in ipairs(header_rows) do
                -- Find offset of the button with inputName == header.insert_before
                local offset = 0
                for _, element in ipairs(form.children) do
                    if element.inputName and (element.inputName == header.insert_before) then
                        offset = element.background:GetPosition().y
                        Patch_Conflict_Check_Function(element)
                        break
                    end
                end
                if offset ~= 0 then
                    -- Move all form elements down by 75
                    for _, element in ipairs(form.children) do
                        local pos = element.background:GetPosition()
                        if (offset <= pos.y) then
                            pos.y = pos.y+75
                            element.desiredPos.y = element.desiredPos.y+75
                            element.background:SetPosition(pos)
                        end
                    end
                    if (header.ui_slider) then
                        -- This code adapted from slider creation code in GUIMainMenu.lua
                        local slider = form:CreateFormElement(Form.kElementType.SlideBar, "bmhk_ui_scale", kBMHKDefaultUIScale/2)
                        local slider_display = form:CreateFormElement(Form.kElementType.TextInput, "bmhk_ui_scale", nil)
                        slider_display:SetNumbersOnly(true)	
			            slider_display:SetXAlignment(GUIItem.Align_Min)
			            slider_display:SetMarginLeft(5)
			            slider_display:SetCSSClass("display_input")
                        slider_display:SetTopOffset(offset+20)
			            slider_display:AddEventCallbacks({ 
				
                        OnEnter = function(self)
                            --Print("OnEnter: %s", tonumber(slider_display:GetValue()))
                            if (nil == tonumber(slider_display:GetValue())) then
                                slider_display:SetValue("0")
                                slider:SetValue(0)
                            else
                                slider:SetValue(tonumber(slider_display:GetValue())/2)
                            end
                        end,
                        OnBlur = function(self)
                            --Print("OnBlur: %s", tonumber(slider_display:GetValue()))
                            if (nil == tonumber(slider_display:GetValue())) then
                                slider_display:SetValue("0")
                                slider:SetValue(0)
                            else
                                slider:SetValue(tonumber(slider_display:GetValue())/2)
                            end
                        end,
                        })
                        -- HACK: Really should use input:AddSetValueCallback, but the slider bar bypasses that.
                        slider:Register(
                            {OnSlide =
                                function(self, value, interest)
                                    --Print("slider:OnSlide %s", value*2)
                                    Client.SetOptionFloat("bmhk_ui_scale", value*2)
                                    slider_display:SetValue(ToString(string.sub(value*2,0,4)))
                                end
                            }, SLIDE_HORIZONTAL)

                        slider:SetCSSClass("option_input")
                        slider:SetTopOffset(offset+20)
                        slider:SetValue(Client.GetOptionFloat("bmhk_ui_scale", kBMHKDefaultUIScale)/2)
                        slider_display:SetValue(ToString(string.sub(slider:GetValue()*2,0,4)))
                    end
                    -- Add separator with label text = header.header_text
                    local keyInputText = CreateMenuElement(form, "Font", false)
                    keyInputText:SetText(header.header_text)
                    keyInputText:SetCSSClass("option_label")
                    keyInputText:SetTopOffset(offset+20)
                    keyInputText:SetBackgroundHoverColor(nil)
                    keyInputText:SetTextColor(Color(1,1,1,1))
                    keyInputText:SetFontName("fonts/AgencyFB_medium.fnt")
                end -- if offset found
            end -- for each header
        end -- if keybindings form
    end -- for each form
end -- Insert_Binding_Menu_Header_Rows

-- We will extend MainMenu_OnOpenMenu to patch GUIMainMenu
local originalMMOnOpen = MainMenu_OnOpenMenu
function MainMenu_OnOpenMenu()
    --Print("MainMenu_OnOpenMenu")
    originalMMOnOpen()

        -- We will extend GUIMainMenu:Update
        local originalGMMUpdate = GUIMainMenu.Update
        function GUIMainMenu:Update(deltaTime)
            originalGMMUpdate(self, deltaTime)
            if self.optionWindow and not self.optionWindow.bmhk_menu_patched then
                --Print("Patching Options Menu")
                Insert_Binding_Menu_Header_Rows(self)
                localCheckForConflictedKeys(self.keyInputs)
                self.optionWindow.bmhk_menu_patched = true
            end
        end -- GUIMainMenu:ShowMenu

end -- MainMenu_OnOpenMenu
]]--
--=== Change Log =================================================================================
--
-- 0.80
-- - Created initial revision
-- - Added key bindings to the menu
-- - Fixed bug with Form height hardcoded in CSS
--
-- 1.00
-- - Added hotkey icons to the Alien Buy Menu
-- - Removed Main.lua, will need to load through MainMenuModLoader
--
-- 1.10
-- - Reorganized Files
-- - Moved version string to bmhk_Client.lua
-- - Added separator to Bindings list
-- - Fixed wrong text on some of the binding labels
--
-- 2.00
-- - Added constant globals for the key binding names
-- - Added key bindings for marine buy menus
-- - Added function to add heading lables to the bindings menu automatically
--
-- 2.01
-- - Avoid marking key conflicts for BMHK-related keys as these are context-
--   specific
--
-- 2.10
-- - Add a slider bar to the key bindings menu to control the UI scale for the
--   button labels
--
-- 2.20
-- - Update for build 263
-- - Add numerical value to options slider to match other menus
--
-- 2.21
-- - Added check against kLongFormScrollFix as I am patching the scroll bar
--   bug in multiple mods now.
--
-- 2.30
-- - Add protection for kLongFormScrollFix if it is loaded before ContentBox.
--
-- 2.40
-- - Add keybinding for HMG
-- - Reorder armory keybindings to put the welder first
-- - Remove references to phantom ability
-- - Add keybinds for camouflage, vampirism, crush, and focus
-- - Reorganize default keybindings
--
--================================================================================================