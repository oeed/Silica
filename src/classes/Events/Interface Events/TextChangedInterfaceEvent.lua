
class "TextChangedInterfaceEvent" extends "InterfaceEvent" {
	eventType = Event.TEXT_CHANGED;
	text = false; -- the new text value
	oldText = false; -- the previous text value
}

--[[
	@constructor
	@desc Creates a Text event from the arguments
	@param text -- the new text value
	@param oldText -- the old text value
]]
function TextChangedInterfaceEvent:init( text, oldText )
	self.text = text
	self.oldText = oldText
end
