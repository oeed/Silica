
local BUTTON_DIAMETER = 5

class WindowButton extends View {

	width = Number( 9 );
	height = Number( 9 );
    isPressed = Boolean( false );

    window = Window;

}

--[[
    @desc Creates a button object and connects the event handlers
]]
function WindowButton:initialise( ... )
    self:super( ... )
    
    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
    if self.onMouseUp then self:event( MouseUpEvent, self.onMouseUp ) end
end

function WindowButton:onDraw()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas

    local diameter = theme:value( "diameter" )
    local circleMask = CircleMask( 1 + math.ceil( ( width - diameter ) / 2 ), 1 + math.ceil( ( height - diameter ) / 2 ), diameter )
    canvas:fill( theme:value( "fillColour" ), circleMask )
    canvas:outline( theme:value( "outlineColour" ), circleMask, theme:value( "outlineThickness" ) )
end

function WindowButton:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function WindowButton.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function WindowButton.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

--[[
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function WindowButton:onGlobalMouseUp( MouseUpEvent event, Event.phases phase )
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = false
        if self.isEnabled and self:hitTestEvent( event ) then
            return self.event:handleEvent( event )
        end
    end
end

--[[
    @desc Fired when the mouse is pushed anywhere on screen. Adds the pressed appearance.
    @param [MouseDownEvent] event -- the mouse down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function WindowButton:onMouseDown( MouseDownEvent event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end
