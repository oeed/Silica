
class "PathMask" extends "Mask" {
    
}

function PathMask:initialise( Number x, Number y, Path path, Number( path.width ) width,  Number( path.height ) height )
    local pixels = {}
    local scaleX, scaleY = width / path.width, height / path.height
    local intersections = path:getIntersections( scaleX, scaleY )

    for y = 1, height do
        local yIntersections = intersections[y]
        for i = 1, #yIntersections, 2 do
            local x1, x2 = yIntersections[i], yIntersections[i + 1]
            for x = math.floor( x1 + 0.5), math.floor( x2 + 0.5 ) do
                pixels[(y - 1) * width + x] = true
            end
        end
    end

    -- for i = 1, width * height do
    --     pixels[i] = true
    -- end

    self:super( x, y, width, height, pixels )
end