
class "CircleRenderer" extends "FilledRenderer" {
	
}

function CircleRenderer:init( x, y, diameter )
	self.super:init( x, y, diameter, diameter )
end

function CircleRenderer:getRenderer()
	local renderer = FilledRenderer.getRenderer( self )
	renderer.diameter = self.diameter
	return renderer
end

function CircleRenderer:setDiameter( diameter )
	self.width = diameter
	self.height = diameter
end

function CircleRenderer:getDiameter( diameter )
	return math.min( self.width, self.height )
end

function CircleRenderer:getFill()
	if self.fillCache then return self.fillCache end

	local fill = {}
	local r = self.diameter / 2
	local radius = ( self.diameter + 1 ) / 2
	for y = 1, self.height do
		local ySqrd = ( y - radius )^2
		local fillY = {}
		for x = 1, self.width do
			local distance = ( ySqrd + ( x - radius )^2 )^0.5
			if distance <= r then
				fillY[x] = true
			end
		end
		fill[y] = fillY
	end
	self.fillCache = fill
	return fill
end
