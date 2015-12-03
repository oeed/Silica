
class "StripeMask" extends "Mask" {

}

function StripeMask:initialise( Number x, Number y, Number width, Number height, Number offset, Number stripeWidth )
    local pixels = {}
    if stripeWidth <= 0 then
        for i = 1, width * height do
            pixels[i] = true
        end
    else
        for i = 1, width * height do
            local n = (i - 1) / width - offset
            pixels[i] = ( ( (i - 1) % width + n ) / stripeWidth ) % 2 < 1
        end
    end
    self:super( x, y, width, height, pixels )
end