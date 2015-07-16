
class "InterfaceOutletChangedInterfaceEvent" extends "InterfaceEvent" {
	eventType = Event.INTERFACE_OUTLET_CHANGED;
	interfaceOutlet = false;
	oldView = false;
	newView = false;
	isSentToChildren = false;
	isSentToSender = false;
}

--[[
	@constructor
	@desc Creates a focus event from the arguments
	@param interfaceOutlet -- the interface outlet that changed
	@param newView -- the new view the outlet is bound to
	@param oldView -- the old view the outlet was bound to
]]
function InterfaceOutletChangedInterfaceEvent:initialise( interfaceOutlet, newView, oldView )
	self.interfaceOutlet = interfaceOutlet
	self.newView = newView
	self.oldView = oldView
end
