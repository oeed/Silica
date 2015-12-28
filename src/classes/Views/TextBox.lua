
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

local CURSOR_ANIMATION_SPEED = 0.4
local CURSOR_ANIMATION_EASING = Animation.easings.OUT_QUART
local SCROLL_SPEED = 4

local sub = string.sub -- move to top
local concat = table.concat
local floor = math.floor

local SELECTION_DIRECTIONS = {
		BOTH = 0;
		LEFT = -1;
		RIGHT = 0;
	}

class "TextBox" extends "View" {

	height = Number( 15 );
	width = Number( 120 );
	text = String( "" );
	placeholder = String.allowsNil;

	cursorFlashCounter = 0;
	cursorColour = Graphics.colours( Graphics.colours.BLACK );

	cursorX = Number( 0 );
	selectionX = Number.allowsNil;
	selectionWidth = Number( 0 );
	selectionVisible = Boolean( false );

	isFocused = Boolean( false );
	isPressed = Boolean( false );
	isMasked = Boolean( false ); -- whether bullets are shown instead of characters (for passwords)

	scroll = Number( 0 );
	maxScroll = Number( 0 );
	cursorPosition = 1;
	maximumLength = false;
	selectionPosition = Number.allowsNil;

	selectionDirections = Enum( Number, SELECTION_DIRECTIONS );

}

--[[
	@constructor
	@desc Creates a text box view and connects the event handlers
]]
function TextBox:initialise( ... )
	self:super( ... )
	self:event( KeyUpEvent, self.onKeyUp )
	self:event( KeyDownEvent, self.onKeyDown )
	self:event( CharacterEvent, self.onCharacter )
	self:event( MouseDownEvent, self.onMouseDown )
	self:event( MouseUpEvent, self.onMouseUp )
	self:event( MouseDragEvent, self.onMouseDrag )
	self:event( MouseScrollEvent, self.onMouseScroll )
    self:event( KeyboardShortcutEvent, self.onKeyboardShortcut )
    self:event( MouseDoubleClickEvent, self.onMouseDoubleClick )
	self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
end

