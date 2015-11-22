
class "ChildRemovedInterfaceEvent" extends "InterfaceEvent" {
    static = {
        eventType = "interface_child_removed";
    };
	childView = false; -- the removed child
	isSentToChildren = Boolean( false );
}

--[[
	@constructor
	@desc Creates a child removed event from the arguments
	@param [View] childView -- the removed child
]]
function ChildRemovedInterfaceEvent:initialise( childView )
	self.childView = childView
end
