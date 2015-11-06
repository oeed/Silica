
class "Button" extends "View" {

    height = 16; -- the default height
    width = 36;
    text = false;

    isPressed = false;
    isFocused = false;
    isAutosizing = true;
    font = false;

    shadowObject = false;
    backgroundObject = false;
    isFocusDismissable = false;
    textObject = false;

    needsAutosize = false;

    leftMargin = 0;
    rightMargin = 0;
}

-- action Button.buttonOne function( event )
-- end

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function Button:initialise( ... )
    self.super:initialise( ... )

    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self:event( Event.KEY_DOWN, self.onKeyDown )
    self:event( Event.KEY_UP, self.onKeyUp )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Button:initialiseCanvas()
    self.super:initialiseCanvas()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas
    local shadowObject = canvas:insert( RoundedRectangle( 2, 2, width - 1, height - 1, theme.shadowColour ) )
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

function Button:setText( text )
    self.text = text
    local textObject = self.textObject
    if textObject then
        textObject.text = text
    end
    self.needsAutosize = true
end

--[[
    @instance
    @desc Set the margin on either side of the text
    @param [number] margin -- the space around the text
]]
function Button:setMargin( margin )
    self.leftMargin = margin
    self.rightMargin = margin
end

--[[
    @instance
    @desc Set the margin on the left side of the text
    @param [number] margin -- the space around the left side of the text
]]
function Button:setLeftMargin( leftMargin )
    self.leftMargin = leftMargin
    self.needsAutosize = true
end

--[[
    @instance
    @desc Set the margin on the left side of the text
    @param [number] margin -- the space around the left side of the text
]]
function Button:setRightMargin( rightMargin )
    self.rightMargin = rightMargin
    self.needsAutosize = true
end

function Button:update( deltaTime )
    self.super:update( deltaTime )
    if self.needsAutosize then
        self:autosize()
    end
end

function Button:setFont( font )
    self.font = font
    local textObject = self.textObject
    if textObject then
        textObject.font = font
        self.needsAutosize = true
    end
end

function Button:setNeedsAutosize( needsAutosize )
    self.needsAutosize = needsAutosize
end

--[[
    @instance
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

function Button:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function Button:setIsPressed( isPressed )
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

function Button:setIsFocused( isFocused )
    self.isFocused = isFocused
    self:updateThemeStyle()
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Button:onGlobalMouseUp( event )
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
    @instance
    @desc Fired when the mouse is pushed anywhere on screen. Adds the pressed appearance.
    @param [MouseDownEvent] event -- the mouse down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Button:onMouseDown( event )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end

--[[
    @instance
    @desc Fired when a key is pressed down. Presses the button down if it isin focus and it was the enter key.
    @param [KeyDownEvent] event -- the key down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Button:onKeyDown( event )
    if self.isEnabled and self.isFocused and event.keyCode == keys.enter then
        self.isPressed = true
        return true
    end
end

--[[
    @instance
    @desc Fired when a key is pressed released. Fires the button action if the button is pressed, in focus and it was the enter key.
    @param [KeyUpEvent] event -- the key down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Button:onKeyUp( event )
    if self.isEnabled and self.isPressed and self.isFocused and event.keyCode == keys.enter then
        self.isPressed = false
    self.event:handleEvent( ActionInterfaceEvent( self ) )
        return true
    end
end
