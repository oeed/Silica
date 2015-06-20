
class "Button" extends "View" {

    height = 12; -- the default height

    isPressed = false;
    isEnabled = true;
    cornerRadius = 6;

    textColour = Graphics.colours.BLACK;
    backgroundColour = Graphics.colours.WHITE;
    outlineColour = Graphics.colours.LIGHT_GREY;

    pressedTextColour = Graphics.colours.WHITE;
    pressedBackgroundColour = Graphics.colours.BLUE;
    pressedOutlineColour = nil;

    disabledTextColour = Graphics.colours.LIGHT_GREY;
    disabledBackgroundColour = Graphics.colours.WHITE;
    disabledOutlineColour = Graphics.colours.LIGHT_GREY;

    shadowColour = Graphics.colours.GREY;

    shadowObject = nil;
    backgroundObject = nil;
}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function Button:init( ... )
    self.super:init( ... )
    
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
end

function Button:setHeight( height )
    self.super:setHeight( height )
    if self.canvas then
        local cornerRadius = math.min( height / 2, self.cornerRadius )
        self.cornerRadius = cornerRadius
        self.shadowObject.radius = cornerRadius
        self.backgroundObject.radius = cornerRadius
        self.backgroundObject.height = height - 1
        self.shadowObject.height = height - 1
    end
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Button:initCanvas()
    local cornerRadius = self.cornerRadius
    self.shadowObject = self.canvas:insert( RoundedRectangle( 2, 2, self.width - 1, self.height - 1, self.shadowColour, nil, cornerRadius ) )
    self.backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width - 1, self.height - 1, self.backgroundColour, self.outlineColour, cornerRadius ) )
end

--[[
    @instance
    @desc Update the canvas appearance.
]]
function Button:updateCanvas()
    if self.canvas and self.backgroundObject then
        self.backgroundObject.fillColour = self.isEnabled and ( self.isPressed and self.pressedBackgroundColour or self.backgroundColour ) or self.disabledBackgroundColour
        self.backgroundObject.outlineColour = self.isEnabled and ( self.isPressed and Graphics.colours.TRANSPARENT or self.outlineColour ) or self.disabledOutlineColour
        self.backgroundObject.x = self.isPressed and 2 or 1
        self.backgroundObject.y = self.isPressed and 2 or 1
    end
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Button:setIsPressed( isPressed )
    self.isPressed = isPressed
    if isPressed ~= nil then
        self:updateCanvas()
    end
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Button:onGlobalMouseUp( event )
    if self.isPressed then
        self.isPressed = false
        if self.isEnabled and self:hitTestEvent( event ) then
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
function Button:onMouseDown( event )
    if self.isEnabled then
        self.isPressed = true
    end
    return true
end
