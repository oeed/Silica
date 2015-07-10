
class "TestView" extends "View" {
	width = nil;
	height = nil;
}

function TestView:init( ... )
	self.super:init( ... )
end

function TestView:initCanvas( ... )
	self.super:initCanvas( ... )
	self.canvas.fillColour = Graphics.colours.RED
end

function TestView:setWidth( width )
	self.super:setWidth( width )
	log("width constraint: "..self.stringConstraints.width)
	log("setting width to " .. width)
end