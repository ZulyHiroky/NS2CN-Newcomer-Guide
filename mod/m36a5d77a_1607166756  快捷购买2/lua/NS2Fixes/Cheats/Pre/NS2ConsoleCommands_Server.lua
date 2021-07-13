local oldHook = Event.Hook
function Event.Hook(name, callback, ...)

    if name == "Console_film" then
        -- do nothing
    else
        return oldHook(name, callback, ...)
    end
end