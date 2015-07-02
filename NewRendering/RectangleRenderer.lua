
class "RectangleRenderer" extends "FilledRenderer" {
	
}

function RectangleRenderer:getFill()
	if self.fillCache then return self.fillCache end
	local fill = {}
	local width = self.width
	for y = 1, self.height do
		local fillY = {}
		for x = 1, width do
			fillY[x] = true
		end
		fill[y] = fillY
	end
	return fill
end
