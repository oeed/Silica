
class "TimerEvent" extends "Event" {
	eventType = Event.TIMER;
	timer = nil;
}

--[[
	@constructor
	@desc Creates a timer event from the arguments
	@param [table] arguments -- the event arguments
]]
function TimerEvent:init( arguments )
	self.super:init( arguments )

	if #arguments >= 2 then
		self.timer = arguments[2]
	end
end
