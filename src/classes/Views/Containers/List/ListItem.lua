
local SIDE_MARGIN = 7
local TOP_BOTTOM_PADDING = 2

class "ListItem" extends "View" implements "IDraggableView" {
    
    height = Number( 12 );
    isSelected = Boolean( false );
    isCanvasHitTested = Boolean( false );

    backgroundObject = false;
    textObject = false;
    text = false;

}

function ListItem:initialise( ... )
    self:super( ... )

    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
    self:event( MouseHeldEvent, self.onMouseHeld )
end

function ListItem:initialiseCanvas()
    self:super()
    local width, height, canvas = self.width, self.height, self.canvas
    local backgroundObject = canvas:insert( RoundedRectangle( 2, 1, width - 2, height ) )
    local textObject = canvas:insert( Text( 1 + SIDE_MARGIN, 1 + TOP_BOTTOM_PADDING, 8, width - 2 * SIDE_MARGIN, self.text ) )

    self.theme:connect( backgroundObject, "radius", "cornerRadius" )
    self.theme:connect( backgroundObject, "fillColour" )
    self.theme:connect( textObject, "textColour" )

    self.backgroundObject = backgroundObject
    self.textObject = textObject
end

function ListItem:updateWidth( width )
    self.backgroundObject.width = width - 2
end

function ListItem.text:set( text )
    self.text = text
    self.textObject.text = text
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

function ListItem:onMouseHeld( Event event, Event.phases phase )
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