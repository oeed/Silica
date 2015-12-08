
local sin, cos, floor, min, max, abs, acos, PI, remove = math.sin, math.cos, math.floor, math.min, math.max, math.abs, math.acos, math.pi, table.remove

local function round( num )
    return floor( num + 0.5 )
end

-- the next few functions are just taken from a site for bezier intersection, hence the terribly named variables. don't hate.
local function sgn( n )
    return n < 0 and -1 or 1
end

local function sortSpecial( a )
    local flip;
    local temp;
    
    repeat
        flip = false
        for i = 1, #a - 1 do
            if ( a[i+1] >= 0 and a[i] > a[i+1] ) or ( a[i] < 0 and a[i+1] >= 0 ) then
                flip = true
                temp = a[i]
                a[i] = a[i+1]
                a[i+1] = temp
            end
        end
    until not flip

    return a
end

local function bezierCoeffs( P0, P1, P2, P3 )
    local Z = {};
    Z[1] = -P0 + 3 * P1 + -3 * P2 + P3; 
    Z[2] = 3 * P0 - 6 * P1 + 3 * P2;
    Z[3] = -3 * P0 + 3 * P1;
    Z[4] = P0;
    return Z;
end

local function cubicRoots( P )

    local a = P[1]
    local b = P[2]
    local c = P[3]
    local d = P[4]
    
    local A = b / a
    local B = c / a
    local C = d / a

    local Q, R, D, S, T, Im -- ehm?

    local Q = ( 3 * B - A ^ 2 )/9;
    local R = ( 9 * A * B - 27 * C - 2 * A ^ 3 ) / 54;
    local D = Q ^ 3 + R ^ 2;    -- polynomial discriminant

    local t = {}
    
    if D >= 0 then -- complex or duplicate roots
        local v1, v2, third = R + D^.5, R - D^.5, 1 / 3
        local T = sgn( v1 ) * abs( v1 ) ^ third
        local S = sgn( v2 ) * abs( v2 ) ^ third

        t[1] = A / -3 + ( S + T ) -- real root
        t[2] = A / -3 - ( S + T ) / 2 -- real part of complex root
        t[3] = A / -3 - ( S + T ) / 2 -- real part of complex root
        local Im = abs( 3^.5 * ( S - T ) / 2 ) -- complex part of root pair   
        
        if Im ~= 0 then
            t[2]=-1
            t[3]=-1
        end
    else -- distinct real roots
        local th = acos( R / (-( Q^3) )^.5 )
        
        t[1] = 2 * ( -Q )^.5 * cos( th / 3 ) - A / 3
        t[2] = 2 * ( -Q )^.5 * cos( ( th + 2 * PI ) / 3 ) - A / 3
        t[3] = 2 * ( -Q )^.5 * cos( ( th + 4 * PI ) / 3 ) - A / 3
        local Im = 0.0
    end
    
    -- discard out of spec roots
    for i = 1, 3 do
        if t[i] < 0 or t[i] > 1 then
            t[i] = -1
        end
    end
                
    -- sort but place -1 at the end
    t = sortSpecial( t );
    
    return t;
end

class "Path" {
    
    lines = Table( {} );
    isClosed = Boolean( false );
    width = Number;
    height = Number;
    currentX = Number;
    currentY = Number;
    outlineCache = Table( {} ); -- { [scale] = {} } where scale is the scale multiplier (i.e. 1)
    fillCache = Table( {} ); -- { [scale] = {} } where scale is the scale multiplier (i.e. 1)
    serialisedPath = Table.allowsNil;

}

--[[
    @constructor
    @desc Creates the start of a path
    @param [number] x -- the x coordinate
    @param [number] y -- the y coordinate
    @param [number] width -- the starting y coordinate
    @param [number] height -- the starting y coordinate
    @param [number] currentX -- the starting x coordinate
    @param [number] currentY -- the starting y coordinate
]]
function Path:initialise( Number width, Number height, Number( 1 ) currentX, Number( 1 ) currentY, Table.allowsNil lines )
    self.width = width
    self.height = height
    self.currentX = currentX
    self.currentY = currentY
    if lines then
        self.lines = lines
        self.closed = true
    end
end

--[[
    @static
    @desc Loads a path from a serialised path
    @param [table] serialisedPath -- the serialised path table
    @return [Path] path -- the path
]]
function Path.static:fromSerialisedPath( serialisedPath )
    return Path( serialisedPath.x, serialisedPath.y, serialisedPath.width, serialisedPath.height, 1, 1, serialisedPath.lines )
end

--[[
    @instance
    @desc Returns a serialised copy of the path which can be used to load from later
    @return [table] path -- the copied path table
]]
function Path.serialisedPath:get()
    local lines, pathCopy = self.lines, { x = self.x, y = self.y, width = self.width, height = self.height, lines = {} }
    local linesCopy = pathCopy.lines

    for i, line in ipairs( lines ) do
        local lineCopy = {}
        for k, v in pairs( line ) do
            lineCopy[k] = v
        end
        linesCopy[i] = lineCopy
    end

    return pathCopy
