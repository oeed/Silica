
class "WindowContainer" extends "Container" {
	backgroundObject = nil;
}

function WindowContainer:init(...)
	self.super:init(...)
end

function WindowContainer:initCanvas()
	self.canvas = WindowCanvas( self.x, self.y, self.width, self.height )
	self.backgroundObject = self.canvas:insert( Rectangle( 1, 1, self.width, self.height, Graphics.colours.WHITE ) )
end

function WindowContainer:setHeight( height )
    self.super:setHeight( height )
    self.backgroundObject.height = height
end

function WindowContainer:setWidth( width )
    self.super:setWidth( width )
    self.backgroundObject.width = width
end
