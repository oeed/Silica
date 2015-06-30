
class "Button" extends "View" {

    height = 15; -- the default height
    width = 36;
    text = nil;

    isPressed = false;
    isAutosizing = true;
    font = nil;

    shadowObject = nil;
    backgroundObject = nil;
    textObject = nil;
}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function Button:init( ... )
    self.super:init( ... )

    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
    if self.onMouseUp then self:event( Event.MOUSE_UP, self.onMouseUp ) end
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Button:initCanvas()
    self.super:initCanvas()
    local shadowObject = self.canvas:insert( RoundedRectangle( 2, 2, self.width - 1, self.height - 1, self.theme.shadowColour ) )
    local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width - 1, self.height - 1, self.theme.fillColour, self.theme.outlineColour, cornerRadius ) )
    local textObject = self.canvas:insert( Text( 1, 4, 30, 10, self.text ) )

    self.theme:connect( backgroundObject, 'fillColour' )
    self.theme:connect( backgroundObject, 'outlineColour' )
    self.theme:connect( backgroundObject, 'radius', 'cornerRadius' )
    self.theme:connect( shadowObject, 'shadowColour' )
    self.theme:connect( shadowObject, 'radius', 'cornerRadius' )
    self.theme:connect( textObject, 'textColour' )
    self.theme:connect( self, 'cornerRadius', 'cornerRadius' )

    self.backgroundObject = backgroundObject
    self.shadowObject = shadowObject
    self.textObject = textObject

    if not self.font then
        self.font = Font.named( "Auckland" )
    elseif self.isAutosizing then
        self:autosize()
    end
end

function Button:setHeight( height )
    self.super:setHeight( height )
    if self.hasInit then
        self.backgroundObject.height = height - 1
        self.shadowObject.height = height - 1
    end
end

function Button:setWidth( width )
    self.super:setWidth( width )
    if self.hasInit then
        self.backgroundObject.width = width - 1
        self.shadowObject.width = width - 1
        local margin = math.max( self.cornerRadius - 1, 3 )
        self.textObject.width = self.width - 2 * margin + 2
    end
end

function Button:setText( text )
    self.text = text
    if self.hasInit then
        self.textObject.text = text
        if self.isAutosizing then
            self:autosize()
        end
    end
end

function Button:setCornerRadius( cornerRadius )
    self.cornerRadius = cornerRadius
    local textObject = self.textObject
    if textObject then
        local margin = math.max( cornerRadius - 1, 3 )
        textObject.x = margin
        if self.isAutosizing then
            self:autosize()
        else
            textObject.width = self.width - 2 * margin + 2
        end
    end
end

function Button:setFont( font )
    self.font = font
    local textObject = self.textObject
    if textObject then
        self.textObject.font = font
        if self.isAutosizing then
            self:autosize()
        end
    end
end

--[[
    @instance
    @desc Automatically resizes the button, regardless of isAutosizing value, to fit the text
    @param [boolean] isHorizontal -- default is true. whether the button should be resized horizontally
    @param [boolean] isVertical -- default is true. whether the button should be resized vertically
]]
function Button:autosize( isHorizontal, isVertical )
    isHorizontal = ( isHorizontal == nil ) and true or isHorizontal
    isVertical = ( isVertical == nil ) and true or isVertical
    local font, text, textObject = self.font, self.text, self.textObject

    if font and text then
        if isHorizontal then
            local fontWidth = font:getWidth( text )
            local margin = math.max( self.cornerRadius - 1, 3 )
            self.width = fontWidth + 2 * margin - 2
        end

        if isVertical then
            local fontHeight = font.height
            self.height = fontHeight + 7
        end
    end
end

function Button:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function Button:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    if self.hasInit then
        self:updateThemeStyle()
    end
end

function Button:setIsPressed( isPressed )
    self.isPressed = isPressed
    if self.hasInit then
        self:updateThemeStyle()
        local backgroundObject = self.backgroundObject
        backgroundObject.x = isPressed and 2 or 1
        backgroundObject.y = isPressed and 2 or 1
        local textObject = self.textObject
        textObject.x = isPressed and 7 or 6
        textObject.y = isPressed and 5 or 4
    end
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Button:onGlobalMouseUp( event )
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
function Button:onMouseDown( event )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end
