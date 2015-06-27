
class "MenuChangedInterfaceEvent" extends "InterfaceEvent" {
	eventType = Event.MENU_CHANGED;
	owner = nil;
}

--[[
	@constructor
	@desc Creates a interface event from the arguments
	@param [class] owner -- the owner view
]]
function MenuChangedInterfaceEvent:init( owner )
	self.super:init( owner )
end
