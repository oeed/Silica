
-- draws a corner with the given radius for the corner given
local function corner( fill, width, height, radius, position ) -- position is a byte. first bit is 0 if top, second bit is 0 if left
	if radius <= 0 then return end
	
	local minDistance = radius
	radius = radius + 0.5 -- doing this seems to magically make them look much better

	local centerX = (bit.band( position, 2 ) == 0) and radius or width - radius + 1
	local centerY = (bit.band( position, 1 ) == 0) and radius or height - radius + 1
	local minX = (bit.band( position, 2 ) == 0) and 1 or width - minDistance + 1
	local minY = (bit.band( position, 1 ) == 0) and 1 or height - minDistance + 1

	for x = minX, minX + radius - 1 do
		fill[x] = fill[x] or {}
		local xDistance = ( x - centerX ) ^ 2
		for y = minY, minY + radius - 1 do
			local distance = ( xDistance + ( y - centerY) ^ 2 ) ^ 0.5
			if distance <= minDistance then
				fill[x][y] = true
			end
		end
	end
end

class "RoundedRectangle" extends "GraphicsObject" {
	fillColour = Graphics.colours.RED;

	radius = false;
	leftRadius = false;
	rightRadius = false;
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
function RoundedRectangle:initialise( x, y, width, height, fillColour, outlineColour, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius )
	self.super:initialise( x, y, width, height )
	self.fillColour = fillColour or Graphics.colours.TRANSPARENT
	self.outlineColour = outlineColour or Graphics.colours.TRANSPARENT
	topLeftRadius = topLeftRadius or 0
	self.topLeftRadius = topLeftRadius
	self.topRightRadius = topRightRadius or topLeftRadius
	self.bottomLeftRadius = bottomLeftRadius or topRightRadius or topLeftRadius
	self.bottomRightRadius = bottomRightRadius or bottomLeftRadius or topRightRadius or topLeftRadius
end

--[[
	@instance
	@desc Sets the radius of both sides
	@param [number] radius -- the new radius
	@return [type] returnedValue -- description
]]
function RoundedRectangle:setRadius( radius )
	self.topLeftRadius = radius
	self.topRightRadius = radius
	self.bottomLeftRadius = radius
	self.bottomRightRadius = radius
end

function RoundedRectangle:setTopLeftRadius( radius )
	if radius then self.topLeftRadius = math.floor( radius ) end
end

function RoundedRectangle:setTopRightRadius( radius )
	if radius then self.topRightRadius = math.floor( radius ) end
end

function RoundedRectangle:setBottomLeftRadius( radius )
	if radius then self.bottomLeftRadius = math.floor( radius ) end
end

function RoundedRectangle:setBottomRightRadius( radius )
	if radius then self.bottomRightRadius = math.floor( radius ) end
end

function RoundedRectangle:setLeftRadius( radius )
	if radius then
		self.bottomLeftRadius = math.floor( radius )
		self.topLeftRadius = math.floor( radius )
	end
end

function RoundedRectangle:setRightRadius( radius )
	if radius then
		self.bottomRightRadius = math.floor( radius )
		self.topRightRadius = math.floor( radius )
	end
end

function RoundedRectangle:setTopRadius( radius )
	if radius then
		self.topLeftRadius = math.floor( radius )
		self.topRightRadius = math.floor( radius )
	end
end

function RoundedRectangle:setBottomRadius( radius )
	if radius then
		self.bottomLeftRadius = math.floor( radius )
		self.bottomRightRadius = math.floor( radius )
	end
end

function RoundedRectangle:getRadius( radius )
	return math.max( self.topLeftRadius, self.topRightRadius, self.bottomLeftRadius, self.bottomRightRadius )
end

function RoundedRectangle:getLeftRadius( radius )
	return math.max( self.topLeftRadius, self.bottomLeftRadius )
end

function RoundedRectangle:getRightRadius( radius )
	return math.max( self.topRightRadius, self.bottomRightRadius )
end

function RoundedRectangle:getTopRadius( radius )
	return math.max( self.topLeftRadius, self.topRightRadius )
end

function RoundedRectangle:getBottomRadius( radius )
	return math.max( self.bottomLeftRadius, self.bottomRightRadius )
end


--[[
    @instance
    @desc Gets the pixels to be filled
    @return [table] fill -- the pixels to fill
]]
function RoundedRectangle:getFill()
	if self.fill then return self.fill end
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

	local maxTopRadius = math.max( topLeftRadius, topRightRadius )
	for x = topLeftRadius, self.width - topRightRadius do
		fill[x] = fill[x] or {}
		for y = 1, maxTopRadius do
			fill[x][y] = true
		end
	end

	local maxBottomRadius = math.max( bottomLeftRadius, bottomRightRadius )
	for x = bottomLeftRadius, self.width - bottomRightRadius do
		fill[x] = fill[x] or {}
		for y = self.height - maxBottomRadius + 1, self.height do
			fill[x][y] = true
		end
	end

	for x = 1, self.width do
		fill[x] = fill[x] or {}
		for y = maxTopRadius + 1, self.height - maxBottomRadius do
			fill[x][y] = true
		end
	end

	self.fill = fill
	return fill
end
