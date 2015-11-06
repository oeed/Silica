
local SHADOW_RATIO = 2/3
local MAX_SHADOW_SIZE = 3

class "DragDropManager" {
    
    owner = false;
    dragView = false;
    data = false;
    relativeX = false;
    relativeY = false;
    destination = false;
    didHideSource = false;
    sourceViews = false;
    completion = false;

    dropStyles = {
        DISAPPEAR = 0;
        SHRINK = 1;
        RETURN = 2;
    }

}

--[[
    @instance
    @desc Creates a drag and drop manager
    @param [Application] owner -- the manager owner
]]
function DragDropManager:initialise( owner )
    self.owner = owner
    owner:event( Event.MOUSE_DRAG, self.onMouseDrag, nil, nil, self )
    owner:event( Event.MOUSE_UP, self.onMouseUp, nil, nil, self )
end

--[[
    @instance
    @desc Starts a drag and drop proccess
    @param [Table{View}] views -- the view being dragged
    @param [ClipboardData] data -- the data that will be given to the destination
    @param [number] relativeX -- the x coordinate relative to view the mouse is located
    @param [number] relativeY -- the x coordinate relative to view the mouse is located
    @param [boolean] hideSource -- whether the source view should be hidden during dragging
    @param [function] completion -- called when the drag and drop is cancelled or successful (destination view passed if dropped, nil if cancelled)
]]
function DragDropManager:start( views, data, relativeX, relativeY, hideSource, completion )
    if not data or not data:typeOf( ClipboardData ) then
        error( "Drag and drop must provide a valid ClipboardData source.", 4 )
    end

    local x, y, x2, y2 = self.owner.container.width, self.owner.container.height, 1, 1
    local images = {}
    for i, view in ipairs( views ) do
        if not view:typeOf( IDraggableView ) then
            error( "Drag and drop can only be used on Views the implement IDraggableView.", 4 )
        end

        local viewX, viewY = view:position()
        local viewWidth, viewHeight = view.width, view.height
        x = math.min( x, viewX )
        y = math.min( y, viewY )
        x2 = math.max( x2, viewX + viewWidth - 1 )
        y2 = math.max( y2, viewY + viewHeight - 1 )
        table.insert( images, { viewX, viewY, view.canvas:toImage(), view.canvas:toShadowImage() } )

        if hideSource then
            view.isVisible = false
        end
    end
    local width, height = x2 - x + 1, y2 - y + 1

    local image = Image.blank( width, height )
    local shadowImage = Image.blank( width, height )
    for i, imageData in ipairs( images ) do
        local _x, _y = imageData[1] - x + 1, imageData[2] - y + 1
        image:appendImage( imageData[3], _x, _y )
        shadowImage:appendImage( imageData[4], _x, _y )
    end

    self:cancel()
    local dragView = DragView( {
            width = width + SHADOW_RATIO * MAX_SHADOW_SIZE;
            height = height + MAX_SHADOW_SIZE;
            x = x;
            y = y;
            image = image;
            shadowImage = shadowImage;
        } )
    self.owner.container:insert( dragView )
    self.dragView = dragView
    self.data = data
    self.relativeX = relativeX - x + 1
    self.relativeY = relativeY - y + 1
    self.didHideSource = hideSource or false
    self.completion = completion or false
    self.sourceViews = views

    dragView:animate( "shadowSize", MAX_SHADOW_SIZE, 0.2, nil, Animation.easing.IN_SINE )
end

--[[
    @instance
    @desc Cancels the current drag and drop proccess, if one exists
    @return [boolean] didCancel -- whether a proccess was canceled (i.e. returns true if one existed)
]]
function DragDropManager:cancel()
    local dragView = self.dragView
    if dragView then
        local time, easing = 0.7, Animation.easing.OUT_SINE
        local didHideSource, completion = self.didHideSource, self.completion

        local sourceViews = self.sourceViews
        local originalX, originalY = self.owner.container.width, self.owner.container.height
        for i, view in ipairs( sourceViews ) do
            local viewX, viewY = view:position()
            originalX = math.min( originalX, viewX )
            originalY = math.min( originalY, viewY )
        end

        dragView:animateX( originalX, time, function()
            for i, view in ipairs( sourceViews ) do
                if didHideSource then
                    view.isVisible = true
                end
            end
            dragView.parent:remove( dragView )
            if completion then completion() end
        end, easing )
        dragView:animateY( originalY, time, nil, easing )
        dragView:animate( "shadowSize", 0, time, nil, easing )
        self.dragView = false
    end
