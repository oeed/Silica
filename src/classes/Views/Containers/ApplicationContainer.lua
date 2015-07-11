
class "ApplicationContainer" extends "Container" {
	-- TODO: make this use a Constraint
	x = 1;
	y = 1;
	width = 310;
	height = 175;
	themeName = false;
}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function ApplicationContainer:init( ... )
	self.super:init( ... )
    self.theme:connect( self.canvas, "fillColour" )
    self:event( Event.MOUSE_DOWN, self.onMouseUp, EventManager.phase.AFTER )
end

function ApplicationContainer:initCanvas()
	local canvas = ScreenCanvas( self.x, self.y, self.width, self.height )
    self.canvas = canvas
end

--[[
	@instance
	@desc Returns the theme name, reverting to default if not defined
]]
function ApplicationContainer:getThemeName()
	return self.themeName or "default"
end

--[[
	@instance
	@desc Sets the container's theme based upon it's name
	@return [string] themeName -- the name of the theme
]]
function ApplicationContainer:setThemeName( themeName )
	self.themeName = themeName
	-- TODO: there might be a need to do this within Application so it doesn't set the theme when a container is initiailsed
	Theme.active = Theme( themeName )
end

function ApplicationContainer:draw()
	self.canvas:drawToTerminal()
end

--[[
    @instance
    @desc Fired when the mouse is released and doesn't hit anything else. Unfocuses the focused view, if any.
    @param [MouseDownEvent] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function ApplicationContainer:onMouseUp( event )
    self.application:clearFocus()
end