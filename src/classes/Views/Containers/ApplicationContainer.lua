
class "ApplicationContainer" extends "Container" {
	-- TODO: make this use a Constraint
	x = 1;
	y = 1;
	width = 310;
	height = 175;
}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function ApplicationContainer:init( ... )
	self.super:init( ... )

    self:event( Event.MOUSE_DOWN, self.onMouseUp, EventManager.phase.AFTER )
end

function ApplicationContainer:initCanvas()
	self.canvas = ScreenCanvas( self.x, self.y, self.width, self.height )
end

--[[
	@instance
	@desc Sets the background/default colour of the application. Default is white.
	@param [Graphics.colours] fillColour -- the fill colour
]]
function ApplicationContainer:setFillColour( fillColour )
	self.canvas.fillColour = fillColour
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