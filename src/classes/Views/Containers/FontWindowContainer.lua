
class "FontWindowContainer" extends "WindowContainer" {

	backgroundObject = false;

}

function FontWindowContainer:initialiseCanvas()
	self.canvas = FontWindowCanvas( self.width, self.height )
	self.backgroundObject = self.canvas:insert( Rectangle( 1, 1, self.width, self.height, Graphics.colours.WHITE ) )
end