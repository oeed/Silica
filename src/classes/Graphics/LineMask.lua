
class "LineMask" extends "Mask" {

}

function LineMask:initialise( Number x, Number y, Number width, Number height, Boolean( true ) isFromTopLeft )
    local pixels = {}
    local i = 0
    for y = 1, height do
        if width > height then
            local y = minY
            for x = 1, width do
                pixels[(y - 1) * width + floor( 1 + (x - 1) / width * height + 0.5 )] = true
            end
        else
            local dx = ( height / width ) * inverseScaleX
            for y = minY, maxY, inverseScaleY do
                -- outline[floor( y * scaleY + 0.5 )][x1 + ( y - 1 ) / height * width] = true
            end
        end
    end

    self:super( x, y, width, height, pixels )
end