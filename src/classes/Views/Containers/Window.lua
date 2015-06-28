
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
}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function Window:init( ... )
	self.super:init( ... )

    self.closeButton = self:insert( CloseWindowButton( { x = 4, y = 2 } ))
    self.minimiseButton = self:insert( MinimiseWindowButton( { x = 11, y = 2 } ))
    self.maximiseButton = self:insert( MaximiseWindowButton( { x = 18, y = 2 } ))
	self.container = self:insert( WindowContainer( { x = 1, y = self.barHeight + 2, width = self.width - 2, height = self.height - self.barHeight - 5 } ) )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_DRAG, self.onGlobalMouseDrag )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Window:initCanvas()
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
	self.barObject = barObject
	self.separatorObject = separatorObject
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
        self.isDragging = true
        self.dragX = event.x
        self.dragY = event.y
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
    if self.isDragging and self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.x = event.x - self.dragX + 1
        self.y = event.y - self.dragY + 1
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
    if self.isDragging and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.dragX = nil
        self.dragY = nil
        self.isDragging = false
    end
    return true
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