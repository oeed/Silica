
class "Checkbox" extends "View" {

    width = Number( 7 );
    height = Number( 7 );

    isPressed = Boolean( false );
    isEnabled = Boolean( true );
    isChecked = Boolean( false );

    checkObject = false;

}

--[[
    @desc Creates a button object and connects the event handlers
]]
function Checkbox:initialise( ... )
	self:super( ... )
    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
end

--[[
    @desc Sets up the canvas and it's graphics objects
]]
function Checkbox:initialiseCanvas()
    self:super()
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
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Checkbox.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

--[[
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Checkbox.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

--[[
    @desc Sets whether the button is pressed, changing the drawing state
]]
function Checkbox.isChecked:set( isChecked )
    self.isChecked = isChecked
    self:updateThemeStyle()
end

--[[
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance. Sends the event to the local handler.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Checkbox:onGlobalMouseUp( Event event, Event.phases phase )	
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
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Checkbox:onMouseDown( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end