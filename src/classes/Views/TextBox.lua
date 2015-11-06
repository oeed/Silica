
--[[
	TODO
		Shift clicking
		Shift-left/right
		Ctrl-left/right
		Home
		End
		Delete
		Ctrl-shift-left/right
		Ctrl-a
]]

local CURSOR_ANIMATION_SPEED = 0.45

local floor = math.floor

class "TextBox" extends "View" {

	height = 15; -- the default height
	width = 120;
	text = "";
	placeholder = "";

	font = false;

	backgroundObject = false;
	textObject = false;
	placeholderObject = false;
	cursorObject = false;
	selectionObject = false;
	cursorFlashCounter = 0;

	leftMargin = 0;
	rightMargin = 0;
	isFocused = false;
	isPressed = false;
	isMasked = false; -- whether bullets are shown instead of characters (for passwords)

	scroll = 0;
	cursorPosition = 1;
	maximumLength = false;
	selectionPosition = false;

}

--[[
	@constructor
	@desc Creates a text box view and connects the event handlers
]]
function TextBox:initialise( ... )
	self.super:initialise( ... )
	self:event( Event.KEY_UP, self.onKeyUp )
	self:event( Event.KEY_DOWN, self.onKeyDown )
	self:event( Event.CHARACTER, self.onCharacter )
	self:event( Event.MOUSE_DOWN, self.onMouseDown )
	self:event( Event.MOUSE_UP, self.onMouseUp )
	self:event( Event.MOUSE_DRAG, self.onMouseDrag )
    self:event( Event.KEYBOARD_SHORTCUT, self.onKeyboardShortcut )
    	self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
end

--[[
	@instance
	@desc Sets up the canvas and it's graphics objects
]]
function TextBox:initialiseCanvas()
	self.super:initialiseCanvas()
	local width, height, theme = self.width, self.height, self.theme
	local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, width, height, theme.fillColour, theme.outlineColour, cornerRadius ) )
	local selectionObject = self.canvas:insert( Rectangle( 0, 4, 1, self.height - 6 ) )
	local placeholderObject = self.canvas:insert( Text( self.leftMargin, 5, self.width, 10, self.text ) )
	local textObject = self.canvas:insert( Text( self.leftMargin, 5, self.width, 10, self.placeholder ) )
	local cursorObject = self.canvas:insert( Cursor( 0, 4, self.height - 6 ) )
	cursorObject.isVisible = false
	selectionObject.isVisible = false

	theme:connect( backgroundObject, "fillColour" )
	theme:connect( backgroundObject, "outlineColour" )
	theme:connect( backgroundObject, "radius", "cornerRadius" )
	theme:connect( textObject, "textColour" )
	theme:connect( placeholderObject, "textColour", "placeholderColour" )
	theme:connect( cursorObject, "fillColour", "cursorColour" )
	theme:connect( selectionObject, "fillColour", "selectionColour" )
	theme:connect( self, "leftMargin" )
	theme:connect( self, "rightMargin" )

	self.backgroundObject = backgroundObject
	self.textObject = textObject
	self.placeholderObject = placeholderObject
	self.cursorObject = cursorObject
	self.selectionObject = selectionObject

	if not self.font then
		self.font = Font.systemFont
	end
end

function TextBox:update( deltaTime )
	self.super:update( deltaTime )

	if self.isFocused then
		local cursorFlashCounter = self.cursorFlashCounter
		local visible = cursorFlashCounter % 2 < 1
		local rem = cursorFlashCounter % 1
		local colour
		if rem > .85 then
			if visible then
				colour = ( rem > .95 and colours.lightGrey ) or colours.grey
			else
				colour = ( rem > .95 and colours.grey ) or colours.lightGrey
				visible = true
			end
		else
			colour = colours.black
		end
		self.cursorObject.fillColour = colour
		self.cursorObject.isVisible = visible
		self.cursorFlashCounter = cursorFlashCounter + deltaTime
	end
end

function TextBox:updateHeight( height )
	self.backgroundObject.height = height
end

function TextBox:updateWidth( width )
	self.backgroundObject.width = width
	local textObject = self.textObject
	textObject.x = self.leftMargin + 1 - self.scroll
	textObject.width = width - self.leftMargin - self.rightMargin
	local placeholderObject = self.placeholderObject
	placeholderObject.x = self.leftMargin + 1
	placeholderObject.width = width - self.leftMargin - self.rightMargin
