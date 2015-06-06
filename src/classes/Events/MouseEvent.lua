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
	-- TODO: still need to figure this out
end