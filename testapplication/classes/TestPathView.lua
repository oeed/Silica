
class "TestPathView" extends "View" {
    
}

function TestPathView:onDraw()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas

    canvas:fill( colours.red )
end