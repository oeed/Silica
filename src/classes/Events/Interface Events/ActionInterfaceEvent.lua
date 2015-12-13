
class "ActionInterfaceEvent" extends "InterfaceEvent" {

    static = {
        eventType = "interface_action";
    };

	sender = View; -- the View whose action it is
    originalEvent = Event.allowsNil; -- the event the invoked this event (such as a mouse up, key click, etc.)

}

--[[
	@constructor
	@desc Creates a focus event from the arguments
	@param [View] sender -- the view whose action it is
]]
function ActionInterfaceEvent:initialise( View sender, Event.allowsNil originalEvent )
	self.sender = sender
    self.originalEvent = originalEvent
end

