
local keyStrings = {
	nil,	"1", 	"2", 	"3",	"4",
	"5", 	"6", 	"7", 	"8", 	"9",
	"0", 	"-", 	"=", 	"backspace","tab",
	"q", 	"w", 	"e", 	"r",	"t",
	"y",	"u",	"i",	"o",	"p",
	"(",	")",	"enter","ctrl","a",
	"s",	"d",	"f",	"g",	"h",
	"j",	"k",	"l",	";",	"'",
	"`",	"shift","\\",	"z",	"x",
	"c",	"v",	"b",	"n",	"m",
	",",	".",	"/",	"shift",nil,
	"alt",	nil,	nil,	"f1",	"f2",
	"f3",	"f4",	"f5",	"f6",	"f7",
	"f8",	"f9",	"f10",	[87] = "f11",
	[88] = "f12",	[153] = "ctrl",
	[199] = "home",	[207] = "end",
	[184] = "alt",	[200] = "up",
	[203] = "left",	[205] = "right",
	[208] = "down",	[211] = "delete",				
	[219] = "ctrl",	[220] = "ctrl",				
}

local keySymbols = {
	-- TODO: tab, left, right, up down, delete
	backspace = string.char( 144 );
	enter = string.char( 157 );
	ctrl = string.char( 141 );
	shift = string.char( 129 );
	alt = string.char( 143 );
}

class "KeyboardShortcutManager" {
	keysDown = {};
	keysUpdates = {};
	owner = false;
	event = false;
}

function KeyboardShortcutManager:initialise( owner )
	self.owner = owner
	self.event = EventManager( self )
	self.event:connectGlobal( KeyDownEvent, self.onGlobalKeyDown )
	self.event:connectGlobal( KeyUpEvent, self.onGlobalKeyUp )
end

function KeyboardShortcutManager:onGlobalKeyDown( Event event, Event.phases phase )
	local keyString = event.keyString
	if keyString then
		self.keysDown[keyString] = true
		self.keysUpdates[keyString] = os.clock()
		self.owner:schedule( self.onKeyTimeout, 10, self, keyString )
		return self:sendEvent()
	end
end

function KeyboardShortcutManager:onGlobalKeyUp( Event event, Event.phases phase )
	local keyString = event.keyString
	self.keysDown[keyString] = nil
	self.keysUpdates[keyString] = os.clock()
end

function KeyboardShortcutManager:isKeyDown( keyString )
	return self.keysDown[keyString] == true
end

function KeyboardShortcutManager:isOnlyKeyDown( keyString )
	local keysDown = self.keysDown
	for k, v in pairs( keysDown ) do
		if k ~= keyString then
			if v then
				return false
			end
		elseif not v then
			return false
		end
	end
	return keysDown[keyString] == true
end

--[[
	@desc Returns the symbol for a keyString for places such as menus
	@return [string] keyString -- the string value of the key
	@return [string] symbol -- the symbol
]]
function KeyboardShortcutManager.static:symbol( keyString )
	return ( not keyString and "" or keySymbols[keyString] or keyString:upper() )
end

--[[
	@desc Converts a keys API code to the common string value used throughout Silica
	@param [number] keyCode -- the numerical value of the key
	@return [string] keyString -- the string value of the key
]]
function KeyboardShortcutManager.static:convert( keyCode )
	return keyStrings[keyCode]
end

--[[
	@desc Returns true if the given key string is valid
	@param [string] keyString -- the string value of the key
	@return [boolean] isValid -- whether the key string is valid
]]
function KeyboardShortcutManager.static:isValid( keyString )
	if not keyString then return false end
	for i, _keyString in pairs( keyStrings ) do
		if _keyString == keyString then
			return true
		end
	end
	return false
end

--[[
	@desc Send the keyboard shortcut event of the currently held keys
]]
function KeyboardShortcutManager:sendEvent()
	return self.owner.event:handleEvent( KeyboardShortcutEvent( self.keysDown ) )
end

--[[
	@desc Fires 10 seconds after a key was pressed. If the key status hasn't changed it sets it to not be pressed.
	@param [string] keyString -- the key string
]]
function KeyboardShortcutManager:onKeyTimeout( keyString )
	if os.clock() - self.keysUpdates[keyString] >= 10 then
		self.keysDown[keyString] = nil
		self.keysUpdates[keyString] = os.clock()
	end
end
