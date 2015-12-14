
class "LineMask" extends "Mask" {

}

function LineMask:initialise( Number x, Number y, Number width, Number height, Boolean( true ) isFromTopLeft )
    local pixels = {}
    local xDiff = width - 1
    local yDiff = ( isFromTopLeft and height - 1 or -height + 1 )
    if xDiff > math.abs(yDiff) then
        local y = isFromTopLeft and 1 or height
        local dy = yDiff / xDiff
        for x = 1, width do
            pixels[( math.floor( y + 0.5 ) - 1 ) * width + x ] = true
            y = y + dy
        end
    else
        local x = isFromTopLeft and 1 or width
        local dx = xDiff / yDiff
        for y = 1, height do
            pixels[(y - 1) * width + math.floor( x + 0.5 ) ] = true
            x = x + dx
        end
    end

    self:super( x, y, width, height, pixels )
end