
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
	topRadius = false;
	bottomRadius = false;
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
	self:super( x, y, width, height )
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
function RoundedRectangle.radius:set( radius )
	self.topLeftRadius = radius
	self.topRightRadius = radius
	self.bottomLeftRadius = radius
	self.bottomRightRadius = radius
end

function RoundedRectangle.topLeftRadius:set( topLeftRadius )
	if topLeftRadius then self.topLeftRadius = math.floor( topLeftRadius ) end
end

function RoundedRectangle.topRightRadius:set( topRightRadius )
	if topRightRadius then self.topRightRadius = math.floor( topRightRadius ) end
end

function RoundedRectangle.bottomLeftRadius:set( bottomLeftRadius )
	if bottomLeftRadius then self.bottomLeftRadius = math.floor( bottomLeftRadius ) end
end

function RoundedRectangle.bottomRightRadius:set( bottomRightRadius )
	if bottomRightRadius then self.bottomRightRadius = math.floor( bottomRightRadius ) end
end

function RoundedRectangle.leftRadius:set( leftRadius )
	if leftRadius then
		self.bottomLeftRadius = math.floor( leftRadius )
		self.topLeftRadius = math.floor( leftRadius )
	end
end

function RoundedRectangle.rightRadius:set( rightRadius )
	if rightRadius then
		self.bottomRightRadius = math.floor( rightRadius )
		self.topRightRadius = math.floor( rightRadius )
	end
end

function RoundedRectangle.topRadius:set( topRadius )
	if topRadius then
		self.topLeftRadius = math.floor( topRadius )
		self.topRightRadius = math.floor( topRadius )
	end
end

function RoundedRectangle.bottomRadius:set( bottomRadius )
	if bottomRadius then
		self.bottomLeftRadius = math.floor( bottomRadius )
		self.bottomRightRadius = math.floor( bottomRadius )
	end
end

function RoundedRectangle.radius:get()
	return math.max( self.topLeftRadius, self.topRightRadius, self.bottomLeftRadius, self.bottomRightRadius )
end

function RoundedRectangle.leftRadius:get()
	return math.max( self.topLeftRadius, self.bottomLeftRadius )
end

function RoundedRectangle.rightRadius:get()
	return math.max( self.topRightRadius, self.bottomRightRadius )
end

function RoundedRectangle.topRadius:get()
	return math.max( self.topLeftRadius, self.topRightRadius )
end

function RoundedRectangle.bottomRadius:get()
	return math.max( self.bottomLeftRadius, self.bottomRightRadius )
end


--[[
    @instance
    @desc Gets the pixels to be filled
    @return [table] fill -- the pixels to fill
]]
function RoundedRectangle.fill:get()
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
