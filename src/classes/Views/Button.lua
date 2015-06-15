
class "Button" extends "View" {

    height = 12; -- the default height
    width = 30;

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

    shadowObject = nil;
    backgroundObject = nil;
}

--[[
    @instance
    @desc Creates a button object and connects the event handlers
]]
function Button:init( ... )
	self.super:init( ... )
    
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onMouseUp, EventManager.phase.BEFORE )

    self:initCanvas()
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Button:initCanvas()
    -- self.canvas.colour = colours.blue
    -- self.canvas:insert( Rectangle( 2, 2, 10, 10, colours.green ) )
    self.shahdowObject = self.canvas:insert( Rectangle( 2, 2, self.width - 1, self.height - 1, self.shadowColour ) )
    self.backgroundObject = self.canvas:insert( Rectangle( 1, 1, self.width - 1, self.height - 1, self.backgroundColour ) )
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Button:setIsPressed( isPressed )
    self.backgroundObject.colour = self.isEnabled and ( isPressed and self.pressedBackgroundColour or self.backgroundColour ) or self.disabledBackgroundColour
    self.backgroundObject.x = isPressed and 2 or 1
    self.backgroundObject.y = isPressed and 2 or 1
    self.backgroundObject.hasChanged = true

    self.isPressed = isPressed
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Button:onMouseUp( event )
    print('up')
    if self.isPressed then
        self.isPressed = false
        -- if self:hitTestEvent( event ) then
        --     return self.event:handleEvent( event )
        -- end
    end
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Button:onMouseDown( event )
    if self.isEnabled then
        self.isPressed = true
    end
    return true
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
