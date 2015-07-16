
class "TimerEvent" extends "Event" {
	eventType = Event.TIMER;
	timer = false;
}

--[[
	@constructor
	@desc Creates a timer event from the arguments
	@param [number] time -- the ID of the timer
]]
function TimerEvent:initialise( timer )
	self.timer = timer
end
