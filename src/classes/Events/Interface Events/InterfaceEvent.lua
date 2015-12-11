
class "InterfaceEvent" extends "Event" {

	owner = false;

}

--[[
	@constructor
	@desc Creates an interface event from the arguments
	@param [class] owner -- the owner view
]]
function InterfaceEvent:initialise( owner )
	self.owner = owner
end
