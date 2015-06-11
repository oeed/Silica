
class "DragMouseEvent" extends "MouseEvent" {
	eventType = Event.MOUSE_DRAG;
	mouseButton = nil;
}

--[[
	@instance
	@desc Creates a click mouse event from the arguments
	@param [table] arguments -- the event arguments
]]
function DragMouseEvent:init( arguments )
	self.super:init( arguments )

	if #arguments >= 4 then
		self.mouseButton = arguments[2]
		self.x = arguments[3]
		self.y = arguments[4]
		self.globalX = arguments[3]
		self.globalY = arguments[4]
	end
end
