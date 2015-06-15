
class "Rectangle" extends "GraphicsObject" {
	colour = colours.red;
}

function Rectangle:init( x, y, width, height, colour ) -- @constructor( number x, number y, number width, number height, graphics.colour colour )
	self.super.init( self, x, y, width, height )
	self.colour = colour
end

function Rectangle:drawTo( object )
	for x = self.x, self.x + self.width - 1 do
		for y = self.y, self.y + self.width - 1 do
			object:setPixel( x, y, self.colour )
		end
	end
end
