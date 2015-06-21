
class "ScreenCanvas" extends "Canvas" {
	fillColour = Graphics.colours.WHITE;
	drawn = {};
}

--[[
	@instance
	@desc Draws the canvas to the terminal/screen provided
	@param [term] terminal -- the terminal object to draw to
	@return self
]]
function ScreenCanvas:drawToTerminal( terminal )
    if self.isVisible then
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
			local colour = self.fillColour or 1
			local width = self.width
			local height = self.height
			local drawn = self.drawn
			-- the blacked out corners. if theres a faster way to do this then feel free to change it
			local corner = { 
				[1]={ [1]=true, [2]=true, [3]=true, [4]=true, [height - 3]=true, [height - 2]=true, [height - 1]=true, [height]=true },
				[2]={ [1]=true, [2]=true, [height - 1]=true, [height]=true },
				[3]={ [1]=true, [height]=true },
				[4]={ [1]=true, [height]=true },
				[width - 3]={ [1]=true, [height]=true },
				[width - 2]={ [1]=true, [height]=true },
				[width - 1]={ [1]=true, [2]=true, [height - 1]=true, [height]=true },
				[width]={ [1]=true, [2]=true, [3]=true, [4]=true, [height - 3]=true, [height - 2]=true, [height - 1]=true, [height]=true },
			}
			for y = 1, self.height do
				currentY = y
				currentLength = 0
				currentColour = nil
				for x = 1, width do
					-- if x == width then print(corner[x])  print(corner[x][y]) end
					if not corner[x] or not corner[x][y] then
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
				end
				draw()
			end
		end
	end
	return self
end
