
class "ReadyInterfaceEvent" extends "InterfaceEvent" {
	eventType = Event.INTERFACE_READY;
	isInit = false; -- whether the event is the first one called in Application:initialise
}

--[[
	@constructor
	@desc Creates a ready event from the arguments
	@param isInit -- whether the event is the first one called in Application:initialise
]]
function ReadyInterfaceEvent:initialise( isInit )
	self.isInit = isInit or false
end

