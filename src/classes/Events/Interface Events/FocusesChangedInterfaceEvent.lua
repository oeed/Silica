
class "FocusesChangedInterfaceEvent" extends "InterfaceEvent" {
	eventType = "interface_focuses_changed";
	newFocuses = false; -- the new views that are being focused on. doesn't lose it's focus when it recieves this event.
    oldFocuses = false; -- the old views that previously were focused
}

--[[
	@constructor
	@desc Creates a focus event from the arguments
    @param [table] newFocuses -- the new focuses
	@param [table] oldFocuses -- the old focuses
]]
function FocusesChangedInterfaceEvent:initialise( newFocuses, oldFocuses )
    log("change?")
    for k, v in pairs(oldFocuses) do
        log(tostring(k)..":"..tostring(v))
    end
	self.newFocuses = newFocuses
    self.oldFocuses = oldFocuses
end

--[[
    @instance
    @desc Returns true if the given is currently focused
    @param [View] view
    @return [boolean] isFocused
]]
function FocusesChangedInterfaceEvent:contains( view )
    return self.newFocuses[view] ~= nil
end

--[[
    @instance
    @desc Returns true if the given was focused
    @param [View] view
    @return [boolean] isFocused
]]
function FocusesChangedInterfaceEvent:didContain( view )
    return self.oldFocuses[view] ~= nil
end
