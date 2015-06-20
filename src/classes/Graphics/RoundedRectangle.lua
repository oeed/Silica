
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
	@desc Sets the radius of both sides
	@param [number] radius -- the new radius
	@return [type] returnedValue -- description
]]
function RoundedRectangle:setRadius( radius )
	self.topRadius = radius
	self.bottomRadius = radius
end

--[[
    @instance
    @desc Gets the pixels to be filled
    @return [table] fill -- the pixels to fill
]]
function RoundedRectangle:getFill()
	-- print('get fill')
	if self.fill then return self.fill end
	-- print('and calc	')

	local fill = {}
	local fillColour = self.fillColour
	local tr = self.topRadius
	local tradius = ( self.topRadius * 2 + 1 ) / 2
	local br = self.bottomRadius
	local bradius = ( self.bottomRadius * 2 + 1 ) / 2
	-- local _y = self.y - 1
	-- local _x = self.x - 1

	for x = 1, self.width do
		-- TODO: tidy this up
		fill[x] = {}
		if x <= tr then
			local xSqrd = ( x - tradius )^2
			for y = -tradius, tradius do
	     		local distance = ( xSqrd + ( y )^2 )^0.5
				if distance <= tr then
					if y < 0 then
						fill[x][y + tradius] = true
					else
						fill[x][y + self.height - tradius + 1] = true
					end
				end
	     	end

	     	for y = tr + 1, self.height - tr do
				fill[x][y] = true
	     	end
		elseif x > self.width - br then
			local xSqrd = ( x - self.width + 2 * br - bradius )^2
			for y = -bradius, bradius do
	     		local distance = ( xSqrd + ( y )^2 )^0.5
				if distance <= br then
					if y < 0 then
						fill[x][y + bradius] = true
					else
						fill[x][y + self.height - bradius + 1] = true
					end
				end
	     	end

	     	for y = tr + 1, self.height - tr do
				fill[x][y] = true
	     	end
	    else
	    	for y = 1, self.height do
				fill[x][y] = true
	     	end
		end
	end
	self.fill = fill
	return fill
end