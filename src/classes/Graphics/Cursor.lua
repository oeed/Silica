
class "Cursor" extends "GraphicsObject" {
	fillColour = Graphics.colours.BLACK;
}

function Cursor:init( x, y, height )
	self.super:init( x, y, 1, height )
end

--[[
    @instance
    @desc Gets the pixes to be filled
    @return [table] fill -- the pixels to fill
]]
function Cursor:getFill()
	if self.fill then return self.fill end
	local fill = {}
	local fillX = {}
	for y = 1, self.height do
		fillX[y] = true
	end
	fill[1] = fillX
	return fill
end
