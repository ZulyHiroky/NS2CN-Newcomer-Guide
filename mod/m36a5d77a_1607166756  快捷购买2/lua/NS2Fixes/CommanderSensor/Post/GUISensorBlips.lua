

local commanderAlpha = 1.0
local commanderColor = Color(1, 1.0, 1.0, 1)
local commanderBlipImageName = "ui/blip.dds"

local oldInitialize = GUISensorBlips.Initialize
function GUISensorBlips:Initialize()
    oldInitialize(self)
    self.wasCommander = false
end

function GUISensorBlips:UpdateAnimations(deltaTime)

    PROFILE("GUISensorBlips:UpdateAnimations")
    
    local baseRotationPercentage = (Shared.GetTime() % GUISensorBlips.kRotationDuration) / GUISensorBlips.kRotationDuration
    
    if not self.timeLastImpulse then
        self.timeLastImpulse = Shared.GetTime()
    end
    
    if self.timeLastImpulse + GUISensorBlips.kImpulseIntervall < Shared.GetTime() then
        self.timeLastImpulse = Shared.GetTime()
    end  

    local localPlayerIsCommander = Client.GetLocalPlayer() and Client.GetLocalPlayer():isa("Commander")
    
    local destAlpha = math.max(0, 1 - (Shared.GetTime() - self.timeLastImpulse) * GUISensorBlips.kAlphaPerSecond)  
    
    for i, blip in ipairs(self.activeBlipList) do
        local size = math.min(blip.Radius * 2 * GUISensorBlips.kDefaultBlipSize, GUISensorBlips.kMaxBlipSize)
        blip.GraphicsItem:SetSize(Vector(size, size, 0))
        
        -- Offset by size / 2 so the blip is centered.
        local newPosition = Vector(blip.ScreenX - size / 2, blip.ScreenY - size / 2, 0)
        blip.GraphicsItem:SetPosition(newPosition)
        
        -- rotate the blip
        blip.GraphicsItem:SetRotation(Vector(0, 0, 2 * math.pi * (baseRotationPercentage + (i / #self.activeBlipList))))

        -- Draw blips as barely visible when in view, to communicate their purpose. Animate color towards final value.
        local currentColor = blip.GraphicsItem:GetColor()
        destAlpha = ConditionalValue(blip.Obstructed, destAlpha * blip.Radius, currentColor.a - GUISensorBlips.kAlphaPerSecond * deltaTime)
        
        
        if localPlayerIsCommander then
            destAlpha = commanderAlpha
            currentColor = commanderColor
        end
        if self.wasCommander ~= localPlayerIsCommander then
            if localPlayerIsCommander then
                blip.GraphicsItem:SetTexture(commanderBlipImageName)
            else
                blip.GraphicsItem:SetTexture(GUISensorBlips.kBlipImageName)
            end
        end
        
        currentColor.a = destAlpha
        blip.GraphicsItem:SetColor(currentColor)
        blip.TextItem:SetColor(currentColor)
        
    end
    
    self.wasCommander = localPlayerIsCommander
    
end

local oldCreateBlipItem = GUISensorBlips.CreateBlipItem
function GUISensorBlips:CreateBlipItem()

    local newBlip = oldCreateBlipItem(self)
    
    local localPlayerIsCommander = Client.GetLocalPlayer() and Client.GetLocalPlayer():isa("Commander")
    
    if localPlayerIsCommander then
        newBlip.GraphicsItem:SetTexture(commanderBlipImageName)
    end
    return newBlip
    
end