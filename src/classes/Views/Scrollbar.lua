
class "Scrollbar" extends "View" {
	width = 7;
    isHorizontal = false;
	scrollerObject = nil;
	grabberObject = nil;
}

function Scrollbar:init( ... )
	self.super:init( ... )
    -- self:event( Event.MOUSE_SCROLL, self.onMouseScroll )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Scrollbar:initCanvas()
    self.super:initCanvas()

    self.theme:connect( self.canvas, 'fillColour' )

    local scrollerObject = self.canvas:insert( RoundedRectangle( 2, 3, self.width - 2, 30 ) )
    local grabberObject = self.canvas:insert( ScrollbarGrabber( 3, 3, self.width - 4, 30 ) )

    self.theme:connect( scrollerObject, 'fillColour', 'scrollerColour' )
    self.theme:connect( scrollerObject, 'outlineColour' )
    self.theme:connect( scrollerObject, 'radius', 'cornerRadius' )
    self.theme:connect( grabberObject, 'fillColour', 'grabberColour' )

    self.scrollerObject = scrollerObject
    self.grabberObject = grabberObject
end

function Scrollbar:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function Scrollbar:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    if self.hasInit then
        self:updateThemeStyle()
    end
end

function Scrollbar:setIsPressed( isPressed )
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
function Scrollbar:onGlobalMouseUp( event )
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
function Scrollbar:onMouseDown( event )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end