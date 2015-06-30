
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