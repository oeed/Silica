
class "MenuItem" extends "View" {
	text = nil;

	height = 9;
	width = 40;

    isPressed = false;
    isEnabled = true;
	isCanvasHitTested = false;

    backgroundObject = nil;
}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function MenuItem:init( ... )
	self.super:init( ... )

    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
end

function MenuItem:initCanvas()
    local backgroundObject = self.canvas:insert( Rectangle( 1, 1, self.width, self.height, self.fillColour ) )
    self.theme:connect( backgroundObject, 'fillColour' )
    self.backgroundObject = backgroundObject
end

function MenuItem:setWidth( width )
    self.super:setWidth( width )
    self.backgroundObject.width = width
end

function MenuItem:setHeight( height )
    self.super:setHeight( height )
    self.backgroundObject.height = height
end

function MenuItem:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function MenuItem:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function MenuItem:setIsPressed( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function MenuItem:onGlobalMouseUp( event )
    if self.isPressed then
        self.isPressed = false
        if self.isEnabled and self:hitTestEvent( event ) then
            self.parent:close()
            return self.event:handleEvent( event )
        end
    end
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function MenuItem:onMouseDown( event )
    if self.isEnabled then
        self.isPressed = true
    end
    return true
end
