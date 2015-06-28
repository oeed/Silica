
class "KeyboardShortcutEvent" extends "Event" {
	eventType = Event.KEYBOARD_SHORTCUT;
	keys = nil;
}

--[[
	@constructor
	@desc Creates a key event from the arguments
	@param [table] arguments -- the event arguments
]]
function KeyboardShortcutEvent:init( keys )
	self.super:init( { Event.KEYBOARD_SHORTCUT } )
	self.keys = keys
end
