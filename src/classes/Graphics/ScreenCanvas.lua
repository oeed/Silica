
class "ScreenCanvas" extends "Canvas" {
	fillColour = Graphics.colours.LIGHT_BLUE;
	drawn = {};
}

function ScreenCanvas.hasChanged:set( hasChanged )
	self.hasChanged = hasChanged
end

--[[
	@instance
	@desc Draws the canvas to the terminal/screen provided
	@param [term] terminal -- the terminal object to draw to
	@return self
]]
function ScreenCanvas:drawToTerminal( terminal )
    if self.isVisible then
		if self.hasChanged then
	        local s = os.clock()
			self:draw()
			terminal = terminal or term

			local currentLength, currentX, currentY, currentColour

			local sBC, sCP, w = term.setBackgroundColour, term.setCursorPos, term.write
			local function draw()
				if currentLength == 0 then return end
				sBC( currentColour )
				sCP( currentX, currentY )
				w( (" "):rep( currentLength ) )
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
			local cornerColour = Graphics.colours.BLACK
			for x, v in pairs( corner ) do -- ipairs won't do the [height-3] indexes, for example
				for y, v in pairs( v ) do
					buffer[ ( y - 1 ) * width + x ] = cornerColour
				end
			end
	        local blit = term.blit
	        local hexes = { 
	        	[2^0] = "0",
	        	[2^1] = "1",
	        	[2^2] = "2",
	        	[2^3] = "3",
	        	[2^4] = "4",
	        	[2^5] = "5",
	        	[2^6] = "6",
	        	[2^7] = "7",
	        	[2^8] = "8",
	        	[2^9] = "9",
	        	[2^10] = "a",
	        	[2^11] = "b",
	        	[2^12] = "c",
	        	[2^13] = "d",
	        	[2^14] = "e",
	        	[2^15] = "f"
	        }

			for y = 1, self.height do
				-- currentY = y
				-- currentLength = 0
				-- currentColour = nil
				-- for x = 1, width do
				-- 	local p = ( y - 1 ) * width + x
				-- 	local c = buffer[p] or colour
				-- 	if c ~= drawn[p] then
				-- 		drawn[p] = c
				-- 		if currentColour == c then
				-- 			currentLength = currentLength + 1
				-- 		else
				-- 			draw()
				-- 			currentLength = 1
				-- 			currentX = x
				-- 			currentColour = c
				-- 		end
				-- 	elseif currentLength ~= 0 then
				-- 		draw()
				-- 		currentLength = 0
				-- 		currentColour = nil
				-- 	else
				-- 		currentColour = nil
				-- 	end
				-- end
				-- draw()
				local changed = false
				local str = ""
				for x = 1, width do
					local p = ( y - 1 ) * width + x
					local c = buffer[p] or colour
					str = str .. hexes[c]
					if not changed and c ~= drawn[p] then
						changed = true
					end
				end
				if changed then
					log(y)
					log(str)
					term.setCursorPos(1,y)
					term.setBackgroundColour(8)
					blit("e"..str)
					sleep(0)
				end
			end
		end
	end
	return self
end
