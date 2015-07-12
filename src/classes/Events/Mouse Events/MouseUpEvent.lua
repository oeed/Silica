
class "MouseUpEvent" extends "MouseEvent" {
	eventType = Event.MOUSE_UP;
	mouseButton = false;
}

--[[
	@constructor
	@desc Creates a click mouse event from the arguments
	@param [MouseEvent.mouseButtons] mouseButton -- the mouse button (left, right, etc.)
	@param [number] x -- the x screen coordinate
	@param [number] y -- the y screen coordinate
]]
function MouseUpEvent:init( mouseButton, x, y )
	self.mouseButton = mouseButton
	self.x = x
	self.y = y
	self.globalX = x
	self.globalY = y
end

