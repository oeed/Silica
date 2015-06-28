
class "WindowContainer" extends "Container" {

}

function WindowContainer:init(...)
	self.super:init(...)
	self.canvas = WindowCanvas( self.x, self.y, self.width, self.height )
	self.canvas:insert( Rectangle( 1, 1, self.width, self.height, Graphics.colours.WHITE ) )
end