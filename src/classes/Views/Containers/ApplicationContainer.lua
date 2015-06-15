
class "ApplicationContainer" extends "Container" {
	-- TODO: make this use a Constraint
	x = 1;
	y = 1;
	width = 350;
	height = 170;
}

--[[
	@instance
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function ApplicationContainer:init( ... )
	self.super:init( ... )
	self.canvas = ScreenCanvas( self.x, self.y, self.width, self.height )
	self.canvas.colour = colours.lightBlue

	self:insert( Button( { x = 20; y = 20; } ) )
end

function ApplicationContainer:draw()
	self.canvas:drawToTerminal()
end