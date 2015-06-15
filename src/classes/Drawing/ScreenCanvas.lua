
class "ScreenCanvas" extends "Canvas"

--[[
	@instance
	@desc Draws the canvas to the terminal/screen provided
	@param [term] terminal -- the terminal object to draw to
	@return self
]]
function ScreenCanvas:drawToTerminal( terminal )
	if self.hasChanged then
		self:draw()
	end
	terminal = terminal or term
	for y = 1, self.height do
		terminal.setCursorPos( self.x, self.y + y - 1 )
		for x = 1, self.width do
			terminal.setBackgroundColour( self:getPixel( x, y ) )
			terminal.write " "
		end
	end
	return self
end
