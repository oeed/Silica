
class "TestView" extends "View" {

}

function TestView:onDraw()
    local canvas = self.canvas
    canvas:fill( Graphics.colours.GREEN )
end