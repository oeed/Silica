
class "ApplicationContainer" extends "Container" {
	-- TODO: make this use a Constraint
	x = 1;
	y = 1;
	width = 350;
	height = 170;
}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function ApplicationContainer:init( ... )
	self.super:init( ... )
	self.canvas = ScreenCanvas( self.x, self.y, self.width, self.height )

	self:insert( Button( { x = 20; y = 30; } ) )
	self:insert( Checkbox( { x = 20; y = 10; } ) )
end

function ApplicationContainer:draw()
	self.canvas:drawToTerminal()
end