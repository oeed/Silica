
class "Checkbox" extends "View" {

    width = 7;
    height = 7;

    isPressed = false;
    isEnabled = true;
    isChecked = false;
    cornerRadius = 2;

    textColour = Graphics.colours.BLACK;
    backgroundColour = Graphics.colours.WHITE;
    outlineColour = Graphics.colours.LIGHT_GREY;

    pressedTextColour = Graphics.colours.BLACK;
    pressedBackgroundColour = Graphics.colours.LIGHT_BLUE;
    pressedOutlineColour = Graphics.colours.BLUE;

    checkedTextColour = Graphics.colours.BLACK;
    checkedBackgroundColour = Graphics.colours.BLUE;
    checkedTickColour = Graphics.colours.WHITE;
    checkedOutlineColour = Graphics.colours.BLUE;

    disabledTextColour = Graphics.colours.LIGHT_GREY;
    disabledBackgroundColour = Graphics.colours.WHITE;
    disabledOutlineColour = Graphics.colours.LIGHT_GREY;

    disabledCheckedTextColour = Graphics.colours.LIGHT_GREY;
    disabledCheckedBackgroundColour = Graphics.colours.GREY;
    disabledCheckedTickColour = Graphics.colours.LIGHT_GREY;
    disabledCheckedOutlineColour = Graphics.colours.GREY;

}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function Checkbox:init( ... )
	self.super:init( ... )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onMouseUp, EventManager.phase.BEFORE )
    self:initCanvas()
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Checkbox:initCanvas()
    self.backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width, self.height, self.backgroundColour, self.outlineColour, self.cornerRadius ) )
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Checkbox:setIsPressed( isPressed )
    self.backgroundObject.fillColour = self.isEnabled and ( isPressed and self.pressedBackgroundColour or (self.isChecked and self.checkedBackgroundColour or self.backgroundColour ) ) or self.disabledBackgroundColour
    self.backgroundObject.outlineColour = self.isEnabled and ( isPressed and self.pressedOutlineColour or (self.isChecked and self.checkedOutlineColour or self.outlineColour ) ) or self.disabledOutlineColour
    self.isPressed = isPressed
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Checkbox:setIsChecked( isChecked )
    self.backgroundObject.fillColour = self.isEnabled and ( self.isPressed and self.pressedBackgroundColour or (isChecked and self.checkedBackgroundColour or self.backgroundColour ) ) or self.disabledBackgroundColour
    self.backgroundObject.outlineColour = self.isEnabled and ( self.isPressed and self.pressedOutlineColour or (isChecked and self.checkedOutlineColour or self.outlineColour ) ) or self.disabledOutlineColour
    self.isChecked = isChecked
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
            self.isChecked = not self.isChecked
    		if self:hitTestEvent( event ) then
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

--[[
    @instance
    @desc Gets the corner radius, shrinking it if necesary
    @return [number] cornerRadius -- the corner radius
]]
function Checkbox:getCornerRadius()
    return math.min( self.cornerRadius, math.floor( self.height / 2 ) )
end