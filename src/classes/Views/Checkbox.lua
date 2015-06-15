
class "Checkbox" extends "View" {

    isPressed = false;
    isEnabled = true;
    isChecked = false;
    cornerRadius = 1;

    textColour = colours.black;
    backgroundColour = colours.white;
    outlineColour = colours.lightGrey;

    pressedTextColour = colours.black;
    pressedBackgroundColour = colours.lightBlue;
    pressedOutlineColour = colours.blue;

    checkedTextColour = colours.black;
    checkedBackgroundColour = colours.blue;
    checkedTickColour = colours.white;
    checkedOutlineColour = nil;

    disabledTextColour = colours.lightGrey;
    disabledBackgroundColour = colours.white;
    disabledOutlineColour = colours.lightGrey;

    disabledCheckedTextColour = colours.lightGrey;
    disabledCheckedBackgroundColour = colours.grey;
    disabledCheckedTickColour = colours.lightGrey;
    disabledCheckedOutlineColour = nil;

}

--[[
    @instance
    @desc Creates a button object and connects the event handlers
]]
function Checkbox:init( ... )
	self.super:init( ... )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onMouseUp, EventManager.phase.BEFORE )
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

--[[
    @instance
    @desc Draws the checkbox to the canvas
]]
-- function Checkbox:draw()
--     local radius = self.cornerRadius
--     local isPressed = self.isPressed
--     local isEnabled = self.isEnabled
--     local isChecked = self.isChecked

--     local path = Path.rectangle( self.height, self.height, radius )

--     local backgroundColour = isEnabled and ( isPressed and self.pressedBackgroundColour or ( isChecked and self.checkedBackgroundColour or self.backgroundColour ) ) or ( isChecked and self.disabledCheckedBackgroundColour or self.disabledBackgroundColour )
--     local outlineColour = isEnabled and ( isPressed and self.pressedOutlineColour or self.outlineColour ) or self.disabledOutlineColour
--     self:drawPath( 1, 1, path, backgroundColour, outlineColour )

--     if isChecked then
-- 	    local tick = Path:new( 1, self.height - 3 )
-- 	    tick:lineTo( (self.width - 2) / 5, self.height - 3 )
-- 	    tick:lineTo( 4 * (self.height - 2) / 5, (self.height - 2) / 5 )
-- 	    tick:lineTo( (self.width - 2) / 5, self.height - 3 )
-- 	    tick:close()

-- 	    local tickColour = isEnabled and self.checkedTickColour or self.disabledCheckedTickColour
-- 	    self:drawPath( 2, 2, tick, nil, tickColour )
-- 	end
-- end
