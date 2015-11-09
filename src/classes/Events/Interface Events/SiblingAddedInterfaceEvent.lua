
class "SiblingAddedInterfaceEvent" extends "InterfaceEvent" {
	eventType = "interface_sibling_added";
	view = false; -- the new sibling that was added
	isSentToChildren = false;
}

--[[
	@constructor
	@desc Creates a siblings changed event from the arguments
	@param [View] view -- the new sibling view
]]
function SiblingAddedInterfaceEvent:initialise( view )
	self.view = view
end
