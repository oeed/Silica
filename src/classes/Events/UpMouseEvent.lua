class "UpMouseEvent" extends "MouseEvent" {
	eventType = Event.MOUSE_UP;
	mouseButton = nil;
}

--[[
	@instance
	@desc Creates an up mouse event from the arguments
	@param [table] arguments -- the event arguments
]]
function UpMouseEvent:init( arguments )
	self.super:init( arguments )

	if #arguments >= 4 then
		self.mouseButton = arguments[2]
		self.x = arguments[3]
		self.y = arguments[4]
	end
end