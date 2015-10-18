
class "TestView" extends "View" {
	width = false;
	height = false;
}

function TestView:initialise( ... )
	self.super:initialise( ... )
end

function TestView:initialiseCanvas( ... )
	self.super:initialiseCanvas( ... )
	self.canvas.fillColour = Graphics.colours.RED
end

function TestView:setWidth( width )
	self.super:setWidth( width )
    width = self.width
end