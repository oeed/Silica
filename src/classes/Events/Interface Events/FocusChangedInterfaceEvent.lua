
class "FocusChangedInterfaceEvent" extends "InterfaceEvent" {
	eventType = Event.FOCUS_CHANGED;
	newFocus = false; -- the new view that's being focused on. doesn't lose it's focus when it recieves this event.
}

--[[
	@constructor
	@desc Creates a focus event from the arguments
	@param newFocus -- the newFocus view (if any)
]]
function FocusChangedInterfaceEvent:initialise( newFocus )
	self.newFocus = newFocus
end

