
class "ScreenCanvas" extends "Canvas" {
	colour = Graphics.colours.WHITE;
	drawn = {};
}

--[[
	@instance
	@desc Draws the canvas to the terminal/screen provided
	@param [term] terminal -- the terminal object to draw to
	@return self
]]
function ScreenCanvas:drawToTerminal( terminal )
	if self.hasChanged then
		self:draw()

		terminal = terminal or term

		local currentLength, currentX, currentY, currentColour
		local function draw()
			if currentLength == 0 then return end
			term.setBackgroundColour( currentColour )
			term.setCursorPos( currentX, currentY )
			term.write( (" "):rep( currentLength ) )
		end

		local buffer = self.buffer
		local colour = self.colour or 1
		local width = self.width
		local drawn = self.drawn
		for y = 1, self.height do
			currentY = y
			currentLength = 0
			currentColour = nil
			for x = 1, self.width do
				local p = ( y - 1 ) * width + x
				local c = buffer[p] or colour
				if c ~= drawn[p] then
					drawn[p] = c
					if currentColour == c then
						currentLength = currentLength + 1
					else
						draw()
						currentLength = 1
						currentX = x
						currentColour = c
					end
				elseif currentLength ~= 0 then
					draw()
					currentLength = 0
					currentColour = nil
				else
					currentColour = nil
				end
			end
			draw()
		end
	end
	return self
end
