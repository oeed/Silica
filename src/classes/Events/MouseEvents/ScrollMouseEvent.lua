
class "ScrollMouseEvent" extends "MouseEvent" {
	eventType = Event.MOUSE_SCROLL;
	direction = nil;
}

--[[
	@constructor
	@desc Creates a click mouse event from the arguments
	@param [table] arguments -- the event arguments
]]
function ScrollMouseEvent:init( arguments )
	self.super:init( arguments )

	if #arguments >= 4 then
		self.direction = arguments[2]
		self.x = arguments[3]
		self.y = arguments[4]
		self.globalX = arguments[3]
		self.globalY = arguments[4]
	end
end
