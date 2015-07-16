
class "Circle" extends "GraphicsObject" {}

--[[
	@static
	@desc Creates a rounded rectangle
	@param [number] x -- the x coordinate of the rectangle
	@param [number] y -- the y coordinate of the rectangle
	@param [number] width -- the width of the rectangle
	@param [number] height -- the height of the rectangle
	@param [number] radius -- the radius of the corners. of the top of the next parameter is defined, or top left if all 4 are
]]
function Circle:initialise( x, y, diameter )
	self.super:initialise( x, y, diameter, diameter )
end

--[[
    @instance
    @desc Gets the pixes to be filled
    @return [table] fill -- the pixels to fill
]]
function Circle:getFill()
	-- TODO: why is this commented out?
	-- if self.fill then return self.fill end

	local fill = {}
	local fillColour = self.fillColour
	local r = math.min( self.width, self.height ) / 2
	local radius = ( math.min( self.width, self.height ) + 1 ) / 2
	for y = 1, self.height do
		local ySqrd = ( y - radius )^2
		for x = 1, self.width do
			-- TODO: could probably make this faster by only square rooting once per y
     		local distance = ( ySqrd + ( x - radius )^2 )^0.5
			if distance <= r then
				fill[x] = fill[x] or {}
				fill[x][y] = true
			end
		end
	end
	return fill
end
