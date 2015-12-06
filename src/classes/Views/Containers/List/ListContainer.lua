
class "ListContainer" extends "ScrollContainer" implements "IDragDropDestination" {
    
    needsLayoutUpdate = Boolean( false );
    isCanvasHitTested = Boolean( false );
    canRearrange = Boolean( true );
    dropStyle = DragDropManager.dropStyles.RETURN;
    canTransferItems = Boolean( false );

}

function ListContainer:initialise( ... )
    self:super( ... )
    self:event( ChildAddedInterfaceEvent, self.onChildAdded )
    self:event( ChildRemovedInterfaceEvent, self.onChildRemoved )
    self:event( ReadyInterfaceEvent, self.onReady )
end

function ListContainer:onReady( ReadyInterfaceEvent event, Event.phases phase )
    self:updateLayout( true )
end

function ListContainer:update( deltaTime )
    self:super( deltaTime )
    if self.needsLayoutUpdate then
        self:updateLayout()
    end
end

function ListContainer:onChildAdded( ChildAddedInterfaceEvent event, Event.phases phase )
    if not event.childView:typeOf( ListItem ) then
        error( "Attempted to add view '" .. tostring( event.childView ) .. "' that does not extend ListItem to '" .. tostring( self ) .. "'", 0 )
    end
    self.needsLayoutUpdate = true
end

function ListContainer:onChildRemoved( ChildRemovedInterfaceEvent event, Event.phases phase )
    self.needsLayoutUpdate = true
end

function ListContainer:updateLayout( dontAnimate )
    local children, width = self.children, self.width
    local y = self.theme:value( "topMargin" ) + 1

    local time, easing = 0.5, Animation.easings.IN_OUT_SINE

    for i, childView in ipairs( children ) do
        if dontAnimate then
            childView.y = y
        else
            childView:animate( "y", y, time, nil, easing )
        end
        childView.x = 1
        childView.width = width
        y = y + childView.height
    end

    self.height = y + self.theme:value( "bottomMargin" )

    self.needsLayoutUpdate = false
end

function ListContainer:canAcceptDragDrop( data )
    return data:typeOf( ListClipboardData ) and (self.canTransferItems or data.listItem.parent == self)
end

function ListContainer:dragDropMoved( data, dragView )
    local _, selfY = self:position()
    local listItem = data.listItem
    local children = self.children
    local index = math.max( math.min( math.floor( ( dragView.y - selfY - self.theme:value( "topMargin" ) - 1 ) / listItem.height + 1.5 ), #children), 1 )
    if listItem.index ~= index then
        listItem.index = index
        self.needsLayoutUpdate = true
    end
end

function ListContainer:dragDropEntered( data, dragView )
end

function ListContainer:dragDropExited( data, dragView )
    -- self:animate( "row", 0, 0.3 )
end

function ListContainer:dragDropDropped( data )

end

