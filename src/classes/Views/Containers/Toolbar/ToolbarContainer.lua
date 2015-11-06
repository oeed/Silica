
local SIDE_MARGIN = 6
local TOP_MARGIN = 5

class "ToolbarContainer" extends "Container" {

    needsLayoutUpdate = false;
    separatorObject = false;

}

function ToolbarContainer:initialise( ... )
    self.super:initialise( ... )

    self:event( Event.CHILD_ADDED, self.onChildAdded )
    self:event( Event.CHILD_REMOVED, self.onChildRemoved )
end

function ToolbarContainer:initialiseCanvas()
    self.super:initialiseCanvas()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas
    local separatorObject = canvas:insert( Separator( 1, 1, width, height ) )

    theme:connect( separatorObject, "fillColour", "separatorFillColour" )
    theme:connect( separatorObject, "isDashed", "separatorIsDashed" )
    theme:connect( canvas, "fillColour" )

    self.separatorObject = separatorObject
end

function ToolbarContainer:updateWidth( width )
    -- self:updateLayout( true )
    self.separatorObject.width = width
end

function ToolbarContainer:updateHeight( height )
    self.separatorObject.y = height
end

function ToolbarContainer:update( deltaTime )
    self.super:update( deltaTime )
    if self.needsLayoutUpdate then
        self:updateLayout()
    end
end

function ToolbarContainer:onChildAdded( event )
    if not event.childView:typeOf( IToolbarItem ) then
        error( "Attempted to add view '" .. tostring( event.childView ) .. "' that does not implement IToolbarItem to '" .. tostring( self ) .. "'", 0 )
    end
    self.needsLayoutUpdate = true
end

function ToolbarContainer:onChildRemoved( event )
    self.needsLayoutUpdate = true
end

function ToolbarContainer:updateLayout( )
    local children, width = self.children, self.width
    local remainingWidth = width - 2 * SIDE_MARGIN + 1
    local x = 1 + SIDE_MARGIN
    local dynamicItems = 0
    local items = {}

    local contentHeight = 0

    for i, childView in ipairs( children ) do
        local isPressable = childView:typeOf( IToolbarPressableItem )
        childView.y = 1 + TOP_MARGIN
        contentHeight = math.max( childView.height - (isPressable and 1 or 0), contentHeight )

        if childView:typeOf( ToolbarStaticSpace ) then
            local childWidth = childView.width
            remainingWidth = remainingWidth - childWidth
            items[i] = { nil, childWidth }
        elseif childView:typeOf( IToolbarDynamicItem ) then
            dynamicItems = dynamicItems + 1
            items[i] = { childView, nil, isPressable }
            remainingWidth = remainingWidth - SIDE_MARGIN
        else
            local childWidth = childView.width
            remainingWidth = remainingWidth - childWidth - SIDE_MARGIN
            items[i] = { childView, childWidth, isPressable }
        end
    end

    local dynamicWidth = (remainingWidth + SIDE_MARGIN) / dynamicItems
    local passedFirstDynamic = false
    for i, item in ipairs( items ) do
        local childView, childWidth, isPressable = item[1], item[2], item[3]
        if not childWidth then
            if passedFirstDynamic then
                childWidth = math.floor( dynamicWidth )
            else
                childWidth = math.ceil( dynamicWidth )
                passedFirstDynamic = true
            end
        end
        if childView then
            childView.x = x
            childView.width = childWidth
        end
        x = x + childWidth - (isPressable and 1 or 0) + ((not childView or (i < #items and not items[i + 1][1]) ) and 0 or SIDE_MARGIN)
    end

    self.height = contentHeight + 2 * TOP_MARGIN + 1 -- + 1 for separator

    self.needsLayoutUpdate = false
end
