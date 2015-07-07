
class "TestView" extends "View" {
	width = 40;
	height = 40;
}

function TestView:init( ... )
	self.super:init( ... )
end

function TestView:initConstraint()
	if not self.constraint then
    	self.constraint = Constraint( self, { right = "100%" } )
    end
end

function TestView:initCanvas( ... )
	self.super:initCanvas( ... )
	self.canvas.fillColour = Graphics.colours.RED
end