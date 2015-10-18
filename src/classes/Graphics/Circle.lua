
class "Circle" extends "GraphicsObject" {}

--[[
	@static
	@desc Creates a cricle 
	@param [number] x -- the x coordinate of the circle
	@param [number] y -- the y coordinate of the circle
	@param [number] diameter -- the diameter of the circle
]]
function Circle:initialise( x, y, diameter )
	self.super:initialise( x, y, diameter, diameter )
end

--[[
	@instance
	@desc Sets the diamater of the circle
	@param [number] diameter -- the diameter of the circle
]]
function Circle:setDiameter( diameter )
	self.width = diameter
	self.height = diameter
end

--[[
	@instance
	@desc Gets the diameter of the circle
	@return [number] diameter -- the diameter
]]
function Circle:getDiameter( arg1, arg2, arg3 )
	return self.height
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
