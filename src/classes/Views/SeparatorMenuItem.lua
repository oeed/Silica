
class "SeparatorMenuItem" extends "MenuItem" {
	text = false;

	height = 3;
	width = 51;

	textColour = Graphics.colours.LIGHT_GREY;

    pressedTextColour = Graphics.colours.WHITE;

    disabledTextColour = Graphics.colours.LIGHT_GREY;

}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function SeparatorMenuItem:initialise( ... )
	self.super.super:initialise( ... )
end

function SeparatorMenuItem:initialiseCanvas()
	self.super.super:initialiseCanvas()
    self.backgroundObject = self.canvas:insert( Separator( 5, 2, self.width - 8, 1 ) )
end

function SeparatorMenuItem.isPressed:set( isPressed )
    self.isPressed = false
end

function SeparatorMenuItem:updateWidth( width )
	self.backgroundObject.width = width - 8
end

function SeparatorMenuItem:updateHeight( height )
	self.backgroundObject.height = 1
end
