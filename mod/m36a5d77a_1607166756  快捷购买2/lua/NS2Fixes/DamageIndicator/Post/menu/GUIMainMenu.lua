
local oldCreateOptionWindow = GUIMainMenu.CreateOptionWindow
function GUIMainMenu:CreateOptionWindow()
    oldCreateOptionWindow(self)

    local hitIndicatorFixed = Client.GetOptionBoolean( "hitIndicatorFixed", GetShouldHitIndicatorFixedDefault() )
    
	local optionElements = self.optionElements
	if optionElements then
		optionElements.HitIndicatorFixed:SetValue(hitIndicatorFixed and Locale.ResolveString("YES") or Locale.ResolveString("NO"))
	end
	
end

local function OnHitIndicatorFixed(formElement)
	
    local value = formElement:GetActiveOptionIndex() > 1
	
    Client.SetOptionBoolean("hitIndicatorFixed", value)
    
end


local origCreateOptionsForm = GUIMainMenu.CreateOptionsForm
GUIMainMenu.CreateOptionsForm = function(mainMenu, content, options, optionElements)
	
    for index,record in ipairs(options) do 
        local currentFieldName = record["name"]
        if currentFieldName == "DrawDamage" then
            
            table.insert(options, 
            {
                name    = "HitIndicatorFixed",
                label   = "DAMAGE INDICATOR ANIMATION",
                tooltip = "A little red 'pop' animation when you get hit",
                type    = "select",
                values  = { Locale.ResolveString("NO"), Locale.ResolveString("YES") },
                value = Client.GetOptionBoolean("hitIndicatorFixed", GetShouldHitIndicatorFixedDefault()) and Locale.ResolveString("YES") or Locale.ResolveString("NO"),
                callback = OnHitIndicatorFixed
            })
            break
        end
    
    end
	
    return origCreateOptionsForm(mainMenu, content, options, optionElements)
end

