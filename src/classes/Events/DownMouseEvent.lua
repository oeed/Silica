class "DownMouseEvent" extends "MouseEvent" {
	eventType = Event.MOUSE_DOWN;
	mouseButton = nil;
}

--[[
	@instance
	@desc Creates a click mouse event from the arguments
	@param [table] arguments -- the event arguments
]]
function DownMouseEvent:init( arguments )
	self.super:init( arguments )

	if #arguments >= 4 then
		self.mouseButton = arguments[2]
		self.x = arguments[3]
		self.y = arguments[4]
	end
end