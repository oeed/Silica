
class "Rectangle" extends "GraphicsObject" {
	fillColour = Graphics.colours.LIGHT_GREY;
}

function Rectangle:initialise( x, y, width, height, fillColour ) -- @constructor( number x, number y, number width, number height, graphics.fillColour fillColour )
	self.super:initialise( x, y, width, height )
	self.fillColour = fillColour or false
end

--[[
    @instance
    @desc Gets the pixes to be filled
    @return [table] fill -- the pixels to fill
]]
function Rectangle:getFill()
	if self.fill then return self.fill end

	local fill = {}
	local height = self.height
	for x = 1, self.width do
		local fillX = {}
		for y = 1, height do
			fillX[y] = true
		end
		fill[x] = fillX
	end

	self.fill = fill
	return fill
end
