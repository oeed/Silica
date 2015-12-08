
class "PathMask" extends "Mask" {
    
}

function PathMask:initialise( Number x, Number y, Path path )
    local intersections = path:getIntersections()
    local pixels = {}
    local width, height = path.width, path.height

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