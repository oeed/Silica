
class "MouseDownEvent" extends "MouseEvent" {
	eventType = Event.MOUSE_DOWN;
	mouseButton = false;
}

--[[
	@constructor
	@desc Creates a click mouse event from the arguments
	@param [MouseEvent.mouseButtons] mouseButton -- the mouse button (left, right, etc.)
	@param [number] x -- the x screen coordinate
	@param [number] y -- the y screen coordinate
]]
function MouseDownEvent:initialise( mouseButton, x, y )
	self.mouseButton = mouseButton
	self.x = x
	self.y = y
	self.globalX = x
	self.globalY = y
end
