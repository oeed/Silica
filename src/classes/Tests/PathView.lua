
class "PathView" extends "View" {

    height = 100; -- the default height
    width = 100;

}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
-- function PathView:init( ... )
--     self.super:init( ... )
-- end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function PathView:initCanvas()
	self.canvas.fillColour = Graphics.colours.LIGHT_GREY

	local path = Path( 10, 10, self.width - 20, self.height - 20, Graphics.colours.BLUE)
	-- path:curveTo( 4, 3.5, 3, 1, 3, 3.5 - 1.25 )
	-- path:curveTo( 2, 6, 3, 3.5 + 1.25, 3, 5 )
	-- path:lineTo( 40, 20 )
	-- path:lineTo( 40, 40 )
	path:lineTo( 50, 20 )
	path:curveTo( 80, 60, 30, 40, 40, 50 )
	path:lineTo( 10, 80 )
	path:close()
	path.outlineColour = Graphics.colours.LIME
	self.canvas:insert( path )
end