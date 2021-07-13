
local oldOptionBoolean = Client.GetOptionBoolean
Client.GetOptionBoolean = function (name, default)
    if name == "drawDamage" then
        return true
    end
    return oldOptionBoolean(name, default)
end