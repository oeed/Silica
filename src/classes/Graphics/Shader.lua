
class "Shader" extends "GraphicsObject" {
	fillColour = Graphics.colours.LIGHT_GREY;
}

function Shader:init( x, y, width, height, shader )
	self.super:init( x, y, width, height )
	self.shader = shader
end
--[[
    @instance
    @desc Draws a the graphics object to the canvas
    @param [Canvas] canvas -- the canvas to draw to
    @return self
]]
function Shader:drawTo( canvas )
	if self.isVisible then
		canvas:map( self.shader, self.x, self.y, self.width, self.height )
	end
	
    return self
end