
class "SiblingAddedInterfaceEvent" extends "InterfaceEvent" {
	eventType = Event.SIBLING_ADDED;
	view = false; -- the new sibling that was added
	isSentToChildren = false;
}

--[[
	@constructor
	@desc Creates a siblings changed event from the arguments
	@param [View] view -- the new sibling view
]]
function SiblingAddedInterfaceEvent:init( view )
	self.view = view
end
