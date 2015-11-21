
class "KeyboardShortcutEvent" extends "Event" {
    static = {
        eventType = "interface_keyboard_shortcut";
    };
	keys = false;
}

--[[
	@constructor
	@desc Creates a key event from the arguments
	@param [table] arguments -- the event arguments
]]
function KeyboardShortcutEvent:initialise( keys )
	self.keys = keys
end

--[[
	@instance
	@desc Returns true if the keys in the given table match those of the event
	@param [table] keys -- a table of keys (key strings like { 'ctrl', 'a' })
	@param [type] arg2 -- description
	@param [type] arg3 -- description
	@return [type] returnedValue -- description
]]
function KeyboardShortcutEvent:matchesKeys( keys )
	local eventKeys = self.keys
	for i, keyString in ipairs( keys ) do
		if not eventKeys[keyString] then
			return false
		end
	end

	local eventKeysLength = 0
	for keyString, _ in pairs( eventKeys ) do
		eventKeysLength = eventKeysLength + 1
	end

	return eventKeysLength == #keys
end