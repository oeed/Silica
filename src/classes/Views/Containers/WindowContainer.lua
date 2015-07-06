
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

function WindowContainer:setHeight( height )
    self.super:setHeight( height )
    if self.hasInit then
    	self.backgroundObject.height = height
    end
end

function WindowContainer:setWidth( width )
    self.super:setWidth( width )
    if self.hasInit then
    	self.backgroundObject.width = width
    end
end
