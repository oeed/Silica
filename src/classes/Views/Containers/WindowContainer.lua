
class "WindowContainer" extends "Container" {
	backgroundObject = false;
}

function WindowContainer:initialise( ... )
	self.super:initialise( ... )
end

function WindowContainer:initialiseCanvas()
	self.canvas = WindowCanvas( self.x, self.y, self.width, self.height )
	self.backgroundObject = self.canvas:insert( Rectangle( 1, 1, self.width, self.height, Graphics.colours.WHITE ) )
end

function WindowContainer:updateHeight( height )
	self.backgroundObject.height = height
end

function WindowContainer:updateWidth( width )
	self.backgroundObject.width = width
end
