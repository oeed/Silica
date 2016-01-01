
class ActionInterfaceEvent extends InterfaceEvent {

    static = {
        eventType = "interface_action";
    };

	view = View; -- the View whose action it is
    originalEvent = Event.allowsNil; -- the event the invoked this event (such as a mouse up, key click, etc.)

}

--[[
	@constructor
	@desc Creates a focus event from the arguments
	@param [View] view -- the View whose action it is
]]
function ActionInterfaceEvent:initialise( View view, Event.allowsNil originalEvent )
	self.view = view
    self.originalEvent = originalEvent
end