end

--[[
    @instance
    @desc Adds a straight line from the current position to the specified position
    @param [number] x -- the x coordinate to add a line to
    @param [number] y -- the y coordinate to add a line to
    @return [boolean] didAdd -- whether the line was added
]]
function Path:lineTo( x, y )
    if self.isClosed or not x or not y or (x == self.currentX and y == self.currentY) then return false end
    local lines = self.lines
    lines[#lines + 1] = {
        mode = "linear";
        x1 = self.currentX;
        y1 = self.currentY;
        x2 = x;
        y2 = y;
    }
    self.currentX = x
    self.currentY = y
    --[[
    local pointsTable = self.points
    pointsTable[#pointsTable + 1] = false
    pointsTable[#pointsTable + 1] = false
    pointsTable[#pointsTable + 1] = { x, y }
    ]]
    return true
end

--[[
    @instance
    @desc Create a bezier curve from current position to the specified position
    @param [number] endX -- the x coordinate to create the curve to
    @param [number] endY -- the y coordinate to create the curve to
    @param [number] controlPoint1X -- the x coodinate of the first control point (for the current position)
    @param [number] controlPoint1Y -- the y coodinate of the first control point (for the current position)
    @param [number] controlPoint2X -- the x coodinate of the first control point
    @param [number] controlPoint2Y -- the y coodinate of the first control point
    @return [boolean] didAdd -- whether the line was added
]]
function Path:curveTo( endX, endY, controlPoint1X, controlPoint1Y, controlPoint2X, controlPoint2Y )
    if self.isClosed or not endX or not endY or not controlPoint1X or not controlPoint1Y or not controlPoint2X or not controlPoint2Y then return false end
    
    self.lines[#self.lines + 1] = {
        mode = "curve";
        x1 = self.currentX;
        y1 = self.currentY;
        x2 = endX;
        y2 = endY;
        controlPoint1X = controlPoint1X;
        controlPoint1Y = controlPoint1Y;
        controlPoint2X = controlPoint2X;
        controlPoint2Y = controlPoint2Y;
    }

    self.currentX = endX
    self.currentY = endY
    return true
end

--[[
    @desc Moves the active cordinates (where the next path will go from)
]]
function Path:moveTo( Number x, Number y )
    self.currentX = x
    self.currentY = x
end

--[[
    @instance
    @desc Adds an arc at the current position
    @param [number] startAngle -- the angle to start (in radians)
    @param [number] endAngle -- the angle to end (in radians)
    @param [number] radius -- the radius
    @return [boolean] didAdd -- whether the line was added
]]

function Path:arc( startAngle, endAngle, radius )
    if self.isClosed then return false end

    local lines = self.lines

    local currentX, currentY = self.currentX, self.currentY
    local centreX, centreY = currentX - sin( startAngle ) * radius, currentY + cos( startAngle ) * radius

    local length = endAngle - startAngle
    local segments = floor( radius * abs( length ) * PI + .5 )

    for i = 0, segments do
        local angle = startAngle + length * i / segments
        local x, y = centreX + sin( angle ) * radius, centreY - cos( angle ) * radius

        lines[#lines + 1] = {
            mode = "linear";
            x1 = currentX;
            y1 = currentY;
            x2 = x;
            y2 = y;
        }

        currentX, currentY = x, y
    end

    self.currentX, self.currentY = currentX, currentY

    return true
end

--[[
    @instance
    @desc Closes the path (i.e. makes the end meet the start), making it immutable and drawable
    @return [boolean] didClose -- whether the path was closed
]]
function Path:close( linkedToEnd )
    linkedToEnd = (linkedToEnd == nil) and true or false
    if self.isClosed then return false end

    local lines = self.lines
    if #lines == 0 then
        error( "Path has no lines!", 2 )
    end
    if linkedToEnd and (lines[1].x1 ~= lines[#lines].x2 or lines[1].y1 ~= lines[#lines].y2) then
        self:lineTo( lines[1].x1, lines[1].y1 )
    end

    self.isClosed = true
    return true
end

local ERROR_MARGIN = 0.001
local function aproxEqual( n1, n2 )
    return n2 and ( n1 == n2 or ( n1 + ERROR_MARGIN > n2 and n1 - ERROR_MARGIN < n2 ) )
end

function Path:getIntersections( Number( 1 ) scaleX, Number( 1 ) scaleY )
    local intersections = {}
    local lines, height = self.lines, self.height

    local inverseScale = 1 / scaleY
    for y = 1, height, inverseScale do
        intersections[y * scaleY] = {}
    end

    local coefficients = {}
    local lastYs = {}
    for i, line in ipairs( lines ) do
        if line.mode == "linear" then
            lastYs[i] = line.y1
        else
            local xCoefficients = bezierCoeffs( line.x1, line.controlPoint1X, line.controlPoint2X, line.x2 )
            coefficients[i] = {
                xCoefficients,
                bezierCoeffs( line.y1, line.controlPoint1Y, line.controlPoint2Y, line.y2 )
            }

            local t = 1 - ERROR_MARGIN
            lastYs[i] = xCoefficients[1] * t * t * t + xCoefficients[2] * t * t + xCoefficients[3] * t + xCoefficients[4]
        end
    end

    for i, line in ipairs( lines ) do
        local isLinear = line.mode == "linear"
        local x1, x2, y1, y2 = line.x1, line.x2, line.y1, line.y2
        local minX, maxX, minY, maxY, xDiff, yDiff, slope, isVertical, isHorizontal, nextY, lastY, xCoefficients, yCoefficients
        if isLinear then
            minX, maxX, minY, maxY = min( x1, x2 ), max( x1, x2 ), min( y1, y2 ), max( y1, y2 )
            xDiff, yDiff = x2 - x1, y2 - y1
            isVertical, isHorizontal = abs( xDiff ) < ERROR_MARGIN, abs( yDiff ) < ERROR_MARGIN
            if not isVertical and not isHorizontal then
                slope = yDiff / xDiff
            end
            nextY = y2
        else
            xCoefficients = coefficients[i][1]
            yCoefficients = coefficients[i][2]
            nextY = xCoefficients[1] * ERROR_MARGIN * ERROR_MARGIN * ERROR_MARGIN + xCoefficients[2] * ERROR_MARGIN * ERROR_MARGIN + xCoefficients[3] * ERROR_MARGIN + xCoefficients[4]
        end


        local disallowedY, disallowedX
        -- the link below expliains what's happening. essentially we need to check if the end point is a maxima. if it isn't we need to prevent the pixel coordinates from duplicating
        -- https://books.google.com.au/books?id=fGX8yC-4vXUC&pg=PA52&lpg=PA52&dq=polygon+scanline+maxima&source=bl&ots=wb9LU6OjYx&sig=crP4WLcvB-VAHFj_WIsmn5HoTZ4&hl=en&sa=X&ved=0ahUKEwjmzbXaz8nJAhUBhqYKHRl5A30Q6AEINTAF#v=onepage&q=polygon%20scanline%20maxima&f=false

        -- if both lines are heading below or above the vertex it's a maxima
        local thisGreaterThan, lastGreaterThan = nextY > y1, lastYs[i == 1 and #lines or ( i - 1 )] > y1
        if thisGreaterThan ~= lastGreaterThan then
            disallowedY = y1
            disallowedX = x1
        end

        if isLinear then
            if isVertical then -- the two points are in a vertical line
                for y = minY, maxY, inverseScale do
                    if not aproxEqual( y, disallowedY ) and y >= minY - ERROR_MARGIN and y <= maxY + ERROR_MARGIN then
                        local yIntersections = intersections[y * scaleY]
                        yIntersections[#yIntersections + 1] = ( x1 - 1 ) * scaleX + 1
                    end
                end
            elseif isHorizontal then -- the two points are in a horizontal line
                local yIntersections = intersections[floor( y1 * scale + 0.5 )]
                yIntersections[#yIntersections + 1] = ( maxX - 1 ) * scaleX + 1
            else
                local yIntercept = y1 - slope * x1
                for y = minY, maxY, inverseScale do
                    local yIntersections = intersections[y * scaleY]
                    local x = ( y - yIntercept ) / slope
                    if ( not aproxEqual( x, disallowedX ) or not aproxEqual( y, disallowedY ) ) and x >= minX - ERROR_MARGIN and x <= maxX + ERROR_MARGIN then
                        yIntersections[#yIntersections + 1] = ( x - 1 ) * scaleX + 1
                    end
                end
            end
        else
            for y = 1, height, inverseScale do
                local yRoots = cubicRoots( { yCoefficients[1], yCoefficients[2], yCoefficients[3], yCoefficients[4] - y } )
                local yIntersections = intersections[y * scaleY]
                for i = 1, 3 do
                    t = yRoots[i];
                    if 0 <= t and t <= 1 then
                        local x = xCoefficients[1] * t * t * t + xCoefficients[2] * t * t + xCoefficients[3] * t + xCoefficients[4]
                        if not aproxEqual( y, disallowedY ) and not aproxEqual( x, disallowedX ) then
                            yIntersections[#yIntersections + 1] = ( x - 1 ) * scaleX + 1
                        end
                    end
                end
            end
        end
    end

    for y = 1, height, inverseScale do
        table.sort( intersections[y * scaleY] )
    end

    return intersections
end