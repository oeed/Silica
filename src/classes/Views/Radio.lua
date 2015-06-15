
class "Radio" extends "View" {

    isPressed = false;
    isEnabled = true;
    isChecked = false;

    textColour = colours.black;
    backgroundColour = colours.white;
    outlineColour = colours.lightGrey;

    pressedTextColour = colours.black;
    pressedBackgroundColour = colours.lightBlue;
    pressedOutlineColour = colours.blue;

    checkedTextColour = colours.black;
    checkedBackgroundColour = colours.blue;
    checkedOutlineColour = nil;

    disabledTextColour = colours.lightGrey;
    disabledBackgroundColour = colours.white;
    disabledOutlineColour = colours.lightGrey;

    disabledCheckedTextColour = colours.lightGrey;
    disabledCheckedBackgroundColour = colours.grey;
    disabledCheckedOutlineColour = nil;

}

--[[
    @instance
    @desc Creates a button object and connects the event handlers
]]
function Radio:init( ... )
	self.super:init( ... )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onMouseUp, EventManager.phase.BEFORE )
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
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Radio:onMouseUp( event, arg2, arg3 )
    if self.isPressed then
        self.isPressed = false
        self.isChecked = not self.isChecked
        if self:hitTestEvent( event ) then
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
function Radio:onMouseDown( event, arg2, arg3 )
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

    local backgroundColour = isEnabled and ( isPressed and self.pressedBackgroundColour or ( isChecked and self.checkedBackgroundColour or self.backgroundColour ) ) or ( isChecked and self.disabledCheckedBackgroundColour or self.disabledBackgroundColour )
    local outlineColour = isEnabled and ( isPressed and self.pressedOutlineColour or self.outlineColour ) or self.disabledOutlineColour
    self:drawPath( 1, 1, path, backgroundColour, outlineColour )
end
