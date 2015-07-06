
class "TextBox" extends "View" {

    height = 15; -- the default height
    width = 120;
    text = false;

    font = false;

    backgroundObject = false;
    textObject = false;

    leftMargin = 0;
    rightMargin = 0;
    textInput = false;
    isFocused = false;
    isPressed = false;

}

--[[
    @constructor
    @desc Creates a text box view and connects the event handlers
]]
function TextBox:init( ... )
    self.super:init( ... )
    
    self.textInput = TextInput( self, self.text )

    self:event( Event.KEY_UP, self.onKeyboardEvent )
    self:event( Event.KEY_DOWN, self.onKeyboardEvent )
    self:event( Event.CHARACTER, self.onKeyboardEvent )

    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self:event( Event.MOUSE_UP, self.onMouseUp )
    self:event( Event.FOCUS_CHANGED, self.onFocusChanged )
    self:event( Event.TEXT_CHANGED, self.onTextChanged )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )

    if self.onMouseUp then self:event( Event.MOUSE_UP, self.onMouseUp ) end
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function TextBox:initCanvas()
    self.super:initCanvas()
    local width, height, theme = self.width, self.height, self.theme
    local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, width, height, theme.fillColour, theme.outlineColour, cornerRadius ) )
    local textObject = self.canvas:insert( Text( self.leftMargin, 5, self.width, 10, self.text ) )

    theme:connect( backgroundObject, "fillColour" )
    theme:connect( backgroundObject, "outlineColour" )
    theme:connect( backgroundObject, "radius", "cornerRadius" )
    theme:connect( textObject, "textColour" )
    theme:connect( self, "leftMargin" )
    theme:connect( self, "rightMargin" )

    self.backgroundObject = backgroundObject
    self.textObject = textObject

    if not self.font then
        self.font = Font.systemFont
    end
end

function TextBox:setHeight( height )
    self.super:setHeight( height )
    if self.hasInit then
        self.backgroundObject.height = height
    end
end

function TextBox:setWidth( width )
    self.super:setWidth( width )
    if self.hasInit then
        self.backgroundObject.width = width
        local textObject = self.textObject
        textObject.x = self.leftMargin + 1
        textObject.width = width - self.leftMargin - self.rightMargin
    end
end

--[[
    @instance
    @desc Set the text of the text box.
    @param [string] text -- the text of the text box
    @param [bool] isEvent -- whether the text was set by it's text input (to prevent recursion)
]]
function TextBox:setText( text, isEvent )
    self.text = text
    if self.hasInit then
        self.textObject.text = text
        if not isEvent then
            local textInput = self.textInput
            if textInput then
                textInput.text = text
            end
        end
    end
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
        self.textObject.font = font
    end
end

function TextBox:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or ( self.isFocused and "focused" or "default" ) ) or "disabled"
end

function TextBox:setIsPressed( isPressed )
    self.isPressed = isPressed
    if self.hasInit then
        self:updateThemeStyle()
    end
end

function TextBox:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    if self.hasInit then
        self:updateThemeStyle()
    end
end

--[[
    @instance
    @desc Sets whether the text box is focused. DO NOT CALL/SET THIS DIRECTLY! Use :focus and :unfocus instead.
    @param [bool] isFocused -- whether the text box is focused
]]
function TextBox:setIsFocused( isFocused )
    local wasFocused = self.isFocused
    if wasFocused ~= isFocused then
        self.isFocused = isFocused
        self.textInput.isEnabled = isFocused
        if self.hasInit then
            self:updateThemeStyle()
        end
    end
end

--[[
    @instance
    @desc Focuses the text box, making it the current view that text is entered in to
]]
function TextBox:focus()
    self.application.focus = self
end

--[[
    @instance
    @desc Unfocuses the text box, making no other view focused
]]
function TextBox:unfocus()
    self.application:clearFocus()
end

--[[
    @instance
    @desc Fired when the focused view changes
    @param [FocusChangedInterfaceEvent] event -- the focus changed event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onFocusChanged( event )
    self.isFocused = ( self == event.newFocus )
end

--[[
    @instance
    @desc Fired when the text input's text changes
    @param [TextChangedInterfaceEvent] event -- the text changed event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onTextChanged( event )
    self:setText( event.text, true )
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
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
    @return [bool] preventPropagation -- prevent anyone else using the event
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
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onMouseDown( event )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end

--[[
    @instance
    @desc Calked when any keyboard event is fired. Simply passes it to the text input.
    @param [Event] event -- the keyboard event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onKeyboardEvent( event )
    return self.textInput.event:handleEvent( event )
end
