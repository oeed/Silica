
class "Checkbox" extends "View" {

    width = 7;
    height = 7;

    isPressed = false;
    isEnabled = true;
    isChecked = false;
    cornerRadius = 2;

    textColour = Graphics.colours.BLACK;
    fillColour = Graphics.colours.WHITE;
    outlineColour = Graphics.colours.LIGHT_GREY;

    pressedTextColour = Graphics.colours.BLACK;
    pressedFillColour = Graphics.colours.LIGHT_BLUE;
    pressedOutlineColour = Graphics.colours.BLUE;

    checkedTextColour = Graphics.colours.BLACK;
    checkedFillColour = Graphics.colours.BLUE;
    checkedCheckColour = Graphics.colours.WHITE;
    checkedOutlineColour = Graphics.colours.BLUE;

    disabledTextColour = Graphics.colours.LIGHT_GREY;
    disabledFillColour = Graphics.colours.WHITE;
    disabledOutlineColour = Graphics.colours.LIGHT_GREY;

    disabledCheckedTextColour = Graphics.colours.LIGHT_GREY;
    disabledCheckedFillColour = Graphics.colours.GREY;
    disabledCheckedCheckColour = Graphics.colours.LIGHT_GREY;
    disabledCheckedOutlineColour = Graphics.colours.GREY;

    checkObject = nil;

}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function Checkbox:init( ... )
	self.super:init( ... )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onMouseUp, EventManager.phase.BEFORE )
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Checkbox:initCanvas()
    self.backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width, self.height, self.fillColour, self.outlineColour, self.cornerRadius ) )
    
    local checkObject = Path( 2, 2, self.width - 2, self.height - 2, Graphics.colours.TRANSPARENT, 1, 4 )
    checkObject:lineTo( 2, 5 )
    checkObject:lineTo( 5, 2 )
    checkObject:lineTo( 2, 5 )
    checkObject:close()
    checkObject.outlineColour = self.checkedCheckColour
    self.checkObject = checkObject
    self.canvas:insert( checkObject )
end

--[[
    @instance
    @desc Returns the current fill colour for the current style
    @return [Graphics.colours] colour -- the fill colour
]]
function Checkbox:getFillColour()
    return self:themeValue( "fillColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current outline colour for the current style
    @return [Graphics.colours] colour -- the outline colour
]]
function Checkbox:getOutlineColour()
    return self:themeValue( "outlineColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current check colour for the current style
    @return [Graphics.colours] colour -- the check colour
]]
function Checkbox:getCheckColour()
    return self:themeValue( "checkColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current corner radius for the current style
    @return [number] cornerRadius -- the corner radius
]]
function Checkbox:getCornerRadius()
    return self:themeValue( "cornerRadius", self.themeStyle )
end

--[[
    @instance
    @desc Update the canvas appearance.
]]
function Checkbox:updateCanvas()
    if self.canvas and self.backgroundObject then
        self.themeStyle = self.isEnabled and ( self.isPressed and "pressed" or (self.isChecked and "checked" or "default" ) ) or ( self.isChecked and "disabledChecked" or "disabled" )
        self.backgroundObject.fillColour = self.fillColour
        self.backgroundObject.outlineColour = self.outlineColour
        self.checkObject.outlineColour = self.checkColour
    end
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Checkbox:setIsPressed( isPressed )
    self.isPressed = isPressed
    self:updateCanvas()
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Checkbox:setIsChecked( isChecked )
    self.isChecked = isChecked
    self:updateCanvas()
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance. Sends the event to the local handler.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Checkbox:onMouseUp( event )	
    if self.isPressed then
        self.isPressed = false
        if self.isEnabled then
    		if self:hitTestEvent( event ) then
                self.isChecked = not self.isChecked
    			return self.event:handleEvent( event )
            end
		end
    end
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Checkbox:onMouseDown( event )
    if self.isEnabled then
        self.isPressed = true
    end
    return true
end