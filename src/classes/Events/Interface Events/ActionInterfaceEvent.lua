
class "ActionInterfaceEvent" extends "InterfaceEvent" {
	eventType = "interface_action";
	sender = false; -- the view whose action it is
}

--[[
	@constructor
	@desc Creates a focus event from the arguments
	@param [View] sender -- the view whose action it is
]]
function ActionInterfaceEvent:initialise( sender )
	self.sender = sender
end

