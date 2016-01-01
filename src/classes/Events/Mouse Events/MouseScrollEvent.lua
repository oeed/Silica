
class MouseScrollEvent extends MouseEvent {

    static = {
        eventType = "mouse_scroll";
    };
	direction = false;

}

--[[
	@constructor
	@desc Creates a click mouse event from the arguments
	@param [MouseEvent.direction] direction -- the direction of the scroll
	@param [number] x -- the x screen coordinate
	@param [number] y -- the y screen coordinate
]]
function MouseScrollEvent:initialise( direction, x, y )
	self.direction = direction
	self.x = x
	self.y = y
	self.globalX = x
	self.globalY = y
end