function TextBox:onDraw()
    local width, height, theme, canvas, isFocused = self.width, self.height, self.theme, self.canvas, self.isFocused
    local font, text = theme:value( "font" ), ( self.isMasked and string.rep( string.char( 149 ), #self.text ) or self.text )

    local roundedRectangle = RoundedRectangleMask( 1, 1, width, height, theme:value( "cornerRadius" ) )
    local fillColour = theme:value( "fillColour" )
    canvas:fill( fillColour, roundedRectangle )

    local leftMargin, rightMargin, topMargin, bottomMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" )

	if #text == 0 then
		local placeholder = self.placeholder
	    if placeholder then
	    	canvas:fill( theme:value( "placeholderColour" ),  roundedRectangle:intersect( TextMask( leftMargin + 1, topMargin + 1, width - leftMargin - rightMargin, height - topMargin - bottomMargin, self.placeholder, font ) ) )
		end
	end

    local scroll = self.scroll
    local outlineThickness = theme:value( "outlineThickness" )
    if isFocused then
    	local fontHeight = font.height
		local contentMask = RectangleMask( leftMargin - 1, 1 + outlineThickness, width - leftMargin - rightMargin + 4, height - 2 * outlineThickness )
    	if self.selectionVisible then
    		local selectionWidth = self.selectionWidth
    		if selectionWidth > 0 then
	    		local selectionLeftMargin, selectionRightMargin, selectionTopMargin, selectionBottomMargin = theme:value( "selectionLeftMargin" ), theme:value( "selectionRightMargin" ), theme:value( "selectionTopMargin" ), theme:value( "selectionBottomMargin" )
	    		local selectionMask = RoundedRectangleMask( leftMargin + 1 + self.selectionX - scroll - selectionLeftMargin, math.floor( fontHeight / 2 ) - selectionTopMargin, selectionWidth + selectionLeftMargin + selectionRightMargin, fontHeight + selectionTopMargin + selectionBottomMargin, theme:value( "selectionRadius" ) )
	    		canvas:fill( theme:value( "selectionColour" ), selectionMask:intersect( contentMask ) )
	    	end
	    else
	    	local cursorPosition = self.cursorPosition
	    	local cursorColour = self.cursorColour
	    	if cursorColour ~= fillColour then
		    	local cursorMask = RectangleMask( leftMargin + 1 + self.cursorX - scroll, math.floor( fontHeight / 2 ), 1, fontHeight + 1 )
	    		canvas:fill( cursorColour, cursorMask:intersect( contentMask ) )
	    	end
    	end
    end

    local textMask = roundedRectangle:intersect( TextMask( leftMargin + 1 - scroll, topMargin + 1, font:getWidth( text ), height - topMargin - bottomMargin, text, font ) )
    canvas:fill( theme:value( "textColour" ), textMask  )
    canvas:fill( theme:value( "fadeOneColour" ), OutlineMask( leftMargin, topMargin, width - leftMargin - rightMargin + 2, height - topMargin - bottomMargin + 2 * outlineThickness ):intersect( textMask )  )
    canvas:fill( theme:value( "fadeTwoColour" ), OutlineMask( leftMargin - 1, topMargin - 1, width - leftMargin - rightMargin + 4, height - topMargin - bottomMargin + 4 * outlineThickness ):intersect( textMask )  )
    canvas:fill( theme:value( "fillColour" ), OutlineMask( 1 + outlineThickness, 1 + outlineThickness, width - 2 * outlineThickness, height - 2 * outlineThickness, leftMargin - 2 - outlineThickness, topMargin - 2 - outlineThickness, rightMargin - 2 - outlineThickness, bottomMargin - 2 - outlineThickness ):intersect( textMask ) )
    canvas:outline( theme:value( "outlineColour" ), roundedRectangle, outlineThickness )
end

function TextBox:update( deltaTime )
	self:super( deltaTime )

	if self.isFocused then
		local cursorFlashCounter = self.cursorFlashCounter
		local visible = cursorFlashCounter % 2 < 1
		local rem = cursorFlashCounter % 1
		if rem > .85 then
			if visible then
				self.cursorColour = ( rem > .95 and Graphics.colours.LIGHT_GREY ) or Graphics.colours.GREY
			else
				self.cursorColour = ( rem > .95 and Graphics.colours.GREY ) or Graphics.colours.LIGHT_GREY
				visible = true
			end
		elseif not visible then
			self.cursorColour = Graphics.colours.WHITE
		else
			self.cursorColour = Graphics.colours.BLACK
		end
		self.cursorFlashCounter = cursorFlashCounter + deltaTime * 2
	end
end

function TextBox.cursorColour:set( cursorColour )
    if self.cursorColour ~= cursorColour then
    	self.cursorColour = cursorColour
    	self.needsDraw = true
    end
end

--[[
	@desc Converts the coordinates relative to the text box to the character position
	@param [number] x -- the x coordinate
	@return [number] characterPosition -- the charcter position
]]
function TextBox:viewToCharCoords( x )
	if x <= 0 then
		return 1
	end
	local theme = self.theme
	x = x - theme:value( "leftMargin" ) + self.scroll
	local font = theme:value( "font" )
	local getWidth = font.getWidth
	local text = self.isMasked and string.rep( string.char( 149 ), #self.text ) or self.text
	for i = 1, #text do
		local characterWidth = getWidth( font, text:sub( i, i ), true )
		if x <= characterWidth / 2 then
			return i
		end
		x = x - characterWidth
	end
	return #text + 1
end

function TextBox:charToViewCoords( char )
	local text = self.isMasked and string.rep( string.char( 149 ), #self.text ) or self.text
	return self.theme:value( "font" ):getWidth( text:sub( 1, char - 1 ) ) + 1
end

--[[
	@desc Callback to check whether a character entered by the user is valid, intended to be overridden by sub-classes
	@param [string] character
	@return [boolean] isValid
]]
function TextBox:isValidChar( character )
	return true
end

function TextBox.cursorPosition:set( cursorPosition )
	cursorPosition = math.max( math.min( cursorPosition, #self.text + 1 ), 1 )
	self.cursorPosition = cursorPosition
	self.cursorFlashCounter = 0
	self:updateSelection()
	self:updateCursorPosition()
end

function TextBox:updateCursorPosition()
	local value = math.max( self:charToViewCoords( self.selectionPosition or self.cursorPosition ) - 1, 0 )
	self:animate( "cursorX", value, CURSOR_ANIMATION_SPEED, nil, CURSOR_ANIMATION_EASING )
end

function TextBox:updateSelection()
	local selectionPosition = self.selectionPosition
	local isVisible = self.selectionVisible
	local cursorX = math.max( self:charToViewCoords( self.cursorPosition ) - 1, 0 )
	local selectionX = selectionPosition and math.max( self:charToViewCoords( selectionPosition ) - 1, 0 )
	local _x = self.selectionX
	if not isVisible and selectionPosition then
		if selectionX and not _x then self.selectionX = selectionX end
		self.selectionVisible = true
	end

	local x, width, f
	if not selectionPosition or cursorX == selectionX then
		local _width = self.selectionWidth
		if not selectionPosition and not _x then
			self.selectionX = cursorX
			self.selectionWidth = 0
			return
		end
		x = cursorX
		width = 0
		f = function() self.selectionVisible = false end
	else
		x = math.min( cursorX, selectionX )
		width = math.max( cursorX, selectionX ) - x
	end
	self:animate( "selectionX", x, CURSOR_ANIMATION_SPEED, nil, CURSOR_ANIMATION_EASING )
	self:animate( "selectionWidth", width, CURSOR_ANIMATION_SPEED, f, CURSOR_ANIMATION_EASING )
end

--[[
	@desc Updates the maximum scroll value to account for the change in of the text or textbox
]]
function TextBox:updateMaxScroll()
	local theme = self.theme
	self.maxScroll = theme:value( "font" ):getWidth( self.text ) - ( self.width - theme:value( "leftMargin" ) - theme:value( "rightMargin" ) )
end

function TextBox.scroll:set( scroll )
	self.scroll = math.max( math.min( scroll, self.maxScroll ), 0 )
	self.needsDraw = true
end

function TextBox.maxScroll:set( maxScroll )
	self.maxScroll = math.max( maxScroll, 0 )
	self.scroll = self.scroll -- this will check that the scroll value is okay
end

function TextBox.cursorX:set( cursorX )
	self.cursorX = cursorX

	-- if the cursor is extending past the visible bounds adjust scroll to keep it visible
	local width, scroll = self.width, self.scroll
    local relativeX = cursorX - scroll
    if relativeX < 0 then
    	-- the cursor is to the left of the screen
    	self.scroll = scroll + relativeX
    else
    	local theme = self.theme
    	local leftMargin, rightMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" )
    	local rightOverflow = relativeX - width + leftMargin + rightMargin + 1
    	if rightOverflow > 0 then
	    	self.scroll = scroll + rightOverflow
	    else
			self.needsDraw = true -- we can put this here because setting scroll does it, so it's not always needed
	    end
    end
end

function TextBox.selectionX:set( selectionX )
	self.selectionX = selectionX
	self.needsDraw = true
end

function TextBox.selectionWidth:set( selectionWidth )
	self.selectionWidth = selectionWidth
	self.needsDraw = true
end

function TextBox.selectionPosition:set( selectionPosition )
	self.selectionPosition = selectionPosition
	self.cursorFlashCounter = 0
	self:updateSelection()
	self.needsDraw = true
end

--[[
	@desc Insert text into the text box at the current cursor position
	@param [string] character
	@return [boolean] isValid
]]
function TextBox:write( text )
	local t = {}
	local valid = self.isValidChar
	local s = ""
	for i = 1, #text do
		local char = sub( text, 1, 1 )
		if valid( self, char ) then
			s = s .. char
		end
	end
	local text = self.text
	local cursorPosition, selectionPosition = self.cursorPosition, self.selectionPosition
	if selectionPosition then
		-- selectionPosition = selectionPosition - 1
		local left, right = math.min( cursorPosition, selectionPosition ), math.max( cursorPosition, selectionPosition )
		self.text = text:sub( 1, left - 1 ) .. s .. text:sub( right )
		self.selectionPosition = nil
		self.cursorPosition =  math.min( cursorPosition, selectionPosition ) + #s
	else
		self.text = text:sub( 1, cursorPosition - 1 ) .. s .. text:sub( cursorPosition )
		self.cursorPosition =  cursorPosition + #s
	end
end

--[[
	@desc Set the text of the text box.
	@param [string] text -- the text of the text box
]]
function TextBox.text:set( text )
	self.text = text
	self:updateMaxScroll()
	self.needsDraw = true
end

function TextBox.placeholder:set( placeholder )
	self.placeholder = placeholder
	self.needsDraw = true
end

function TextBox.isMasked:set( isMasked )
	self.isMasked = isMasked
	self.needsDraw = true
end

function TextBox:updateThemeStyle()
	self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or ( self.isFocused and "focused" or "default" ) ) or "disabled"
end

function TextBox.isPressed:set( isPressed )
	self.isPressed = isPressed
	self:updateThemeStyle()
end

function TextBox.isEnabled:set( isEnabled )
	self.isEnabled = isEnabled
	if not isEnabled then
		self:unfocus( TextBox )
	end
	self:updateThemeStyle()
end

function TextBox.isFocused:set( isFocused )
	self.isFocused = isFocused
	self.cursorPosition = self.cursorPosition or 1
	self:updateThemeStyle()
end

--[[
	@desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
	@param [Event] event -- the mouse up event
	@return [boolean] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onGlobalMouseUp( MouseUpEvent event, Event.phases phase )
	if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
		self.isPressed = false
		if self.isEnabled and self:hitTestEvent( event ) then
			return self.event:handleEvent( event )
		end
	end
end

--[[
	@desc Fired when the mouse is released. Focuses on the text box
	@param [MouseDownEvent] event -- the mouse down event
	@return [boolean] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onMouseUp( MouseUpEvent event, Event.phases phase )
	if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
		self:focus( TextBox )
	end
	return true
end

function TextBox:onMouseDoubleClick( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
    	local left, right = self:wordPosition( self:viewToCharCoords( event.x ), SELECTION_DIRECTIONS.BOTH )
    	if left ~= right then
	    	self.selectionPosition = right
	    	self.cursorPosition = left
	    end
    end
    return true
end

--[[
	@desc Fired when the mouse is pushed anywhere on screen. Adds the pressed appearance.
	@param [MouseDownEvent] event -- the mouse down event
	@return [boolean] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onMouseDown( MouseDownEvent event, Event.phases phase )
	if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
		self.isPressed = true
		if self.application.keyboardShortcutManager:isOnlyKeyDown( "shift" ) then
			self.selectionPosition = self:viewToCharCoords( event.x )
		else
			self.selectionPosition = nil
			self.cursorPosition = self:viewToCharCoords( event.x )
		end
	end
	return true
end

function TextBox:onMouseDrag( Event event, Event.phases phase )
	if self.isPressed and self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
		self.isPressed = true
		self.selectionPosition = self:viewToCharCoords( event.x )
	end
	return true
end

function TextBox:onMouseScroll( MouseScrollEvent event, Event.phases phase )
	if self.isEnabled then
		self.scroll = self.scroll + event.direction * SCROLL_SPEED
	end
	return true
end

function TextBox:onKeyDown( KeyDownEvent event, Event.phases phase )
	if self.isFocused then
		local keyCode = event.keyCode
		local text = self.text
		local cursorPosition = self.cursorPosition
		local selectionPosition = self.selectionPosition

		if keyCode == keys.backspace then
			if selectionPosition then
				self:write ""
			elseif cursorPosition > 1 then
				self.text = text:sub( 1, cursorPosition - 2 ) .. text:sub( cursorPosition )
				self.cursorPosition = cursorPosition - 1
			end
		elseif keyCode == keys.left then
			if selectionPosition then
				self.selectionPosition = nil
				self.cursorPosition = math.min( cursorPosition, selectionPosition )
			else
				self.cursorPosition = cursorPosition - 1
			end
		elseif keyCode == keys.right then
			if selectionPosition then
				self.selectionPosition = nil
				self.cursorPosition = math.max( cursorPosition, selectionPosition )
			else
				self.cursorPosition = cursorPosition + 1
			end
		elseif keyCode == keys.delete then
			if selectionPosition then
				self:write ""
			elseif cursorPosition < #text + 1 then
				self.text = text:sub( 1, cursorPosition - 1 ) .. text:sub( cursorPosition + 1 )
			end
		end
	end
end

function TextBox:onKeyUp( KeyUpEvent event, Event.phases phase )
	if self.isFocused then
		
	end
end

function TextBox:onCharacter( CharacterEvent event, Event.phases phase )
	if self.isFocused then
		self:write( event.character )
	end
end

-- 										TODO: Number should be TextBox.selectionDirections
function TextBox:wordPosition( Number fromPosition, Number direction, Boolean( true ) allowMiddlePunctuation )
	local text = self.text
	local left, right
	local function go( from, to, dir )
		local offset = 0
		local hasFound = false
		for i = from, to, dir do
			local char = text:sub( i - 1, i - 1 )
			local isPunctuation = char:match( "%p" )
			local isSpace = char:match( "[%s%c]" )
			if hasFound and ( isSpace or ( not allowMiddlePunctuation and isPunctuation ) ) then
				return i - offset
			elseif allowMiddlePunctuation and isPunctuation then
				offset = dir
			elseif not isSpace and not isPunctuation then
				hasFound = true
				offset = 0
			end
		end
		return to
	end
	if direction == SELECTION_DIRECTIONS.LEFT or direction == SELECTION_DIRECTIONS.BOTH then
		left = go( fromPosition, 1, -1 )
	end
	if direction == SELECTION_DIRECTIONS.RIGHT or direction == SELECTION_DIRECTIONS.BOTH then
		right = go( fromPosition + 1, #text + 2, 1 ) - 1
	end
	return left, right
end

--[[
    @desc Fired when the a keyboard shortcut is fired
    @param [Event] event -- the keyboard shortcut
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onKeyboardShortcut( Event event, Event.phases phase )
    if self.isFocused then
        if event:matchesKeys( { "ctrl", "left" } ) or event:matchesKeys( { "home" } ) then
        	self.selectionPosition = nil
        	self.cursorPosition = 1
        elseif event:matchesKeys( { "ctrl", "right" } ) or event:matchesKeys( { "end" } ) then
        	self.selectionPosition = nil
        	self.cursorPosition = #self.text + 1
        elseif event:matchesKeys( { "ctrl", "shift", "left" } ) then
        	self.selectionPosition = 1
        elseif event:matchesKeys( { "ctrl", "shift", "right" } ) then
        	self.selectionPosition = #self.text + 1
        elseif event:matchesKeys( { "alt", "left" } ) then
        	self.cursorPosition = self:wordPosition( self.cursorPosition, SELECTION_DIRECTIONS.LEFT )
        elseif event:matchesKeys( { "alt", "right" } ) then
        	local _, right = self:wordPosition( self.cursorPosition, SELECTION_DIRECTIONS.RIGHT )
        	self.cursorPosition = right
        elseif event:matchesKeys( { "alt", "shift", "left" } ) then
        	self.selectionPosition = self:wordPosition( math.min( self.cursorPosition, self.selectionPosition or math.huge ), SELECTION_DIRECTIONS.LEFT )
        elseif event:matchesKeys( { "alt", "shift", "right" } ) then
        	local _, right = self:wordPosition( math.max( self.cursorPosition, self.selectionPosition or 0), SELECTION_DIRECTIONS.RIGHT )
        	self.selectionPosition = right
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
        	self.selectionPosition = nil
        	self.cursorPosition = 1
        	self.text = self.text:sub( cursorPosition )
        else
            return false
        end
        return true
    end
end
