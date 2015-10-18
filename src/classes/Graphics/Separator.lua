
class "Separator" extends "GraphicsObject" {
	fillColour = Graphics.colours.LIGHT_GREY;
	isDashed = true
}

function Separator:initialise( x, y, width, height, isDashed )
	self.super:initialise( x, y, width, height )
	
	if isDashed ~= nil then
		self.isDashed = isDashed
	end
end

--[[
    @instance
    @desc Gets the pixes to be filled
    @return [table] fill -- the pixels to fill
]]
function Separator:getFill()
	local fill = self.fill
	if fill then return fill end
	local isDashed, height = self.isDashed, self.height
	fill = {}
	for x = 1, self.width do
		local fillX = {}
		if not isDashed or x % 2 == 1 then
			for y = 1, height do
				if not isDashed or y % 2 == 1 then
					fillX[y] = true
				end
			end
		end
		fill[x] = fillX
	end

	self.fill = fill
	return fill
end
