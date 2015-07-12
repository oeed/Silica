
class "WindowContainer" extends "Container" {
	backgroundObject = nil;
}

function WindowContainer:init( ... )
	self.super:init( ... )
end

function WindowContainer:initCanvas()
	self.canvas = WindowCanvas( self.x, self.y, self.width, self.height )
	self.backgroundObject = self.canvas:insert( Rectangle( 1, 1, self.width, self.height, Graphics.colours.WHITE ) )
end

function WindowContainer:updateHeight( height )
	self.backgroundObject.height = height
end

function WindowContainer:updateWidth( width )
	self.backgroundObject.width = width
end
