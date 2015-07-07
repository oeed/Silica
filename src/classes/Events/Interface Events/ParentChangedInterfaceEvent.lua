
class "ParentChangedInterfaceEvent" extends "InterfaceEvent" {
	eventType = Event.PARENT_CHANGED;
	newParent = false; -- the new parent
	oldParent = false; -- the old parent
	isSentToChildren = false;
}

--[[
	@constructor
	@desc Creates a siblings changed event from the arguments
	@param [View] newParent -- the new parent view
	@param [View] oldParent -- the old parent view
]]
function ParentChangedInterfaceEvent:init( newParent, oldParent )
	self.newParent = newParent
	self.oldParent = oldParent
end
