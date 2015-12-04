
class "OutlineMask" extends "Mask" {

}

function OutlineMask:initialise( Number x, Number y, Number width, Number height )
    local pixels = {}
    local i = 0
    for y = 1, height do
        for x = 1, width do
            i = i + 1
            pixels[i] = ( y == 1 or y == height or x == 1 or x == width ) or nil
        end
    end

    self:super( x, y, width, height, pixels )
end