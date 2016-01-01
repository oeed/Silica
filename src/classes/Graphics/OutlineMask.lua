
class OutlineMask extends Mask {

}

function OutlineMask:initialise( Number x, Number y, Number width, Number height, Number( 1 ) leftThickness, Number( leftThickness ) topThickness, Number( leftThickness ) rightThickness, Number( topThickness ) bottomThickness )
    local pixels = {}
    local i = 0
    for y = 1, height do
        for x = 1, width do
            i = i + 1
            pixels[i] = ( y <= topThickness or y > height - bottomThickness or x <= leftThickness or x > width - rightThickness ) or nil
        end
    end

    self:super( x, y, width, height, pixels )
end