
class "TestView" extends "View" {
    
}

function TestView:onDraw()
    log( "test view drwa")
    local canvas = self.canvas
    canvas:fill( Graphics.colours.GREEN )
end