
class "CharacterEvent" extends "Event" {
	eventType = Event.CHARACTER;
	character = false;
}

--[[
	@constructor
	@desc Creates a char event from the arguments
	@param [string] character -- the event character
]]
function CharacterEvent:init( character )
	self.character = character
end
