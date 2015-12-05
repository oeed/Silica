
local RESIZE_MARGIN_X, RESIZE_MARGIN_Y = 3, 4

class "Window" extends "Container" {

	container = false;
    closeButton = false;
    minimiseButton = false;
    maximiseButton = false;
    isEnabled = Boolean( false );

	dragX = false;
	dragY = false;
    isDragging = Boolean( false );
    isResizingX = Boolean( false );
	isResizingY = Boolean( false );

    minWidth = 60;
    minHeight = 40;
    maxWidth = 100;
    maxHeight = 150;

    isCanvasHitTested = Boolean( false );

}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function Window:initialise( ... )
	self:super( ... )
    self.closeButton = self:insert( CloseWindowButton( { x = 2, y = 1, window = self } ))
    self.minimiseButton = self:insert( MinimiseWindowButton( { x = 10, y = 1, window = self } ))
    self.maximiseButton = self:insert( MaximiseWindowButton( { x = 18, y = 1, window = self } ))

    self:loadInterface()
    
    self:event( MouseDownEvent, self.onMouseDownBefore, Event.phases.BEFORE )
    self:event( MouseDownEvent, self.onMouseDownAfter, Event.phases.AFTER )
    self.event:connectGlobal( MouseDragEvent, self.onGlobalMouseDrag )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
    self:event( LoadedInterfaceEvent, self.onInterfaceLoaded )
end

function Window:onDraw()
    local width, height, theme, canvas = self.width - RESIZE_MARGIN_X, self.height - RESIZE_MARGIN_Y, self.theme, self.canvas

    local barHeight = 10
    local topCornerRadius, bottomCornerRadius = theme:value( "topCornerRadius" ), theme:value( "bottomCornerRadius" )
    local barRoundedRectangle = RoundedRectangleMask( 1, 1, width, barHeight, topCornerRadius, topCornerRadius, 0, 0 )
    canvas:fill( theme:value( "barFillColour" ), barRoundedRectangle )
    canvas:outline( theme:value( "separatorColour" ), barRoundedRectangle, 0, 0, 0, theme:value( "separatorThickness" ) )

    local contentMask = RoundedRectangleMask( 1, 1 + barHeight, width, height - barHeight, 0, 0, bottomCornerRadius, bottomCornerRadius )
    canvas:fill(  theme:value( "fillColour" ), contentMask )
    local combinedMask = contentMask:add( barRoundedRectangle )
    canvas:outline(  theme:value( "outlineColour" ), combinedMask, theme:value( "outlineThickness" ) )

    self.shadowSize = theme:value( "shadowSize" )
    return combinedMask
end

--[[
    @desc Loads the interface specified by the self.interfaceName interface name
]]
function Window:loadInterface()
    local interfaceName = self.interfaceName
    if interfaceName then
        local container = Interface( interfaceName, WindowContainer ).container
        container.x = 1
        container.y = 11
        container.width = self.width - RESIZE_MARGIN_X
        container.height = self.height - RESIZE_MARGIN_Y
        self.container = self:insert( container )
    end
end

function Window.height:set( height )
    height = math.max( math.min( height, self.maxHeight ), self.minHeight )
    if self.height ~= height then
        self:super( height )
        local container = self.container
        if container then
            container.height = height - 10 - RESIZE_MARGIN_Y
        end
    end
end

function Window.width:set( width )
    width = math.max( math.min( width, self.maxWidth ), self.minWidth )
    if self.width ~= width then
        self:super( width )
        local container = self.container
        if container then
            container.width = width - RESIZE_MARGIN_X
        end
    end
end

function Window:onInterfaceLoaded( LoadedInterfaceEvent event, Event.phases phase )
    local currentContainer = self.container
    for i, childView in ipairs( self.children ) do
        if childView:typeOf( WindowContainer ) then
            if childView ~= currentContainer then
                childView.x = 1
                childView.y = 11
                childView.width = self.width - RESIZE_MARGIN_X
                childView.height = self.height - 10 - RESIZE_MARGIN_Y
                self.container = childView
            end
            return
        end
    end
    self.container = self:insert( WindowContainer( { x = x, y = y, width = width, height = height } ) )
end

function Window:updateThemeStyle()
    self.theme.style = self.isEnabled and "default" or "disabled"
end

function Window.isEnabled:set( isEnabled )
    self:super( isEnabled )
    self:updateThemeStyle()
end

--[[
    @desc Centres the window relative to it's parent (which should be the application container)
]]
function Window:centre()
    local parent = self.parent
    if parent then
        self.x = math.ceil( ( parent.width - self.width + RESIZE_MARGIN_X ) / 2 )
        self.y = math.ceil( ( parent.height - self.height + RESIZE_MARGIN_Y ) / 2 )
    end
end

Window:alias( Window.centre, "center" )

--[[
    @desc Focus on the window, bringing it to the front and enabling controls whilst unfocusing other windows
]]
function Window:focus()
    if not self.isEnabled then
        self.application:unfocusAll( Window )
        self.isEnabled = true
        self.parent:sendToFront( self )
        for i, sibling in ipairs( self:siblingsOfType( Window ) ) do
            sibling:unfocus()
        end
    end
end

--[[
    @desc Unfocus on the window, disabling controls
]]
function Window:unfocus()
    self.isEnabled = false
end

--[[
    @desc Fired when the mouse is pushed on the window bar before children have recieved the event. Makes the window front most and active
    @param [MouseDownEvent] event -- the mouse down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Window:onMouseDownBefore( MouseDownEvent event, Event.phases phase )
    self:focus()
end

--[[
    @desc Fired when the mouse is pushed on the window bar after children have recieved the event. Starts dragging.
    @param [MouseDownEvent] event -- the mouse down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Window:onMouseDownAfter( MouseDownEvent event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        x = event.x
        y = event.y
        local width = self.width
        local height = self.height
        local isResizingX = x >= width - 2 * RESIZE_MARGIN_X
        local isResizingY = y >= height - 2 * RESIZE_MARGIN_Y
        log(isResizingX)
        self.isResizingX = isResizingX
        self.isResizingY = isResizingY
        self.isDragging = not ( isResizingX or isResizingY )
        self.dragX = isResizingX and width - x or x
        self.dragY = isResizingY and height - y or y
    end
    return true
end

--[[
    @desc Fired when the mouse is dragged anywhere on screen. Moves the window if dragging
    @param [Event] event -- the mouse drag event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Window:onGlobalMouseDrag( MouseDragEvent event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        local preventPropagation = false
        if self.isDragging then
            self.x = event.x - self.dragX + 1
            self.y = event.y - self.dragY + 1
            preventPropagation = true
        else
            if self.isResizingX then
                self.width = event.x - self.x + self.dragX + 1
                preventPropagation = true
            end
            if self.isResizingY then
                self.height = event.y - self.y + self.dragY + 1
                preventPropagation = true
            end
        end
        return preventPropagation
    end
end

--[[
    @desc Fired when the mouse is released anywhere on screen. Stops dragging
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Window:onGlobalMouseUp( MouseUpEvent event, Event.phases phase )
    if (self.isDragging or self.isResizingX or self.isResizingY ) and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.dragX = false
        self.dragY = false
        self.isDragging = false
        self.isResizingX = false
        self.isResizingY = false
        return true
    end
end

--[[
    @desc Closes the window, removing it from the screen
]]
function Window:close()
    self.isVisible = false
    self.parent:remove( self )
end