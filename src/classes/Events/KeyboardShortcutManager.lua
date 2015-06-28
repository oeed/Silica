
class "KeyboardShortcutManager" {
	keysDown = {};
	keysUpdates = {};
	owner = nil;
	event = nil;
}

function KeyboardShortcutManager:init( owner )
	self.owner = owner
	self.event = EventManager( self )
	self.event:connectGlobal( Event.KEY_DOWN, self.onGlobalKeyDown )
	self.event:connectGlobal( Event.KEY_UP, self.onGlobalKeyUp )
end

function KeyboardShortcutManager:onGlobalKeyDown( event )
	local keyCode = event.keyCode
	self.keysDown[keyCode] = true
	self:sendEvent()
	self.keysUpdates[keyCode] = os.clock()
	self.owner:schedule( self.onKeyTimeout, 10, self, keyCode )
end

function KeyboardShortcutManager:onGlobalKeyUp( event )
	local keyCode = event.keyCode
	self.keysDown[keyCode] = nil
	self.keysUpdates[keyCode] = os.clock()
end

--[[
	@instance
	@desc Send the keyboard shortcut event of the currently held keys
]]
function KeyboardShortcutManager:sendEvent()
	self.owner.event:handleEvent( KeyboardShortcutEvent( self.keysDown ) )
end

--[[
	@instance
	@desc Fires 10 seconds after a key was pressed. If the key status hasn't changed it sets it to not be pressed.
	@param [number] keyCode -- the key code
]]
function KeyboardShortcutManager:onKeyTimeout( keyCode )
	if os.clock() - self.keysUpdates[keyCode] >= 10 then
		self.keysDown[keyCode] = nil
		self.keysUpdates[keyCode] = os.clock()
	end
end
