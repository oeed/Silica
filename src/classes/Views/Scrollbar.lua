
class "Scrollbar" extends "View" {
	width = Number( 7 );
    isHorizontal = Boolean( false );
	scrollerObject = false;
	grabberObject = false;
    dragPoint = false;
    direction = false;
    isPressed = Boolean( false );
}

function Scrollbar:initialise( ... )
	self:super( ... )
    -- self:event( MouseScrollEvent, self.onMouseScroll )
    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseDragEvent, self.onGlobalMouseDrag )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
end

--[[
    @desc Sets up the canvas and it's graphics objects
]]
function Scrollbar:initialiseCanvas()
    self:super()

    self.theme:connect( self.canvas, "fillColour" )

    local scrollerObject = self.canvas:insert( RoundedRectangle( 2, 3, self.width - 2, 30 ) )
    local grabberObject = self.canvas:insert( ScrollbarGrabber( 3, 3, self.width - 4, 30 ) )

    self.theme:connect( scrollerObject, "fillColour", "scrollerColour" )
    self.theme:connect( scrollerObject, "outlineColour" )
    self.theme:connect( scrollerObject, "radius", "cornerRadius" )
    self.theme:connect( grabberObject, "fillColour", "grabberColour" )

    local position, size = self.scroller
    -- local position, size = self:getScroller()
    self.scrollerObject = scrollerObject
    self.grabberObject = grabberObject
end

function Scrollbar:updateHeight( height )
    self:getScroller()
end

function Scrollbar:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function Scrollbar.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function Scrollbar.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

--[[
    @desc Gets and updates the size and location of the scroller
    @return [number] position -- the position of the scroller
    @return [number] size -- the size of the scroller
]]
function Scrollbar:getScroller( dontSetPosition )
    local parent = self.parent
    if not parent then
        return 0, self.direction == "vertical" and self.height or self.width
    end

    local trayMargin = 2
    local traySize = self.height - 2 * trayMargin

    local frameSize, contentSize, contentScroll
    frameSize = parent.height
    local container = parent.container
    contentSize = container.height
    contentScroll = - parent.offsetY


    local barSize = math.max( math.floor( traySize * frameSize / contentSize ), 1 )
    local barPosition = math.ceil( traySize * contentScroll / contentSize )

    local scrollerObject = self.scrollerObject
    local grabberObject = self.grabberObject
    scrollerObject.height = barSize
    grabberObject.height = barSize
    if not dontSetPosition then
        local y = 1 + trayMargin - barPosition
        scrollerObject.y = y
        grabberObject.y = y
    end

    return barPosition, barSize
end

--[[
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Scrollbar:onGlobalMouseUp( Event event, Event.phases phase )
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = false
    end
end

--[[
    @desc Fired when the mouse is pushed anywhere on screen. Adds the pressed appearance.
    @param [MouseDownEvent] event -- the mouse down event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Scrollbar:onMouseDown( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
        local position, size = self:getScroller( true )
        self.dragPoint = event.y + position - 1
    end
    return true
end

--[[
    @desc Fired when the mouse is dragged anywhere on screen. Moves the window if dragging
    @param [Event] event -- the mouse drag event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function Scrollbar:onGlobalMouseDrag( Event event, Event.phases phase )
    if self.isPressed and self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        local oldRelative = event.relativeView
        event:makeRelative( self )

        local position, size = self:getScroller( true )
        local traySize
        position = event.y - self.dragPoint
        traySize = self.height

        position = math.max( math.min( position, traySize - size ), 0 )
        local parent = self.parent
        -- parent.offsetY = math.floor( position / traySize * parent.container.height )
        -- scrollTo
        parent:scrollTo( math.floor( position / traySize * parent.container.height ) )
      
        event:makeRelative( oldRelative )
    end
end