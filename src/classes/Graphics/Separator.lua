
class "Separator" extends "GraphicsObject" {
	fillColour = Graphics.colours.LIGHT_GREY;
}

function Separator:init( x, y, width, height )
	self.super:init( x, y, width, height )
end

--[[
    @instance
    @desc Gets the pixes to be filled
    @return [table] fill -- the pixels to fill
]]
function Separator:getFill()
	local fill = {}
	for x = 1, self.width do
		local fillX = {}
		if x % 2 == 1 then
			for y = 1, self.height do
				if y % 2 == 1 then
					fillX[y] = true
				end
			end
		end
		fill[x] = fillX
	end
	return fill
end
