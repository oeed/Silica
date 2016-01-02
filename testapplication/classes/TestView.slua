
class "TestView" extends "View" {

    isPressed = Boolean( false );

}

function TestView:initialise( ... )
    self:super( ... )

    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
end

function TestView:onMouseDown( MouseDownEvent event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        if self:hitTestEvent( event ) then
        self.isPressed = true
    end
    end
    return true
end

function TestView:onGlobalMouseUp( MouseUpEvent event, Event.phases phase )
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = false
        if self:hitTestEvent( event ) then
            -- self.event:handleEvent( ActionInterfaceEvent( self ) )
            -- local result = self.event:handleEvent( event )
            -- return result == nil and true or result
        end
    end
end

function TestView:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" ) or "disabled"
end

function TestView.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

function TestView:onDraw()
    local canvas, theme = self.canvas, self.theme
    canvas:fill( theme:value( "fillColour" ), RoundedRectangleMask( 1, 1, self.width, self.height, 4 ) )
end