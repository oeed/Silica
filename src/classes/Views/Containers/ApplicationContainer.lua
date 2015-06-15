
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
	self.canvas = ScreenCanvas( self.width or 1, self.height or 1 )
	local rectangle = self.canvas:insert( Rectangle( 6, 6, 40, 40, colours.red ) )
	-- self.canvas:draw()
end

function ApplicationContainer:draw()
	self.canvas:drawToTerminal()
end