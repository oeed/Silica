
class CharacterEvent extends Event {

    static = {
        eventType = "char";
    };
	character = String;

}

--[[
	@constructor
	@desc Creates a char event from the arguments
	@param [string] character -- the event character
]]
function CharacterEvent:initialise( String character )
	self.character = character
end
