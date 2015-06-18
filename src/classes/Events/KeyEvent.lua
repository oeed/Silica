
class "KeyEvent" extends "Event" {
	eventType = Event.KEY;
	keyCode = nil;
	isCharacter = nil;
}

--[[
	@constructor
	@desc Creates a key event from the arguments
	@param [table] arguments -- the event arguments
]]
function KeyEvent:init( arguments )
	self.super:init( arguments )

	if #arguments >= 2 then
		local keyCode = arguments[2] 
		self.keyCode = keyCode
		-- TODO: this needs testing
		self.isCharacter = (2 <= keyCode and keyCode <= 13) or (16 <= keyCode and keyCode <= 27) or (30 <= keyCode and keyCode <= 41) or (44 <= keyCode and keyCode <= 53)
	end
end
