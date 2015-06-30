
class "ScrollView" extends "Container" {
	contents = nil;
	horizontalScrollbar = nil;
	verticalScrollbar = nil;
	scrollSpeed = 10;
	verticalVelocity = 0;
	horizontalVelocity = 0;
}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function ScrollView:init( ... )
	self.super:init( ... )
	self.canvas.fillColour = Graphics.colours.WHITE

	local width, height = self.width, self.height
	self.verticalScrollbar = self:insert( Scrollbar( { isHorizontal = false, x = width - Scrollbar.width + 1, height = height } ) )
	self.container = self:insert( ScrollContainer( { x = 1, y = 1, width = width, height = height } ) )
    -- self:sendToFront( self.horizontalScrollbar )
    self:sendToFront( self.verticalScrollbar )

    self:event( Event.INTERFACE_LOADED, self.onInterfaceLoaded )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self:event( Event.MOUSE_SCROLL, self.onMouseScroll )
end

function ScrollView:onMouseDown( event )
	self.offsetY = 30
end

function ScrollView:onInterfaceLoaded( event )
    local currentContainer = self.container
    for i, childView in ipairs( self.children ) do
        if childView ~= currentContainer and childView:typeOf( ScrollContainer ) then
            childView.x = 1
            childView.y = 1
            self:remove( self.container )
            self.container = childView
            -- self:sendToFront( self.horizontalScrollbar )
            self:sendToFront( self.verticalScrollbar )
            break
        end
    end
end

function ScrollView:setWidth( width )
	self.super:setWidth( width )
	if self.hasInit then
		local verticalScrollbar = self.verticalScrollbar
		if verticalScrollbar then verticalScrollbar.x = width - verticalScrollbar.width + 1 end
	end
end

function ScrollView:setHeight( height )
	self.super:setHeight( height )
	if self.hasInit then
		local verticalScrollbar = self.verticalScrollbar
		if verticalScrollbar then self.verticalScrollbar.height = height end
	end
end

--[[
	@instance
	@desc Set vertical scroll offset of the contents
	@param [number] offsetY -- the vertical offset
]]
function ScrollView:setOffsetY( offsetY )
	local container = self.container
	if container then
		local height = self.height
		local realOffsetY = math.max( math.min( offsetY, math.max( container.height - height, 0 ) ), 1 )
		self.offsetY = realOffsetY
		-- container:animateY( -realOffsetY, 0.5, Animation.easing.EASE_OUT_CUBIC )
	end
end

function ScrollView:update( deltaTime )
	local verticalVelocity = self.verticalVelocity
	
end

--[[
	@instance
	@desc Scrolls the scroll view in the direction (and magnitude) given
	@param [MouseEvent.directions/number] direction -- the direction/distance to scroll
]]
function ScrollView:scroll( direction )
	self.offsetY = self.offsetY + direction
	-- TODO: horizontal scrolling
end

--[[
	@instance
	@desc Fired when the mouse is scrolled over the scroll view
	@param [Event] event -- the mouse scroll event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function ScrollView:onMouseScroll( event )
	if self.isEnabled then
		self:scroll( event.direction * self.scrollSpeed )
	end
	return true
end
