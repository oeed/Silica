
class "ChildRemovedInterfaceEvent" extends "InterfaceEvent" {

    static = {
        eventType = "interface_child_removed";
    };

    container = Container;
    childView = View; -- the added child
    isSentToChildren = Boolean( false );
    isSentToParents = Boolean( true );

}

--[[
	@constructor
	@desc Creates a child removed event from the arguments
	@param [View] childView -- the removed child
]]
function ChildRemovedInterfaceEvent:initialise( View childView, Container container )
	self.childView = childView
    self.container = container
end
