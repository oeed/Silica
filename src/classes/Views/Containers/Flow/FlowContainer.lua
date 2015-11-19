
local TOP_MARGIN = 5
local BOTTOM_MARGIN = 5
local SIDE_MARGIN = 6

class "FlowContainer" extends "Container" {
    
    needsLayoutUpdate = false;
    expandVertically = true;

}

function FlowContainer:initialise( ... )
    self:super( ... )
    self:event( ChildAddedInterfaceEvent, self.onChildAdded )
    self:event( ChildRemovedInterfaceEvent, self.onChildRemoved )
    self:event( ReadyInterfaceEvent, self.onReady )
end

function FlowContainer:initialiseCanvas()
    self:super()

    self.theme:connect( self.canvas, "fillColour" )
end

function FlowContainer:updateWidth( width )
    self.needsLayoutUpdate = true
end

function FlowContainer:updateHeight( height )
    -- self.needsLayoutUpdate = true
end

function FlowContainer:onReady( event )
    self:updateLayout( true )
end

function FlowContainer:update( deltaTime )
    self:super( deltaTime )
    if self.needsLayoutUpdate then
        self:updateLayout()
    end
end

function FlowContainer:onChildAdded( event )
    if event.childView:typeOf( IFlowItem ) then
        self.needsLayoutUpdate = true
    end
end

function FlowContainer:onChildRemoved( event )
    self.needsLayoutUpdate = true
end

function FlowContainer:updateLayout( dontAnimate )
    local width, height = self.width, self.height

    local children = {}
    for i, childView in ipairs( self.children ) do
        if childView:typeOf( IFlowItem ) then
            table.insert( children, childView )
        end
    end

    local time, easing = 0.5, Animation.easings.SINE_IN_OUT

    local nChildren = #children
    local totalWidth = 0
    local minWidths = {}
    for i, childView in ipairs( children ) do
        totalWidth = totalWidth + childView.idealWidth
        minWidths[i] = childView.minWidth or 1
    end

    local averageWidth = math.min( math.floor( totalWidth / nChildren + 0.5 ), width - 2 * SIDE_MARGIN )
    local maxItemsPerRow = math.floor( totalWidth / averageWidth + 0.5 )
    local idealWidth = math.floor( totalWidth / maxItemsPerRow )

    local y = TOP_MARGIN + 1

    local _i = 0
    for i = 1, nChildren do
        if i > _i then
            local rowWidth = 2 * SIDE_MARGIN
            local x = SIDE_MARGIN + 1
            local numberOfItems = 1

            local totalMinWidths = 0
            local spareWidth = width - rowWidth
            for n = 1, math.min( maxItemsPerRow, nChildren - i + 1 ) do
                local minWidth = minWidths[i + n - 1]
                totalMinWidths = totalMinWidths + minWidth
                if totalMinWidths + rowWidth > width then
                    if n == 1 then
                        spareWidth = spareWidth - minWidth
                    end
                    break
                end
                numberOfItems = n
                spareWidth = spareWidth - minWidth
            end

            local itemWidth = spareWidth / numberOfItems
            _i = _i + numberOfItems

            local height = 1
            for n = i, _i do
                local childView = children[n]
                local width = minWidths[n] + ( n == i and math.ceil or math.floor)(itemWidth)
                local idealHeight = childView.idealHeight
                local maxWidth = childView.maxWidth
                width = (maxWidth and math.min( width, maxWidth ) or width)
                if dontAnimate then
                    childView.x = x
                    childView.y = y
                    childView.width = width
                    childView.height = idealHeight
                else
                    childView:animateX( x, time, nil, easing )
                    childView:animateY( y, time, nil, easing )
                    childView:animateWidth( width, time, nil, easing )
                    childView:animateHeight( idealHeight, time, nil, easing )
                end
                x = x + width
                height = math.max( idealHeight, height )
            end
            y = y + height
        end
    end

    self:animateHeight( y + BOTTOM_MARGIN, time, nil, easing )

    self.needsLayoutUpdate = false
end
