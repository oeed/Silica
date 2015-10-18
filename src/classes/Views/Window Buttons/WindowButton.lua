
class "WindowButton" extends "View" {
	width = 9;
	height = 7;
    isPressed = false;
    backgroundObject = false;
    symbolObject = false;
    window = false;
}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function WindowButton:initialise( ... )
    self.super:initialise( ... )
    
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
    if self.onMouseUp then self:event( Event.MOUSE_UP, self.onMouseUp ) end
end

function WindowButton:initialiseCanvas()
	self.super:initialiseCanvas()

    local backgroundObject = self.canvas:insert( Circle( 3, 2, 5, 5 ) )
    self.theme:connect( backgroundObject, "fillColour" )
    -- local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width, self.height ) )

    self.theme:connect( backgroundObject, "outlineColour" )
    -- self.theme:connect( backgroundObject, "topLeftRadius", "cornerRadius" )



    self.backgroundObject = backgroundObject
end

function WindowButton:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function WindowButton:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function WindowButton:setIsPressed( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function WindowButton:onGlobalMouseUp( event )
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
    @param [MouseDownEvent] event -- the mouse down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function WindowButton:onMouseDown( event )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end
