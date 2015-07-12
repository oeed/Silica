
class "MouseScrollEvent" extends "MouseEvent" {
	eventType = Event.MOUSE_SCROLL;
	direction = false;
}

--[[
	@constructor
	@desc Creates a click mouse event from the arguments
	@param [MouseEvent.direction] direction -- the direction of the scroll
	@param [number] x -- the x screen coordinate
	@param [number] y -- the y screen coordinate
]]
function MouseScrollEvent:init( direction, x, y )
	self.direction = direction
	self.x = x
	self.y = y
	self.globalX = x
	self.globalY = y
end

