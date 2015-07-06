
class "KeyboardShortcutEvent" extends "Event" {
	eventType = Event.KEYBOARD_SHORTCUT;
	keys = false;
}

--[[
	@constructor
	@desc Creates a key event from the arguments
	@param [table] arguments -- the event arguments
]]
function KeyboardShortcutEvent:init( keys )
	self.keys = keys
end