end

function TextBox:updateSelection()
	local selectionObject = self.selectionObject
	local leftMargin = self.leftMargin
	local cursorPosition = self.cursorPosition
	local selectionPosition = self.selectionPosition

	local isVisible = selectionObject.isVisible
	if not selectionPosition then--or cursorPosition == selectionPosition then
		if isVisible then selectionObject.isVisible = false end
	else
		local cursorX = leftMargin + math.max( self:charToViewCoords( cursorPosition ) - 1, 1 ) - self.scroll
		local selectionX = leftMargin + math.max( self:charToViewCoords( selectionPosition ) - 1, 1 ) - self.scroll

		if not isVisible then selectionObject.isVisible = true end

		local x, width, f
		if cursorX == selectionX then
			-- if isVisible then selectionObject.isVisible = false end
			local _x, _width = selectionObject.x, selectionObject.width
			x = math.floor( _x + _width / 2 )
			width = 0
			f = function() selectionObject.isVisible = false end
		else
			x = math.min( cursorX, selectionX )
			width = math.max( cursorX, selectionX ) - x
		end

		if not isVisible then
			selectionObject.x = x
			selectionObject.width = width
		else
			self:animate( "selectionX", x, CURSOR_ANIMATION_SPEED, f, Animation.easing.OUT_QUART )
			self:animate( "selectionWidth", width, CURSOR_ANIMATION_SPEED, nil, Animation.easing.OUT_QUART )
		end
	end
end

