
class "ScrollbarGrabber" extends "GraphicsObject" {
	lines = 4;
}

--[[
    @instance
    @desc Gets the pixes to be filled
    @return [table] fill -- the pixels to fill
]]
function ScrollbarGrabber.fill:get()
	local height = self.height
	local width = self.width
	local lines = self.lines

	local fill = {}
	local startY = math.ceil( ( height - 2 * lines + 1 ) / 2 )
	for x = 1, width do
		fill[x] = fill[x] or {}
		for y = startY, startY + 2 * lines - 1, 2 do
			fill[x][y] = true
		end
	end

	return fill
end
