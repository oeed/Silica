
class "Checkbox" extends "View" {

    width = 7;
    height = 7;

    isPressed = false;
    isEnabled = true;
    isChecked = false;

    checkObject = nil;

}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function Checkbox:init( ... )
	self.super:init( ... )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Checkbox:initCanvas()
    self.super:initCanvas()
    local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width, self.height, self.theme.fillColour, self.theme.outlineColour, self.theme.cornerRadius ) )
    
    local checkObject = Path( 2, 2, self.width - 2, self.height - 2, 1, 4 )
    checkObject:lineTo( 2, 5 )
    checkObject:lineTo( 5, 2 )
    checkObject:close( false )

    self.theme:connect( backgroundObject, "fillColour" )
    self.theme:connect( backgroundObject, "outlineColour" )
    self.theme:connect( backgroundObject, "radius", "cornerRadius" )
    self.theme:connect( checkObject, "outlineColour", "checkColour" )

    self.backgroundObject = backgroundObject
    self.checkObject = checkObject
    self.canvas:insert( checkObject )
end

function Checkbox:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or (self.isChecked and "checked" or "default" ) ) or ( self.isChecked and "disabledChecked" or "disabled" )
end

function Checkbox:updateHeight( height )
    self.backgroundObject.height = height
end

function Checkbox:updateWidth( width )
    self.backgroundObject.width = width
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Checkbox:setIsPressed( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Checkbox:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Checkbox:setIsChecked( isChecked )
    self.isChecked = isChecked
    self:updateThemeStyle()
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance. Sends the event to the local handler.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Checkbox:onGlobalMouseUp( event )	
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
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
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end