--[[
	@instance
	@desc Converts the coordinates relative to the text box to the character position
	@param [number] x -- the x coordinate
	@return [number] characterPosition -- the charcter position
]]
function TextBox:viewToCharCoords( x )
	if x <= 0 then
		return 1
	end
	local font = self.font
	local width = font.getWidth
	local text = self.isMasked and string.rep( string.char( 149 ), #self.text ) or self.text
	for i = 1, #text do
		local cw = width( font, text:sub( i, i ) )
		if x <= cw / 2 then
			return i
		end
		x = x - cw
	end
	return #text + 1
end

function TextBox:charToViewCoords( char )
	local text = self.isMasked and string.rep( string.char( 149 ), #self.text ) or self.text
	return self.font:getWidth( text:sub( 1, char - 1 ) ) + 1
end

--[[
	@instance
	@desc Callback to check whether a character entered by the user is valid, intended to be overridden by sub-classes
	@param [string] character
	@return [boolean] isValid
]]
function TextBox:isValidChar( character )
	return true
end

function TextBox:setScroll( scroll )
	self.scroll = scroll
	self.textObject.x = self.leftMargin + 1 - self.scroll
	self:updateSelection()
	self:updateCursorPosition()
end

function TextBox:setCursorPosition( cursorPosition )
	cursorPosition = math.max( math.min( cursorPosition, #self.text + 1 ), 1 )
	self.cursorPosition = cursorPosition
	self.cursorFlashCounter = 0
	if self:charToViewCoords( cursorPosition ) - self.scroll < 1 then
		self.scroll = self:charToViewCoords( cursorPosition ) - 1
	elseif self:charToViewCoords( cursorPosition ) - self.scroll > ( self.width - self.leftMargin - self.rightMargin ) then
		self.scroll = self:charToViewCoords( cursorPosition ) - ( self.width - self.leftMargin - self.rightMargin )
	end

	self:updateCursorPosition()
end

function TextBox:setCursorX( x )
	self.cursorObject.x = x
end

function TextBox:getCursorX()
	return self.cursorObject.x
end

function TextBox:setSelectionX( x )
	self.selectionObject.x = x
end

function TextBox:getSelectionX()
	return self.selectionObject.x
end

function TextBox:setSelectionWidth( width )
	self.selectionObject.width = width
end

function TextBox:getSelectionWidth()
	return self.selectionObject.width
end

function TextBox:updateCursorPosition()
	local value = self.leftMargin + math.max( self:charToViewCoords( self.selectionPosition or self.cursorPosition ) - 1, 1 ) - self.scroll
	self:animate( "cursorX", value, CURSOR_ANIMATION_SPEED, nil, Animation.easing.OUT_QUART )
end

function TextBox:setSelectionPosition( selectionPosition )
	self.selectionPosition = selectionPosition
	self.cursorFlashCounter = 0
	self:updateSelection()
	self:updateCursorPosition()
end

--[[
	@instance
	@desc ima leave this... until floobits,.. just yeah
	es@param [string] character
	@return [boolean] isValid
]]
local sub = string.sub -- move to top
local concat = table.concat
function TextBox:write( text )
	local t = {}
	local valid = self.isValidChar
	for i = 1, #text do
		local char = sub( text, 1, 1 )
		if valid( self, char ) then
			t[#t + 1] = char
		end
	end
	local text = self.text
	local s = concat( t )
	local cp, sp = self.cursorPosition, self.selectionPosition
	if sp then
		sp = sp - 1
		self.text = text:sub( 1, math.min( cp, sp ) - 1 ) .. s .. text:sub( math.max( cp, sp ) + 1 )
		self.cursorPosition =  math.min( cp, sp ) + #s
		self.selectionPosition = false
	else
		self.text = text:sub( 1, cp - 1 ) .. s .. text:sub( cp )
		self.cursorPosition =  cp + #s
	end
end

--[[
	@instance
	@desc Returns the character at the given character position
	@param [number] characterPosition -- the character position
	@return [string] character -- the character
]]
function TextBox:charCoordsToChar( characterPosition )
	return character
end

--[[
	@instance
	@desc What does this actually do?
	@param [type] arg1 -- description
	@param [type] arg2 -- description
	@param [type] arg3 -- description
	@return [type] returnedValue -- description
]]
function TextBox:charToCharCoords( arg1, arg2, arg3 )
	return returnedValue
end

--[[
	@instance
	@desc Converts the character position to screen coordinates
	@param [number] characterPosition -- the position of the character
	@return [number] x -- the x coordinate realtive to the text box
	@return [number] y -- the y coordinate realtive to the text box
]]
function TextBox:charCoordsToViewCoordinates( characterPosition )
	return x, y
end

--[[
	@instance
	@desc Set the text of the text box.
	@param [string] text -- the text of the text box
]]
function TextBox:setText( text )
	self.text = text
	self.textObject.text = self.isMasked and string.rep( string.char( 149 ), #text ) or text
	self.placeholderObject.isVisible = #text == 0
end

function TextBox:setPlaceholder( placeholder )
	self.placeholder = placeholder
	local placeholderObject = self.placeholderObject
	if placeholderObject then
		placeholderObject.text = placeholder or ''
	end
end

function TextBox:setIsMasked( isMasked )
	self.isMasked = isMasked
	self.text = self.text
end

--[[
	@instance
	@desc Set the margin on either side of the text
	@param [number] margin -- the space around the text
]]
function TextBox:setMargin( margin )
	self.leftMargin = margin
	self.rightMargin = margin
end

function TextBox:setFont( font )
	self.font = font
	local textObject = self.textObject
	if textObject then
		textObject.font = font
		self.placeholderObject.font = font
		self.cursorObject.height = font.height + 1
		self.selectionObject.height = font.height + 1
	end
end

function TextBox:updateThemeStyle()
	self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or ( self.isFocused and "focused" or "default" ) ) or "disabled"
end

function TextBox:setIsPressed( isPressed )
	self.isPressed = isPressed
	self:updateThemeStyle()
end

function TextBox:setIsEnabled( isEnabled )
	self.isEnabled = isEnabled
	if not isEnabled then
		self:unfocus()
	end
	self:updateThemeStyle()
end

function TextBox:setIsFocused( isFocused )
	self.isFocused = isFocused
	self.cursorObject.isVisible = isFocused
	self.cursorPosition = self.cursorPosition or 1
	self.isFocused = isFocused
	self:updateThemeStyle()
end

--[[
	@instance
	@desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
	@param [Event] event -- the mouse up event
	@return [boolean] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onGlobalMouseUp( event )
	if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
		self.isPressed = false
		if self.isEnabled and self:hitTestEvent( event ) then
			return self.event:handleEvent( event )
		end
	end
end

--[[
	@instance
	@desc Fired when the mouse is released. Focuses on the text box
	@param [MouseDownEvent] event -- the mouse down event
	@return [boolean] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onMouseUp( event )
	if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
		self:focus()
	end
	return true
end

--[[
	@instance
	@desc Fired when the mouse is pushed anywhere on screen. Adds the pressed appearance.
	@param [MouseDownEvent] event -- the mouse down event
	@return [boolean] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onMouseDown( event )
	if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
		self.isPressed = true
		self.cursorPosition = self:viewToCharCoords( event.x - self.leftMargin + self.scroll )
		self.selectionPosition = false
	end
	return true
end

function TextBox:onMouseDrag( event )
	if self.isPressed and self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
		self.isPressed = true
		self.selectionPosition = self:viewToCharCoords( event.x - self.leftMargin + self.scroll )
	end
	return true
end

function TextBox:onKeyDown( event )
	if self.isFocused then
		local keyCode = event.keyCode
		local text = self.text

		if keyCode == keys.backspace then
			if self.selectionPosition then
				self:write ""
			elseif self.cursorPosition > 1 then
				self.text = text:sub( 1, self.cursorPosition - 2 ) .. text:sub( self.cursorPosition )
				self.cursorPosition = self.cursorPosition - 1
			end
		elseif keyCode == keys.left then
			local selectionPosition = self.selectionPosition
			local cursorPosition = self.cursorPosition

			if selectionPosition then
				self.cursorPosition = math.min( cursorPosition, selectionPosition )
				self.selectionPosition = false
			else
				self.cursorPosition = cursorPosition - 1
			end
		elseif keyCode == keys.right then
			local selectionPosition = self.selectionPosition
			local cursorPosition = self.cursorPosition

			if selectionPosition then
				self.cursorPosition = math.max( cursorPosition, selectionPosition )
				self.selectionPosition = false
			else
				self.cursorPosition = cursorPosition + 1
			end
		elseif keyCode == keys["end"] then

		elseif keyCode == keys.home then

		elseif keyCode == keys.delete then

		end
	end
end

function TextBox:onKeyUp( event )
	if self.isFocused then
		
	end
end

function TextBox:onCharacter( event )
	if self.isFocused then
		local text = self.text
		self:write( event.character )
	end
end

--[[
    @instance
    @desc Fired when the a keyboard shortcut is fired
    @param [Event] event -- the keyboard shortcut
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onKeyboardShortcut( event )
    if self.isFocused then
        if event:matchesKeys( { "ctrl", "left" } ) or event:matchesKeys( { "home" } ) then
        	self.selectionPosition = false
        	self.cursorPosition = 1
        elseif event:matchesKeys( { "ctrl", "right" } ) or event:matchesKeys( { "end" } ) then
        	self.selectionPosition = false
        	self.cursorPosition = #self.text + 1
        elseif event:matchesKeys( { "ctrl", "shift", "left" } ) then -- ehm, nope, select a word
        	self.selectionPosition = 1
        elseif event:matchesKeys( { "ctrl", "shift", "right" } ) then -- ehm, nope, select a word
        	self.selectionPosition = #self.text + 1
        elseif event:matchesKeys( { "shift", "left" } ) then
        	local selectionPosition = self.selectionPosition
        	if selectionPosition then
	        	self.selectionPosition = math.max( 1, selectionPosition - 1 )
	    	else
	    		self.selectionPosition = math.max( 1, self.cursorPosition - 1 )
	    	end
        elseif event:matchesKeys( { "shift", "right" } ) then
        	local selectionPosition = self.selectionPosition
        	if selectionPosition then
	        	self.selectionPosition = math.min( #self.text + 1, selectionPosition + 1 )
	    	else
	    		self.selectionPosition = math.min( #self.text + 1, self.cursorPosition + 1 )
	    	end
        elseif event:matchesKeys( { "ctrl", "a" } ) then
        	self.cursorPosition = 1
        	self.selectionPosition = #self.text + 1
        elseif event:matchesKeys( { "ctrl", "backspace" } ) then
        	local cursorPosition = self.cursorPosition
        	self.cursorPosition = 1
        	self.selectionPosition = false
        	self.text = self.text:sub( cursorPosition )
        elseif event:matchesKeys( { "ctrl", "home" } ) then
        	self.cursorPosition = 1
        	self.selectionPosition = #self.text + 1
        elseif event:matchesKeys( { "ctrl", "end" } ) then
        	self.cursorPosition = 1
        	self.selectionPosition = #self.text + 1
        else
            return false
        end
        return true
    end
end
