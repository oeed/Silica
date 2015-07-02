
local floor = math.floor
local max = math.max

-- draws a corner with the given radius for the corner given
local function corner( fill, width, height, radius, position ) -- position is a byte. first bit is 0 if top, second bit is 0 if left
	if radius <= 0 then return end
	
	local minDistance = radius
	local radius2 = radius ^ 2
	radius = radius + 0.5 -- doing this seems to magically make them look much better

	local top = position == 0 or position == 1
	local left = position == 1 or position == 3
	local centerX = left and radius or width - radius + 1
	local centerY = top and radius or height - radius + 1
	local minX = left and 1 or width - minDistance + 1
	local minY = top and 1 or height - minDistance + 1

	for y = minY, minY + radius - 1 do
		local fillY = fill[y] or {}
		for x = minX, minX + radius - 1 do
			local distance = ( x - centerX ) ^ 2 + ( y - centerY ) ^ 2
			if distance <= radius2 then
				fillY[x] = true
			end
		end
		fill[y] = fillY
	end
end

class "RoundedRectangleRenderer" extends "FilledRenderer" {
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
function RoundedRectangleRenderer:init( x, y, width, height, tlRadius, trRadius, blRadius, brRadius )
	self.super:init( x, y, width, height )
	topLeftRadius = topLeftRadius or 0
	self.topLeftRadius = tlRadius
	self.topRightRadius = trRadius or tlRadius
	self.bottomLeftRadius = blRadius or trRadius or tlRadius
	self.bottomRightRadius = brRadius or blRadius or trRadius or tlRadius
end

--[[
	@instance
	@desc Sets the radius of both sides
	@param [number] radius -- the new radius
	@return [type] returnedValue -- description
]]
function RoundedRectangleRenderer:setRadius( radius )
	self.topLeftRadius = radius
	self.topRightRadius = radius
	self.bottomLeftRadius = radius
	self.bottomRightRadius = radius
end

function RoundedRectangleRenderer:setTopLeftRadius( radius )
	if radius then self.topLeftRadius = floor( radius ) end
	self.fillcache = nil
end

function RoundedRectangleRenderer:setTopRightRadius( radius )
	if radius then self.topRightRadius = floor( radius ) end
	self.fillcache = nil
end

function RoundedRectangleRenderer:setBottomLeftRadius( radius )
	if radius then self.bottomLeftRadius = floor( radius ) end
	self.fillcache = nil
end

function RoundedRectangleRenderer:setBottomRightRadius( radius )
	if radius then self.bottomRightRadius = floor( radius ) end
	self.fillcache = nil
end

function RoundedRectangleRenderer:setLeftRadius( radius )
	self.bottomLeftRadius = floor( radius )
	self.topLeftRadius = floor( radius )
end

function RoundedRectangleRenderer:setRightRadius( radius )
	self.bottomRightRadius = floor( radius )
	self.topRightRadius = floor( radius )
end

function RoundedRectangleRenderer:setTopRadius( radius )
	self.topLeftRadius = floor( radius )
	self.topRightRadius = floor( radius )
end

function RoundedRectangleRenderer:setBottomRadius( radius )
	self.bottomLeftRadius = floor( radius )
	self.bottomRightRadius = floor( radius )
end

function RoundedRectangleRenderer:getRadius( radius )
	return max( self.topLeftRadius, self.topRightRadius, self.bottomLeftRadius, self.bottomRightRadius )
end

function RoundedRectangleRenderer:getLeftRadius( radius )
	return max( self.topLeftRadius, self.bottomLeftRadius )
end

function RoundedRectangleRenderer:getRightRadius( radius )
	return max( self.topRightRadius, self.bottomRightRadius )
end

function RoundedRectangleRenderer:getTopRadius( radius )
	return max( self.topLeftRadius, self.topRightRadius )
end

function RoundedRectangleRenderer:getBottomRadius( radius )
	return max( self.bottomLeftRadius, self.bottomRightRadius )
end


--[[
    @instance
    @desc Gets the pixels to be filled
    @return [table] fill -- the pixels to fill
]]
function RoundedRectangleRenderer:getFill()
	if self.fillcache then return self.fillcache end

	local fill = {}

	local topLeftRadius = self.topLeftRadius
	local topRightRadius = self.topRightRadius
	local bottomLeftRadius = self.bottomLeftRadius
	local bottomRightRadius = self.bottomRightRadius

	local width, height = self.width, self.height

	corner( fill, width, height, topLeftRadius, 0 )
	corner( fill, width, height, topRightRadius, 2 )
	corner( fill, width, height, bottomLeftRadius, 1 )
	corner( fill, width, height, bottomRightRadius, 3 )

	local maxTopRadius = max( topLeftRadius, topRightRadius )
	for y = 1, maxTopRadius do
		fill[y] = fill[y] or {}
		for x = topLeftRadius, width - topRightRadius do
			fill[y][x] = true
		end
	end

	local maxBottomRadius = max( bottomLeftRadius, bottomRightRadius )
	for y = height - maxBottomRadius + 1, height do
		fill[y] = fill[y] or {}
		for x = bottomLeftRadius, width - bottomRightRadius do
			fill[y][x] = true
		end
	end

	for y = maxTopRadius + 1, height - maxBottomRadius do
		fill[y] = fill[y] or {}
		for x = 1, width do
			fill[y][x] = true
		end
	end

	self.fillcache = fill
	return fill
end
