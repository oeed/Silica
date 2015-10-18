
class "ChildRemovedInterfaceEvent" extends "InterfaceEvent" {
	eventType = Event.CHILD_REMOVED;
	childView = false; -- the removed child
	isSentToChildren = false;
}

--[[
	@constructor
	@desc Creates a child removed event from the arguments
	@param [View] childView -- the removed child
]]
function ChildRemovedInterfaceEvent:initialise( childView )
	self.childView = childView
end
