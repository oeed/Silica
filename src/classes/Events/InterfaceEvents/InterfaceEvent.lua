
class "InterfaceEvent" extends "Event" {
	owner = nil;
}

--[[
	@constructor
	@desc Creates an interface event from the arguments
	@param [class] owner -- the owner view
]]
function InterfaceEvent:init( owner )
	self.super:init( { self.eventType } )
	self.owner = owner
end
