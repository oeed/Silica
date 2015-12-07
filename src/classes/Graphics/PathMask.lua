
class "PathMask" {
    
}

function PathMask:initialise( Number x, Number y, Path path )
    local pixels = {}
    for i = 1, width * height do
        pixels[i] = true
    end

    self:super( x, y, width, height, pixels )
end
