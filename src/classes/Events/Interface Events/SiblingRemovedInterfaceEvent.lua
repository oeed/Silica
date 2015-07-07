
class "SiblingRemovedInterfaceEvent" extends "InterfaceEvent" {
	eventType = Event.SIBLING_REMOVED;
	view = false; -- the new sibling that was removed
	isSentToChildren = false;
}

--[[
	@constructor
	@desc Creates a siblings changed event from the arguments
	@param [View] view -- the removed sibling view
]]
function SiblingRemovedInterfaceEvent:init( view )
	self.view = view
end
