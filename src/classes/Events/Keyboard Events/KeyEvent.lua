
class "KeyEvent" extends "Event" {
	keyCode = false;
	keyString = false;
	isCharacter = false;
}

--[[
	@constructor
	@desc Creates a key event from the arguments
	@param [number] keyCode -- the key's numerical key code
]]
function KeyEvent:initialise( keyCode )
	self.keyCode = keyCode
	self.keyString = KeyboardShortcutManager.convert( keyCode ) or false
	-- TODO: this needs testing
	self.isCharacter = (2 <= keyCode and keyCode <= 13) or (16 <= keyCode and keyCode <= 27) or (30 <= keyCode and keyCode <= 41) or (44 <= keyCode and keyCode <= 53)
end
