
local function split(a,e)
    local t,e=e or":",{}
    local t=string.format("([^%s]+)",t)
    a:gsub(t,function(t)e[#e+1]=t end)
    return e
end

class "KeyboardShortcut" {
	keys = {};
}

--[[
	@constructor
	@desc Creates a keyboard shortcut
	@param ... -- all the keys for the shortcut
]]
function KeyboardShortcut:initialise( ... )
	self.keys = { ... }
end

--[[
	@desc Returns the symbol string to be used on menus and elsewhere to represent the shortcut
	@return [string] symbols -- the symbols string
]]
function KeyboardShortcut:symbols()
	local symbols = ""
	local symbol = KeyboardShortcutManager.symbol
	for i, keyString in ipairs( self.keys ) do
		symbols = symbols .. symbol( keyString )
	end
	return symbols
end

--[[
	@desc Creates a keyboard shortcut from a string. Each key is separated by a space. Keys represented by a character (i.e. a, 5, /) should be written as the character. Other posibilities are: ctrl (also acts as command on OS X), alt, shift, tab, esc, delete, backspace, enter, left, right, up, down, fn, home, end, f1, f2 .. f12
	@param [string] keys -- the shortcut string
	@return [KeyboardShortcut] keyboardShortcut -- the keyboard shortcut
]]
function KeyboardShortcut.static:fromString( str )
	local parts = split( str, " " )
	local keys = {}

	local static = KeyboardShortcutManager.static
	for i, key in ipairs( parts ) do
		if #key > 0 then
			if static:isValid( key ) then
				table.insert( keys, key )
			else
				error( "Invalid keyboard shortcut '" .. str .."'. The key '" .. key .. "' is not valid. Omit sides (i.e. leftShift is just shift) and use the character where possible (i.e. / not slash)", 0 )
			end
		end
	end

	return KeyboardShortcut( unpack( keys ) )
end

--[[
	@desc Compares the shortcut to a keyboard shortcut event
	@param [KeyboardShortcutEvent] event -- the keyboard shortcut event
	@return [boolean] isMatch -- whether the keyboard shortcut was a match (i.e. the keys are down)
]]
function KeyboardShortcut:matchesEvent( event )
	return event:matchesKeys( self.keys )
end
