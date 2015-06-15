
class "Button" extends "View" {

    isPressed = false;
    isEnabled = true;
    cornerRadius = 6;

    textColour = colours.black;
    backgroundColour = colours.white;
    outlineColour = colours.lightGrey;

    pressedTextColour = colours.white;
    pressedBackgroundColour = colours.blue;
    pressedOutlineColour = nil;

    disabledTextColour = colours.lightGrey;
    disabledBackgroundColour = colours.white;
    disabledOutlineColour = colours.lightGrey;

    shadowColour = colours.grey;
}

--[[
    @instance
    @desc Creates a button object and connects the event handlers
]]
function Button:init( ... )
	self.super:init( ... )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onMouseUp, EventManager.phase.BEFORE )
    
    self.canvas:insert( Rectangle( 100, 100, 100, 100, colours.green ) ) -- and where is Button being called?
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Button:onMouseUp( event, arg2, arg3 )
    if self.isPressed then
        self.isPressed = false
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
function Button:onMouseDown( event, arg2, arg3 )
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
function Button:getCornerRadius()
    return math.min( self.cornerRadius, math.floor( self.height / 2 ) )
end

--[[
    @instance
    @desc Draws the button to the canvas
]]
-- function Button:draw()
--     local radius = self.cornerRadius
--     local isPressed = self.isPressed
--     local isEnabled = self.isEnabled

--     local path = Path.rectangle( self.width - 1, self.height - 1, radius )

--     if not isPressed then
--         self:drawPath( 2, 2, path, self.shadowColour )
--     end

--     local backgroundColour = isEnabled and ( isPressed and self.pressedBackgroundColour or self.backgroundColour ) or self.disabledBackgroundColour
--     local outlineColour = isEnabled and ( isPressed and self.pressedOutlineColour or self.outlineColour ) or self.disabledOutlineColour
--     self:drawPath( 1 + (isPressed and 1 or 0), 1 + (isPressed and 1 or 0), path, backgroundColour, outlineColour )

--     if self.text then -- possibly to be used for Button subclasses that use images, etc
--         local textColour = isEnabled and ( isPressed and self.pressedTextColour or self.textColour ) or self.disabledTextColour
--         self:drawText( 2, 2, self.width - 2, self.height - 2, self.text, self.font, textColour)
--     end
-- end
