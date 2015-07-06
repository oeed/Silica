
class "MouseDragEvent" extends "MouseEvent" {
	eventType = Event.MOUSE_DRAG;
	mouseButton = false;
}

--[[
	@constructor
	@desc Creates a click mouse event from the arguments
	@param [MouseEvent.mouseButtons] mouseButton -- the mouse button (left, right, etc.)
	@param [number] x -- the x screen coordinate
	@param [number] y -- the y screen coordinate
]]
function MouseDragEvent:init( mouseButton, x, y )
	self.mouseButton = mouseButton
	self.x = x
	self.y = y
	self.globalX = globalX
	self.globalY = globalY
end

