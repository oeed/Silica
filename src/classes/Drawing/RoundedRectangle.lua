
class "RoundedRectangle" extends "GraphicsObject" {
	colour = colours.red;

	topLeftRadius = 1;
	topRightRadius = 1;
	bottomLeftRadius = 1;
	bottomRightRadius = 1;
}

--[[
	@static
	@desc Creates a rounded rectangle
	@param [number] x -- the x coordinate of the rectangle
	@param [number] y -- the y coordinate of the rectangle
	@param [number] width -- the width of the rectangle
	@param [number] height -- the height of the rectangle
	@param [number] topLeftRadius -- the radius of the corners. of the top of the next parameter is defined, or top left if all 4 are
	@param [number] topRightRadius -- the radius of the bottom corners or top right if all 4 are
	@param [number] bottomLeftRadius -- the radius of the bottom left corner
	@param [number] bottomRightRadius -- the radius of the bottom right corner
]]
function RoundedRectangle:init( x, y, width, height, colour, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius )
	self.super:init( x, y, width, height )
	self.colour = colour
	self.topLeftRadius = topLeftRadius or self.topLeftRadius
	self.topRightradius = topRightRadius or topLeftRadius
	self.bottomLeftRadius = bottomLeftRadius or (topRightRadius or topLeftRadius)
	self.bottomRightRadius = bottomRightRadius or (topRightRadius or topRightRadius)
end

--[[
    @instance
    @desc Draws the rectangle to the canvas
    @param [Canvas] canvas -- the canvas to draw to
]]
function RoundedRectangle:drawTo( canvas )
	local function cornerY( x, radius )
		local centreX = radius
		local centreY = radius
		return 2 * radius - math.floor( math.sqrt( radius^2 - centreX^2 + 2 * centreX * x - x^2 ) + centreY + 0.5 )
	end

	local colour = self.colour
	for x = self.x, self.x + self.width - 1 do
		local minY = cornerY( x, 6 )
		minY = minY ~= minY and 1 or minY
		for y = self.y + minY - 1, self.y + self.height - 1 do
			canvas:setPixel( x, y, self.colour )


		end
	end

	-- for x = self.x, self.x + self.width - 1 do
	-- 	for y = self.y, self.y + self.width - 1 do
	-- 		canvas:setPixel( x, y, self.colour )
	-- 	end
	-- end
end