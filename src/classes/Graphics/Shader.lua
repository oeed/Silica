
class "Shader" extends "GraphicsObject" {
	fillColour = Graphics.colours.LIGHT_GREY;
}

function Shader:initialise( x, y, width, height, shader )
	self.super:initialise( x, y, width, height )
	self.shader = shader
end
--[[
    @instance
    @desc Draws a the graphics object to the canvas
    @param [Canvas] canvas -- the canvas to draw to
    @return self
]]
function Shader:drawTo( canvas, isShadow )
	if self.isVisible and ( not isShadow or ( isShadow and self.drawsShadow ) ) then
		canvas:map( self.shader, self.x, self.y, self.width, self.height )
	end
	
    return self
end