
class "LineMask" extends "Mask" {

}

function LineMask:initialise( Number x, Number y, Number width, Number height, Boolean( true ) isFromTopLeft )
    local pixels = {}
    local i = 0
    local slope = height / width
    if height > width then
        for y = 1, height do
            pixels[(y - 1) * width + math.floor( y / slope + 0.5)] = true
        end
    else
        for x = 1, width do
            pixels[(math.floor(slope * x + 0.5) - 1) * width + x] = true
        end
    end

    self:super( x, y, width, height, pixels )
end