end

--[[
    @instance
    @desc Sets the destination, informing the new and old destinations if they've changed
    @param [IDragDropDestination] destination
]]
function DragDropManager:setDestination( destination )
    local oldDestination = self.destination
    if oldDestination ~= destination then
        if oldDestination then
            oldDestination:dragDropExited( self.data, self.dragView )
        end
        if destination then
            destination:dragDropEntered( self.data, self.dragView )
        end
        self.destination = destination
    end
    if destination then
        destination:dragDropMoved( self.data, self.dragView )
    end
end

--[[
    @instance
    @desc Fired when the mouse is dragged in the application
    @param [MouseDragEvent] event -- the mouse dragged event
    @return [boolean] shouldCancel -- whether other events handlers should not recieve this event
]]
function DragDropManager:onMouseDrag( event )
    local dragView = self.dragView
    if dragView then
        dragView.x = event.x - self.relativeX + 1
        dragView.y = event.y - self.relativeY + 1
        self:updateDestination()
        return true
    end
end

--[[
    @instance
    @desc Fired when the mouse is released in the application
    @param [MouseUpEvent] event -- the mouse up event
    @return [boolean] shouldCancel -- whether other events handlers should not recieve this event
]]
function DragDropManager:onMouseUp( event )
    local dragView = self.dragView
    if dragView then
        local destination = self.destination
        if not destination then
            self:cancel()
            dragView.x = event.globalX - self.relativeX + 1
            dragView.y = event.globalY - self.relativeY + 1
        else
            destination:dragDropDropped( self.data )
            local dropStyle = destination.dropStyle
            local dropStyles = self.dropStyles
            local function done()
                if self.didHideSource then
                    for i, view in ipairs( self.sourceViews ) do
                        view.isVisible = true
                    end
                end
                dragView.parent:remove( dragView )
                local completion = self.completion
                if completion then completion( destination ) end
            end
            if dropStyle == dropStyles.SHRINK then
                local time, easing = 0.5, Animation.easing.OUT_SINE
                local x, y, width, height = dragView.x, dragView.y, dragView.width, dragView.height
                dragView:animateWidth( 1, time, done, easing )
                dragView:animateHeight( 1, time, nil, easing )
                dragView:animateX( math.ceil( x + self.relativeX - 1 ), time, nil, easing )
                dragView:animateY( math.ceil( y + self.relativeY - 1), time, nil, easing )
                dragView.shadowObject.isVisible = false
            elseif dropStyle == dropStyles.RETURN then
                local time, easing = 0.5, Animation.easing.OUT_SINE
                local originalX, originalY = self.owner.container.width, self.owner.container.height
                for i, view in ipairs( self.sourceViews ) do
                    local viewX, viewY = view:position()
                    originalX = math.min( originalX, viewX )
                    originalY = math.min( originalY, viewY )
                end
                dragView:animateX( originalX, time, done, easing )
                dragView:animateY( originalY, time, nil, easing )
                dragView:animate( "shadowSize", 0, time, nil, easing )
            else
                done()
            end
            self.dragView = false
            self.destination = false
        end
        return true
    end
end

--[[
    @instance
    @desc Finds the lowest level (i.e. the view with most parents above it) view at the current view coordinates that accepts the drag
]]
function DragDropManager:updateDestination()
    local dragView = self.dragView
    if dragView then
        local ownerContainer = self.owner.container
        local data = self.data

        local function lookInView( view, x, y )
            if view:typeOf( Container ) then
                local children = view.children
                for i = #children, 1, -1 do
                    local childView = children[i]
                    if childView:hitTest( x, y ) then
                        local destination = lookInView( childView, x - childView.x + 1, y - childView.y + 1 )
                        if destination then
                            return destination
                        end
                    end
                end
            end

            if view:typeOf( IDragDropDestination ) and view:canAcceptDragDrop( data ) then
                return view
            end

            return false
        end

        self.destination = lookInView( ownerContainer, dragView.x + self.relativeX - 1, dragView.y + self.relativeY - 1 )
    else
        self.destination = false
    end
end
