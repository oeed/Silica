
class "MouseEvent" extends "Event" {
	x = 0;
	y = 0;
	globalX = 0;
	globalY = 0;

	mouseButtons = {
		LEFT = 1;
		MIDDLE = 3;
		RIGHT = 2;
	};

	directions = {
		UP = -1;
		DOWN = 1;
	};
}

--[[
	@instance
	@desc Make the event's coordinates relative to the supplied view
	@param [View] view -- the view who's coordinate system will be used
]]
function MouseEvent:makeRelative( view )
	local oldRelativeView = self.relativeView
	self.super:makeRelative( view )
	
	local x, y = self.x, self.y

	if oldRelativeView and oldRelativeView == view then
		-- return
	elseif oldRelativeView and oldRelativeView == view.parent then
		-- we are going 1 downward in to the stack
		x = x - view.x + 1
		y = y - view.y + 1
	elseif oldRelativeView and oldRelativeView.parent == view then
		-- we are going 1 upward in to the stack
		x = x + oldRelativeView.x - 1
		y = y + oldRelativeView.y - 1
	else
		-- we don't known exactly where the previous view was
		x, y = view:coordinates( self.globalX, self.globalY, self.application.container )
	end
	self.x = x
	self.y = y
end
