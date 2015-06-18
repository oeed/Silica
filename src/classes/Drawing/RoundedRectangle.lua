
class "RoundedRectangle" extends "GraphicsObject" {
	fillColour = Graphics.colours.RED;

	topRadius = 1;
	bottomRadius = 1;
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
function RoundedRectangle:init( x, y, width, height, fillColour, outlineColour, topRadius, bottomRadius )
	self.super:init( x, y, width, height )
	self.fillColour = fillColour or Graphics.colours.TRANSPARENT
	self.outlineColour = outlineColour or Graphics.colours.TRANSPARENT
	self.topRadius = topRadius
	self.bottomRadius = bottomRadius or topRadius
end

--[[
    @instance
    @desc Draws the rectangle to the canvas
    @param [Canvas] canvas -- the canvas to draw to
]]
function RoundedRectangle:getFill()
	local fill = {}
	local fillColour = self.fillColour
	local tr = self.topRadius
	local tradius = ( self.topRadius * 2 + 1 ) / 2
	local br = self.bottomRadius
	local bradius = ( self.bottomRadius * 2 + 1 ) / 2
	-- local _y = self.y - 1
	-- local _x = self.x - 1

	for y = 1, self.height do
		-- TODO: tidy this up
		fill[y] = {}
		if y <= tr then
			local ySqrd = ( y - tradius )^2
			for x = -tradius, tradius do
	     		local distance = ( ySqrd + ( x )^2 )^0.5
				if distance <= tr then
					if x < 0 then
						fill[y][x + tradius] = true
					else
						fill[y][x + self.width - tradius + 1] = true
					end
				end
	     	end

	     	for x = tr + 1, self.width - tr do
				fill[y][x] = true
	     	end
		elseif y > self.height - br then
			local ySqrd = ( y - self.height + 2 * br - bradius )^2
			for x = -bradius, bradius do
	     		local distance = ( ySqrd + ( x )^2 )^0.5
				if distance <= br then
					if x < 0 then
						fill[y][x + bradius] = true
					else
						fill[y][x + self.width - bradius + 1] = true
					end
				end
	     	end

	     	for x = tr + 1, self.width - tr do
				fill[y][x] = true
	     	end
	    else
	    	for x = 1, self.width do
				fill[y][x] = true
	     	end
		end
	end
	return fill
end