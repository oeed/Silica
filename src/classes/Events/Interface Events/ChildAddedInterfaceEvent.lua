
class "ChildAddedInterfaceEvent" extends "InterfaceEvent" {
    static = {
        eventType = "interface_child_added";
    };
	childView = false; -- the added child
	isSentToChildren = Boolean( false );
}

--[[
	@constructor
	@desc Creates a child added event from the arguments
	@param [View] childView -- the added child
]]
function ChildAddedInterfaceEvent:initialise( childView )
	self.childView = childView
end
