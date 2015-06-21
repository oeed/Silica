
class "MenuItem" extends "View" {
	text = nil;

	height = 9;
	width = 40;

    isPressed = false;
    isEnabled = true;
	isCanvasHitTested = false;

	textColour = Graphics.colours.BLACK;
    fillColour = Graphics.colours.TRANSPARENT;

	pressedTextColour = Graphics.colours.WHITE;
    pressedFillColour = Graphics.colours.BLUE;

    disabledTextColour = Graphics.colours.LIGHT_GREY;
    disabledFillColour = Graphics.colours.TRANSPARENT;

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
    self.backgroundObject = self.canvas:insert( Rectangle( 1, 1, self.width, self.height, self.fillColour ) )
end

--[[
    @instance
    @desc Update the canvas appearance.
]]
function MenuItem:updateCanvas()
    if self.backgroundObject then
	    self.backgroundObject.fillColour = self.isEnabled and ( self.isPressed and self.pressedFillColour or self.fillColour ) or self.disabledFillColour
    end
end

function MenuItem:setWidth( width )
    self.super:setWidth( width )
    if self.backgroundObject then
        self.backgroundObject.width = width
    end
end

function MenuItem:setHeight( height )
    self.super:setHeight( height )
    if self.backgroundObject then
        self.backgroundObject.height = height
    end
end

--[[
    @instance
    @desc Sets whether the menu item is pressed, changing the drawing state
]]
function MenuItem:setIsPressed( isPressed )
    self.isPressed = isPressed
    self:updateCanvas()
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
