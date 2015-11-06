
local SIDE_MARGIN = 6
local TOP_MARGIN = 5
local BOTTOM_MARGIN = TOP_MARGIN

class "ListContainer" extends "ScrollContainer" implements "IDragDropDestination" {
    
    needsLayoutUpdate = false;
    isCanvasHitTested = false;
    canRearrange = true;
    dropStyle = DragDropManager.dropStyles.RETURN;
    canTransferItems = false;

}

function ListContainer:initialise( ... )
    self.super:initialise( ... )
    self:event( Event.CHILD_ADDED, self.onChildAdded )
    self:event( Event.CHILD_REMOVED, self.onChildRemoved )
    self:event( Event.INTERFACE_READY, self.onReady )
end

function ListContainer:onReady( event )
    self:updateLayout( true )
end

function ListContainer:update( deltaTime )
    self.super:update( deltaTime )
    if self.needsLayoutUpdate then
        self:updateLayout()
    end
end

function ListContainer:onChildAdded( event )
    if not event.childView:typeOf( ListItem ) then
        error( "Attempted to add view '" .. tostring( event.childView ) .. "' that does not extend ListItem to '" .. tostring( self ) .. "'", 0 )
    end
    self.needsLayoutUpdate = true
end

function ListContainer:onChildRemoved( event )
    self.needsLayoutUpdate = true
end

function ListContainer:updateLayout( dontAnimate )
    local children, width = self.children, self.width
    local y = TOP_MARGIN + 1

    local time, easing = 0.5, Animation.easing.SINE_IN_OUT

    for i, childView in ipairs( children ) do
        if dontAnimate then
            childView.y = y
        else
            childView:animateY( y, time, nil, easing )
        end
        childView.x = 1
        childView.width = width
        y = y + childView.height
    end

    self.height = y + BOTTOM_MARGIN

    self.needsLayoutUpdate = false
end

function ListContainer:canAcceptDragDrop( data )
    return data:typeOf( ListClipboardData ) and (self.canTransferItems or data.listItem.parent == self)
end

function ListContainer:dragDropMoved( data, dragView )
    local _, selfY = self:position()
    local listItem = data.listItem
    local children = self.children
    local index = math.max( math.min( math.floor( ( dragView.y - selfY - TOP_MARGIN - 1 ) / listItem.height + 1.5 ), #children), 1 )
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

