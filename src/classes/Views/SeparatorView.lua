
class "SeparatorView" extends "View" {

    width = Number( 1 );
    height = Number( 1 );

}

function SeparatorView:onDraw()
    local width, height, theme, canvas, isPressed = self.width, self.height, self.theme
    self.canvas:fill( theme:value( "fillColour" ), theme:value( "isDashed" ) and SeparatorMask( 1, 1, width, height ) or RectangleMask( 1, 1, width, height ) )
end
