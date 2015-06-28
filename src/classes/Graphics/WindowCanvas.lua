
class "WindowCanvas" extends "Canvas" { }

-- function WindowCanvas:drawTo( ... )
--     if self.isVisible then
--         local hasChanged = self.hasChanged
--         self.super:drawTo( ... )
--         if hasChanged then
--         	self.
--         end
--     end
--     return self
-- end



function WindowCanvas:draw( ... )
    if self.isVisible then
    	self.super:draw( ... )
    	local y = self.height - 1
    	local width = self.width
    	local buffer = self.buffer
    	local transparent = Graphics.colours.TRANSPARENT
    	buffer[y * width + 1] = transparent
    	buffer[y * width + width] = transparent
    end
    return self
end
