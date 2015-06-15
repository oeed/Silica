
class "Rectangle" extends "GraphicsObject" {
	colour = colours.red;
}

function Rectangle:init( x, y, width, height, colour ) -- @constructor( number x, number y, number width, number height, graphics.colour colour )
	self.super:init( x, y, width, height )
	self.colour = colour
end

--[[
    @instance
    @desc Draws the rectangle to the canvas
    @param [Canvas] canvas -- the canvas to draw to
]]
function Rectangle:drawTo( canvas )
	local colour = self.colour
	for x = self.x, self.x + self.width - 1 do
		for y = self.y, self.y + self.height - 1 do
			canvas:setPixel( x, y, colour )
		end
	end
end
