
class "SeparatorMenuItem" extends "MenuItem" {

	height = Number( 3 );
	width = Number( 51 );

}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function SeparatorMenuItem:initialise( ... )
	self.super:super( ... ) -- by pass the normal menuitem's event connecting, we don't need to get any events
end

function SeparatorMenuItem:onDraw()
    local width, height, theme, canvas, isPressed = self.width, self.height, self.theme
    canvas:fill( theme:value( "fillColour" ) )
    local leftMargin = theme:value( "leftMargin" )
    local separatorX, separatorY, separatorWidth = 1 + leftMargin, 1 + theme:value( "topMargin" ), width - leftMargin - theme:value( "rightMargin" )
    self.canvas:fill( theme:value( "separatorColour" ), theme:value( "isDashed" ) and SeparatorMask( separatorX, separatorY, separatorWidth, 1 ) or RectangleMask( separatorX, separatorY, separatorWidth, 1 ) )
end

end
