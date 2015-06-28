
class "Radio" extends "View" {

    width = 7;
    height = 7;

    isPressed = false;
    isEnabled = true;
    isChecked = false;

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

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Radio:initCanvas()
    self.super:initCanvas()
    local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width, self.height, self.theme.fillColour, self.theme.outlineColour, self.theme.cornerRadius ) )
    self.theme:connect( backgroundObject, 'fillColour' )
    self.theme:connect( backgroundObject, 'outlineColour' )
    self.theme:connect( backgroundObject, 'radius', 'cornerRadius' )
    self.backgroundObject = backgroundObject
end

function Radio:setHeight( height )
    self.super:setHeight( height )
    if self.hasInit then
        self.backgroundObject.height = height
    end
end

function Radio:setWidth( width )
    self.super:setWidth( width )
    if self.hasInit then
        self.backgroundObject.width = width
    end
end

--[[
    @instance
    @desc Sets the checked state of the radio button. Sets all other sibling (in the same container) radios to false if being set to true
    @param [boolean] isChecked -- the new checked state
]]
function Radio:setIsChecked( isChecked )
    self.isChecked = isChecked
    if self.hasInit then
        if isChecked then
            for i, sibling in ipairs( self:siblingsOfType( Radio ) ) do
                sibling.isChecked = false
            end
        end
        self:updateThemeStyle()
    end
end


function Radio:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or (self.isChecked and "checked" or "default" ) ) or ( self.isChecked and "disabledChecked" or "disabled" )
end

function Radio:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    if self.hasInit then
        self:updateThemeStyle()
    end
end

--[[
    @instance
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Radio:setIsPressed( isPressed )
    self.isPressed = isPressed
    if self.hasInit then
        self:updateThemeStyle()
    end
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Radio:onGlobalMouseUp( event )
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
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
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end
