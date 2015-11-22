
class "Radio" extends "View" {

    width = Number( 7 );
    height = Number( 7 );

    isPressed = Boolean( false );
    isEnabled = Boolean( true );
    isChecked = Boolean( false );

}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function Radio:initialise( ... )
	self:super( ... )
    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
    end

--[[
    @desc Sets up the canvas and it's graphics objects
]]
function Radio:initialiseCanvas()
    self:super()
    local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width, self.height, self.theme.fillColour, self.theme.outlineColour, self.theme.cornerRadius ) )
    self.theme:connect( backgroundObject, "fillColour" )
    self.theme:connect( backgroundObject, "outlineColour" )
    self.theme:connect( backgroundObject, "radius", "cornerRadius" )
    self.backgroundObject = backgroundObject
end

function Radio:updateHeight( height )
    self.backgroundObject.height = height
end

function Radio:updateWidth( width )
    self.backgroundObject.width = width
end

--[[
    @desc Sets the checked state of the radio button. Sets all other sibling (in the same container) radios to false if being set to true
    @param [boolean] isChecked -- the new checked state
]]
function Radio.isChecked:set( isChecked )
    self.isChecked = isChecked
    if isChecked then
        for i, sibling in ipairs( self:siblingsOfType( Radio ) ) do
            sibling.isChecked = false
        end
    end
    self.event:handleEvent( ActionInterfaceEvent( self ) )
    self:updateThemeStyle()
end


function Radio:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or (self.isChecked and "checked" or "default" ) ) or ( self.isChecked and "disabledChecked" or "disabled" )
end

function Radio.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

--[[
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Radio.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

--[[
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Radio:onGlobalMouseUp( Event event, Event.phases phase )
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = false
        if self:hitTestEvent( event ) then
            self.isChecked = true
            return self.event:handleEvent( event )
        end
    end
end

--[[
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Radio:onMouseDown( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end
