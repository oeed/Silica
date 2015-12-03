
class "RectangleMask" extends "Mask" {

    

}

function RectangleMask:initialise( Number x, Number y, Number width, Number height )
    local pixels = {}
    for i = 1, width * height do
        pixels[i] = true
    end

    self:super( x, y, width, height, pixels )
end