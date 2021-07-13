local oldHook = Event.Hook
function Event.Hook(name, callback, ...)

    if name == "Console_soundgeometry" or 
		name == "Console_guiinfo" or 
		name == "Console_pathingfill" then
        -- do nothing
    else
        return oldHook(name, callback, ...)
    end
end