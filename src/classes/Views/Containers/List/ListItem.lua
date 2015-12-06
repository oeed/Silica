
class "ListItem" extends "View" implements "IDraggableView" {
    
    height = Number( 12 );
    isSelected = Boolean( false );
    isCanvasHitTested = Boolean( false );

    text = String;

}

function ListItem:initialise( ... )
    self:super( ... )

    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
    self:event( MouseHeldEvent, self.onMouseHeld )
end

function ListItem:onDraw()
    local width, height, theme, canvas, font = self.width, self.height, self.theme, self.canvas

    local leftMargin, rightMargin, topMargin, bottomMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" )
    local roundedRectangleMask = RoundedRectangleMask( 1 + leftMargin, 1 + topMargin, width - leftMargin - rightMargin, height - topMargin - bottomMargin, theme:value( "cornerRadius" ) )
    canvas:fill( theme:value( "fillColour" ), roundedRectangleMask )

    local leftTextMargin, rightTextMargin, topTextMargin, bottomTextMargin = theme:value( "leftTextMargin" ), theme:value( "rightTextMargin" ), theme:value( "topTextMargin" ), theme:value( "bottomTextMargin" )
    canvas:fill( theme:value( "textColour" ),  TextMask( leftTextMargin + 1, topTextMargin + 1, width - leftTextMargin - rightTextMargin, height - topTextMargin - bottomTextMargin, self.text, theme:value( "font" ) ) )
end

function ListItem.text:set( text )
    self.text = text
    self.needsDraw = true
end

function ListItem:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isSelected and "selected" or "default" ) or "disabled"
end

function ListItem.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function ListItem.isSelected:set( isSelected )
    self.isSelected = isSelected
    self:updateThemeStyle()
end

function ListItem:onMouseHeld( MouseHeldEvent event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT and self.parent.canRearrange then
        self.isSelected = true
        self:startDragDrop( event, ListClipboardData( self ), true, function()self.isSelected = false end )
    end
    return true
end

function ListItem:onGlobalMouseUp( MouseUpEvent event, Event.phases phase )
    if self.isSelected and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isSelected = false
        if self.isEnabled and self:hitTestEvent( event ) then
            self.event:handleEvent( ActionInterfaceEvent( self ) )
            local result = self.event:handleEvent( event )
            return result == nil and true or result
        end
        return true
    end
end

function ListItem:onMouseDown( MouseDownEvent event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isSelected = not self.isSelected
    end
    return true
end