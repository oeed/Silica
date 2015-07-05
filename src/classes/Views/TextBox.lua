
class "TextBox" extends "View" {

    height = 15; -- the default height
    width = 120;
    text = nil;

    font = nil;

    backgroundObject = nil;
    textObject = nil;

    leftMargin = 0;
    rightMargin = 0;
}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function TextBox:init( ... )
    self.super:init( ... )

    self:event( Event.MOUSE_DOWN, self.onMouseDown )
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

    theme:connect( backgroundObject, 'fillColour' )
    theme:connect( backgroundObject, 'outlineColour' )
    theme:connect( backgroundObject, 'radius', 'cornerRadius' )
    theme:connect( textObject, 'textColour' )
    theme:connect( self, 'leftMargin' )
    theme:connect( self, 'rightMargin' )

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
        log(self.leftMargin)
        textObject.width = width - self.leftMargin - self.rightMargin
    end
end

function TextBox:setText( text )
    self.text = text
    if self.hasInit then
        self.textObject.text = text
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
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function TextBox:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    if self.hasInit then
        self:updateThemeStyle()
    end
end

function TextBox:setIsPressed( isPressed )
    self.isPressed = isPressed
    if self.hasInit then
        self:updateThemeStyle()
    end
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
    @desc Fired when the mouse is pushed anywhere on screen. Adds the pressed appearance.
    @param [Event] event -- the mouse down event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function TextBox:onMouseDown( event )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end
