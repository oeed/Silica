
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
        -- look in FontWindowCanvas
        -- dman
    end
    return self
end
