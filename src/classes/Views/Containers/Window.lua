
class "Window" extends "Container" {
	separatorObject = nil;	
	shadowObject = nil;
	barObject = nil;	
	barHeight = 7;

	container = nil;
    closeButton = nil;
    minimiseButton = nil;
    maximiseButton = nil;

	dragX = nil;
	dragY = nil;
    isDragging = false;
    isResizingX = false;
	isResizingY = false;
}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function Window:init( ... )
	self.super:init( ... )

    self.closeButton = self:insert( CloseWindowButton( { x = 1, y = 1 } ))
    self.minimiseButton = self:insert( MinimiseWindowButton( { x = 10, y = 1 } ))
    self.maximiseButton = self:insert( MaximiseWindowButton( { x = 19, y = 1 } ))
	self.container = self:insert( WindowContainer( { x = 1, y = self.barHeight + 2, width = self.width - 2, height = self.height - self.barHeight - 5 } ) )
    self:event( Event.MOUSE_DOWN, self.onMouseDown, EventManager.phase.AFTER )
    self.event:connectGlobal( Event.MOUSE_DRAG, self.onGlobalMouseDrag )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
    self:event( Event.INTERFACE_LOADED, self.onInterfaceLoaded )

    self.container:insert( Button( { x = 10, y = 10 } ) )
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Window:initCanvas()
    self.super:initCanvas()
	local barHeight = self.barHeight
    local shadowObject = self.canvas:insert( RoundedRectangle( 3, 4, self.width - 2, self.height - 3 ) )
    local barObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width - 2, barHeight ) )
    local separatorObject = self.canvas:insert( Rectangle( 1, barHeight + 1, self.width - 2, 1 ) )

    self.theme:connect( barObject, 'fillColour', 'barColour' )
    self.theme:connect( barObject, 'topRadius', 'topCornerRadius' )
    self.theme:connect( separatorObject, 'fillColour', 'separatorColour' )
    self.theme:connect( shadowObject, 'topRadius', 'topCornerRadius' )
    self.theme:connect( shadowObject, 'bottomRadius', 'bottomCornerRadius' )
    self.theme:connect( shadowObject, 'fillColour', 'shadowColour' )
    self.shadowObject = shadowObject
	self.barObject = barObject
	self.separatorObject = separatorObject
end

function Window:setHeight( height )
    self.super:setHeight( height )
    self.shadowObject.height = height - 3
    local container = self.container
    if container then container.height = height - self.barHeight - 5 end
end

function Window:setWidth( width )
    self.super:setWidth( width )
    self.shadowObject.width = width - 2
    self.barObject.width = width - 2
    self.separatorObject.width = width - 2
    local container = self.container
    if container then container.width = width - 2 end
end

function Window:onInterfaceLoaded( event )
    local currentContainer = self.container
    for i, childView in ipairs( self.children ) do
        if childView ~= currentContainer and childView:typeOf( WindowContainer ) then
            childView.x = 1
            childView.y = self.barHeight + 2
            childView.width = self.width - 2
            childView.height = self.height - self.barHeight - 5
            self:remove( self.container )
            self.container = childView
            break
        end
    end
end

function Window:updateThemeStyle()
    self.theme.style = self.isEnabled and "default" or "disabled"
end

--[[
    @instance
    @desc Fired when the mouse is pushed on the window bar. Starts dragging.
    @param [Event] event -- the mouse down event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Window:onMouseDown( event )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        x = event.x
        y = event.y
        local width = self.width
        local height = self.height
        local isResizingX = x >= width - 2
        local isResizingY = y >= height - 3
        self.isResizingX = isResizingX
        self.isResizingY = isResizingY
        self.isDragging = not ( isResizingX or isResizingY )
        self.dragX = isResizingX and width - x or x
        self.dragY = isResizingY and height - y or y
    end
    return true
end

--[[
    @instance
    @desc Fired when the mouse is dragged anywhere on screen. Moves the window if dragging
    @param [Event] event -- the mouse drag event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Window:onGlobalMouseDrag( event )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        if self.isDragging then
            self.x = event.x - self.dragX + 1
            self.y = event.y - self.dragY + 1
        else
            if self.isResizingX then
                self.width = event.x - self.x + self.dragX + 1
            end
            if self.isResizingY then
                self.height = event.y - self.y + self.dragY + 1
            end
        end
    end
    return true
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Stops dragging
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Window:onGlobalMouseUp( event )
    if (self.isDragging or self.isResizingX or self.isResizingY ) and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.dragX = nil
        self.dragY = nil
        self.isDragging = false
        self.isResizingX = false
        self.isResizingY = false
    end
end

function Window:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

--[[
    @instance
    @desc Closes the window, removing it from the screen
]]
function Window:close()
    self.isVisible = false
    self.parent:remove( self )
end