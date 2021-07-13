
local oldCreateOptionWindow = GUIMainMenu.CreateOptionWindow
function GUIMainMenu:CreateOptionWindow()
    oldCreateOptionWindow(self)
    
    local function BoolToIndex(value)
        if value then
            return 2
        end
        return 1
    end

    
    local damageColor =   Client.GetOptionInteger( "damageColor", 1 ) -- 1=default, 2=colorblind, 3=use old ugly useless colors 
    local damageOpacity = Client.GetOptionFloat( "damageOpacity", 1)
    
    
	local optionElements = self.optionElements
    
    optionElements.DamageColor:SetOptionActive( damageColor)
    optionElements.DamageOpacity:SetValue(damageOpacity )
    
    ApplyDamageColorSettings()
end

local function OnDamageOpacityChanged(mainMenu)

    local value = mainMenu.optionElements.DamageOpacity:GetValue()
    Client.SetOptionFloat("damageOpacity", value)
    
    ApplyDamageColorSettings()
    
end

local function OnDamageColorChanged(formElement)

    local value = formElement:GetActiveOptionIndex()
    Client.SetOptionInteger("damageColor", value)
    
    ApplyDamageColorSettings()
    
end


local origCreateOptionsForm = GUIMainMenu.CreateOptionsForm
GUIMainMenu.CreateOptionsForm = function(mainMenu, content, options, optionElements)
    
    for index,record in ipairs(options) do 
        local currentFieldName = record["name"]
        if currentFieldName == "DrawDamage" then
            
            table.insert(options, 
            {
                name    = "DamageColor",
                label   = "Damage Color",
                tooltip = "The method of picking the color of the damage number based on the target's health",
                type    = "select",
                values  = { "Green to red", "Green to blue", "Flat color" },
                value = Client.GetOptionInteger( "damageColor", 0 ),
                callback = OnDamageColorChanged
            })
            table.insert(options, 
            {
                name    = "DamageOpacity",
                label   = "Damage Opacity",
                tooltip = "How transparent the damage numbers appear",
                type    = "slider",
                sliderCallback = OnDamageOpacityChanged
            })
            break
        end
    
    end
    ApplyDamageColorSettings()
    return origCreateOptionsForm(mainMenu, content, options, optionElements)
end

