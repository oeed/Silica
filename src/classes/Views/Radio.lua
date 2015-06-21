
class "Radio" extends "View" {

    width = 7;
    height = 7;

    isPressed = false;
    isEnabled = true;
    isChecked = false;
    cornerRadius = 4;

}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function Radio:init( ... )
	self.super:init( ... )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
end

function Radio:setHeight( height )
    self.super:setHeight( height )
    self:updateCanvas()
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Radio:initCanvas()
    self.backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width, self.height, self.fillColour, self.outlineColour, self.cornerRadius ) )
end

--[[
    @instance
    @desc Returns the current fill colour for the current style
    @return [Graphics.colours] colour -- the fill colour
]]
function Radio:getFillColour()
    return self:themeValue( "fillColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current outline colour for the current style
    @return [Graphics.colours] colour -- the outline colour
]]
function Radio:getOutlineColour()
    return self:themeValue( "outlineColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current corner radius for the current style
    @return [number] cornerRadius -- the corner radius
]]
function Radio:getCornerRadius()
    return self:themeValue( "cornerRadius", self.themeStyle )
end

--[[
    @instance
    @desc Update the canvas appearance.
]]
function Radio:updateCanvas()
    if self.backgroundObject then
        self.backgroundObject.radius = self.cornerRadius
        self.themeStyle = self.isEnabled and ( self.isPressed and "pressed" or (self.isChecked and "checked" or "default" ) ) or ( self.isChecked and "disabledChecked" or "disabled" )
        self.backgroundObject.fillColour = self.fillColour
        self.backgroundObject.outlineColour = self.outlineColour
    end
end

--[[
    @instance
    @desc Sets the checked state of the radio button. Sets all other sibling (in the same container) radios to false if being set to true
    @param [boolean] isChecked -- the new checked state
]]
function Radio:setIsChecked( isChecked )
    if isChecked then
        for i, sibling in ipairs( self:siblingsOfType( Radio ) ) do
            sibling.isChecked = false
        end
    end

    self.isChecked = isChecked
    self:updateCanvas()
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Radio:setIsPressed( isPressed )
    self.isPressed = isPressed
    self:updateCanvas()
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Radio:onGlobalMouseUp( event )
    if self.isPressed then
        self.isPressed = false
        if self:hitTestEvent( event ) then
            self.isChecked = true
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
function Radio:onMouseDown( event )
    if self.isEnabled then
        self.isPressed = true
    end
    return true
end

--[[
    @instance
    @desc Draws the checkbox to the canvas
]]
function Radio:draw()
    local isPressed = self.isPressed
    local isEnabled = self.isEnabled
    local isChecked = self.isChecked

    local path = Path.circle( math.min(self.height, self.height) )

    local fillColour = isEnabled and ( isPressed and self.pressedFillColour or ( isChecked and self.checkedFillColour or self.fillColour ) ) or ( isChecked and self.disabledCheckedFillColour or self.disabledFillColour )
    local outlineColour = isEnabled and ( isPressed and self.pressedOutlineColour or self.outlineColour ) or self.disabledOutlineColour
    self:drawPath( 1, 1, path, fillColour, outlineColour )
end
