
class "Button" extends "View" {

    height = 12; -- the default height
    width = 30;

    isPressed = false;

    shadowObject = nil;
    backgroundObject = nil;
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

    self.theme:connect( backgroundObject, 'fillColour' )
    self.theme:connect( backgroundObject, 'outlineColour' )
    self.theme:connect( backgroundObject, 'radius', 'cornerRadius' )
    self.theme:connect( shadowObject, 'shadowColour' )
    self.theme:connect( shadowObject, 'radius', 'cornerRadius' )

    self.backgroundObject = backgroundObject
    self.shadowObject = shadowObject
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
