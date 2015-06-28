
class "KeyboardShortcut" {
	keys = {};
}

--[[
	@instance
	@desc Creates a keyboard shortcut
	@param ... -- all the keys for the shortcut
]]
function KeyboardShortcut:init( ... )
	self.keys = { ... }
end

--[[
	@instance
	@desc Compares the shortcut to a keyboard shortcut event
	@param [KeyboardShortcutEvent] event -- the keyboard shortcut event
	@param [type] arg2 -- description
	@param [type] arg3 -- description
	@return [boolean] isMatch -- whether the keyboard shortcut was a match (i.e. the keys are down)
]]
function KeyboardShortcut:matchesEvent( event )
	local eventKeys = event.keys
	for i, keyCode in ipairs( self.keys ) do
		if not eventKeys[keyCode] then
			return false
		end
	end

	local eventKeysLength = 0
	for keyCode, _ in pairs( eventKeys ) do
		eventKeysLength = eventKeysLength + 1
	end

	return eventKeysLength == #self.keys
end
