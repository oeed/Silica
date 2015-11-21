
class "CharacterEvent" extends "Event" {
    static = {
        eventType = "char";
    };
	character = false;
}

--[[
	@constructor
	@desc Creates a char event from the arguments
	@param [string] character -- the event character
]]
function CharacterEvent:initialise( character )
	self.character = character
end
