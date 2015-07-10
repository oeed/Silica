
class "TextInput" {
	owner = false;
	isEnabled = false; -- whether or not the text input should act upon keyboard events
	text = false;
	isMultiline = false;
	cursorPositionX = 1;
	cursorPositionY = 1;
}

--[[
    @constructor
    @desc Creates a text input and connects the event handlers
	@param [class] owner -- the class to recieve the events
	@param [string] text -- the starting text
	@param [bool] isMultiline -- whether the text input supports multilines (TODO: unfocuses on enter by default if false)
]]
function TextInput:init( owner, text, isMultiline )
	self.event = EventManager( self )
    self.owner = owner
    self.text = text or ""
    self.isMultiline = isMultiline or false

    self:event( Event.KEY_UP, self.onKeyUp )
    self:event( Event.KEY_DOWN, self.onKeyDown )
    self:event( Event.CHARACTER, self.onCharacter )
end

--[[
	@instance
	@desc Sets the text of the input, informing the owner
	@param [string] text -- the new text value
]]
function TextInput:setText( text )
	local oldText = self.text
	self.text = text
	if self.owner then
		self.owner.event:handleEvent( TextChangedInterfaceEvent( text, oldText ) )
	end
end

--[[
    @instance
    @desc Fired when a key is pressed down
    @param [KeyDownEvent] event -- the key down event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function TextInput:onKeyDown( event )
    if self.isEnabled then
    	local keyCode = event.keyCode
    	local text = self.text

    	if keyCode == keys.backspace then
    		self.text = text:sub( 1, #text - 1 )
    	end

    end
end

--[[
    @instance
    @desc Fired when a key is released
    @param [KeyUpEvent] event -- the key up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function TextInput:onKeyUp( event )
    if self.isEnabled then
    	
    end
end

--[[
    @instance
    @desc Fired when a key is released
    @param [CharacterEvent] event -- the key up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function TextInput:onCharacter( event )
    if self.isEnabled then
    	local text = self.text
    	self.text = text .. event.character
    end
end
