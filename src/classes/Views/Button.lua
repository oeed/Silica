
class "Button" extends "View" {

    height = 12; -- the default height
    width = 30;

    isPressed = false;
    isEnabled = true;
    cornerRadius = 6;

    shadowObject = nil;
    backgroundObject = nil;

    themeStyle = 'default';
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
    self.backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width - 1, self.height - 1, self.fillColour, self.outlineColour, cornerRadius ) )
end

--[[
    @instance
    @desc Returns the current fill colour for the current style
    @return [Graphics.colours] colour -- the fill colour
]]
function Button:getFillColour()
    return self:themeValue( "fillColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current outline colour for the current style
    @return [Graphics.colours] colour -- the outline colour
]]
function Button:getOutlineColour()
    return self:themeValue( "outlineColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current shadow colour for the current style
    @return [Graphics.colours] colour -- the shadow colour
]]
function Button:getShadowColour()
    return self:themeValue( "shadowColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current corner radius for the current style
    @return [number] cornerRadius -- the corner radius
]]
function Button:getCornerRadius()
    return self:themeValue( "cornerRadius", self.themeStyle )
end

--[[
    @instance
    @desc Update the canvas appearance.
]]
function Button:updateCanvas()
    local backgroundObject = self.backgroundObject
    if self.canvas and backgroundObject then
        self.themeStyle = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
        self.shadowObject.fillColour = self.shadowColour
        backgroundObject.fillColour = self.fillColour
        backgroundObject.outlineColour = self.outlineColour
        
        local isPressed = self.isPressed
        backgroundObject.x = isPressed and 2 or 1
        backgroundObject.y = isPressed and 2 or 1
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
