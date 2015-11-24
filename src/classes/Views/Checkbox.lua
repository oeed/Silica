
class "Checkbox" extends "View" {

    width = Number( 8 );
    height = Number( 8 );

    isPressed = Boolean( false );
    isEnabled = Boolean( true );
    isChecked = Boolean( false );

}

function Checkbox:initialise( ... )
	self:super( ... )
    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
end

function Checkbox:onDraw()
    local width, height, theme, canvas, isPressed = self.width, self.height, self.theme, self.canvas, self.isPressed

    -- background shape
    local roundedRectangle = RoundedRectangleMask( 1, 1, width, height, theme:value( "cornerRadius" ) )
    canvas:fill( theme:value( "fillColour" ), roundedRectangle )
    canvas:outline( theme:value( "outlineColour" ), roundedRectangle, theme:value( "outlineThickness" ) )
--  TODO: checkbox check drawing
--     local checkObject = Path( 2, 2, self.width - 2, self.height - 2, 1, 4 )
--     checkObject:lineTo( 2, 5 )
--     checkObject:lineTo( 5, 2 )
--     checkObject:close( false )
end

function Checkbox:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or (self.isChecked and "checked" or "default" ) ) or ( self.isChecked and "disabledChecked" or "disabled" )
end

function Checkbox.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

function Checkbox.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function Checkbox.isChecked:set( isChecked )
    local wasChecked = self.isChecked
    if isChecked ~= wasChecked then
        self.isChecked = isChecked
        self:updateThemeStyle()
        self.event:handleEvent( ActionInterfaceEvent( self ) )
    end
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

function Checkbox:onMouseDown( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end