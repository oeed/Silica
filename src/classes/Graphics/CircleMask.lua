
class "CircleMask" extends "Mask" {

}

function CircleMask:initialise( Number x, Number y, Number diameter )
    local pixels = {}

    local r = diameter / 2
    if r % 1 ~= 0 then
        r = r - 0.25
    end
    local radius = ( diameter + 1 ) / 2
    for y = 1, diameter do
        local ySqrd = ( y - radius )^2
        for x = 1, diameter do
            -- TODO: could probably make this faster by only square rooting once per y somehow
            local distance = ( ySqrd + ( x - radius )^2 )^0.5
            if distance <= r then
                pixels[(y - 1) * diameter + x] = true
            end
        end
    end

    self:super( x, y, diameter, diameter, pixels )
end