
class "Button" extends "View" {

    height = Number( 16 ); -- the default height
    width = Number( 36 );
    text = String( "" );

    isPressed = Boolean( false );
    isFocused = Boolean( false );
    isAutosizing = Boolean( true );
    font = Font( Font.static.systemFont );

    isFocusDismissable = Boolean( true );

    needsAutosize = Boolean( true );
    margin = Number;
    leftMargin = 0;
    rightMargin = 0;
}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function Button:initialise( ... )
    self:super( ... )

    self:event( MouseDownEvent, self.onMouseDown )
    self:event( KeyDownEvent, self.onKeyDown )
    self:event( KeyUpEvent, self.onKeyUp )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
end

--[[
    @desc Sets up the canvas and it's graphics objects
]]
function Button:initialiseCanvas()
    self:super()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas
    local shadowObject = canvas:insert( RoundedRectangle( 2, 2, width - 1, height - 1, theme:value( "shadowColour" ) ) )
    local backgroundObject = canvas:insert( RoundedRectangle( 1, 1, width - 1, height - 1, theme.fillColour, theme.outlineColour, cornerRadius ) )
    local textObject = canvas:insert( Text( 1, 5, width, 10, self.text ) )

    theme:connect( backgroundObject, "fillColour" )
    theme:connect( backgroundObject, "outlineColour" )
    theme:connect( backgroundObject, "radius", "cornerRadius" )
    theme:connect( shadowObject, "fillColour", "shadowColour" )
    theme:connect( shadowObject, "radius", "cornerRadius" )
    theme:connect( textObject, "textColour" )
    theme:connect( self, "leftMargin" )
    theme:connect( self, "rightMargin" )

    self.backgroundObject = backgroundObject
    self.shadowObject = shadowObject
    self.textObject = textObject

    if not self.font then
        self.font = Font.systemFont
    end
end

function Button:updateHeight( height )
    self.backgroundObject.height = height - 1
    self.shadowObject.height = height - 1
    -- self.needsAutosize = true
end

function Button:updateWidth( width )
    self.backgroundObject.width = width - 1
    self.shadowObject.width = width - 1
    local textObject = self.textObject
    if textObject then
        local leftMargin, rightMargin = self.leftMargin, self.rightMargin
        textObject.x = self.isPressed and leftMargin + 2 or leftMargin + 1
        textObject.width = width - leftMargin - rightMargin
    end
end

function Button.text:set( text )
    self.text = text
    local textObject = self.textObject
    if textObject then
        textObject.text = text
    end
    self.needsAutosize = true
end

--[[
    @desc Set the margin on either side of the text
    @param [number] margin -- the space around the text
]]
function Button.margin:set( margin )
    self.leftMargin = margin
    self.rightMargin = margin
end

--[[
    @desc Set the margin on the left side of the text
    @param [number] margin -- the space around the left side of the text
]]
function Button.leftMargin:set( leftMargin )
    self.leftMargin = leftMargin
    self.needsAutosize = true
end

--[[
    @desc Set the margin on the left side of the text
    @param [number] margin -- the space around the left side of the text
]]
function Button.rightMargin:set( rightMargin )
    self.rightMargin = rightMargin
    self.needsAutosize = true
end

function Button:update( deltaTime )
    self:super( deltaTime )
    if self.needsAutosize then
        self:autosize()
    end
end

function Button.font:set( font )
    self.font = font
    local textObject = self.textObject
    if textObject then
        textObject.font = font
        self.needsAutosize = true
    end
end

function Button.needsAutosize:set( needsAutosize )
    self.needsAutosize = needsAutosize
end

--[[
    @desc Automatically resizes the button, regardless of isAutosizing value, to fit the text
]]
function Button:autosize()
    -- TODO: support self.isAutosizing
    local font, text = self.font, self.text

    if font and text then
        local fontWidth = font:getWidth( text )
        self.width = fontWidth + self.leftMargin + self.rightMargin + 1

        local fontHeight = font.height
        self.height = fontHeight + 8
    end
    self.needsAutosize = false
end

function Button:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or ( self.isFocused and "focused" or "default" ) ) or "disabled"
end

function Button.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function Button.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
    local backgroundObject = self.backgroundObject
    backgroundObject.x = isPressed and 2 or 1
    backgroundObject.y = isPressed and 2 or 1
    local textObject = self.textObject
    -- textObject.x = isPressed and self.leftMargin + 2 or self.leftMargin + 1
    if textObject then
        textObject.y = isPressed and 6 or 5
    end
end

function Button.isFocused:set( isFocused )
    self.isFocused = isFocused
    self:updateThemeStyle()
end

--[[
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Button:onGlobalMouseUp( Event event, Event.phases phase )
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = false
        if self.isEnabled and self:hitTestEvent( event ) then
            self.event:handleEvent( ActionInterfaceEvent( self ) )
            local result = self.event:handleEvent( event )
            return result == nil and true or result
        end
    end
end

--[[
    @desc Fired when the mouse is pushed anywhere on screen. Adds the pressed appearance.
    @param [MouseDownEvent] event -- the mouse down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Button:onMouseDown( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end

--[[
    @desc Fired when a key is pressed down. Presses the button down if it isin focus and it was the enter key.
    @param [KeyDownEvent] event -- the key down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Button:onKeyDown( Event event, Event.phases phase )
    if self.isEnabled and self.isFocused and event.keyCode == keys.enter then
        self.isPressed = true
        return true
    end
end

--[[
    @desc Fired when a key is pressed released. Fires the button action if the button is pressed, in focus and it was the enter key.
    @param [KeyUpEvent] event -- the key down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Button:onKeyUp( Event event, Event.phases phase )
    if self.isEnabled and self.isPressed and self.isFocused and event.keyCode == keys.enter then
        self.isPressed = false
    self.event:handleEvent( ActionInterfaceEvent( self ) )
        return true
    end
end
