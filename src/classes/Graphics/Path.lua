
local sin, cos, floor, min, max, abs, acos, PI = math.sin, math.cos, math.floor, math.min, math.max, math.abs, math.acos, math.pi

local function round( num )
	return floor( num + 0.5 )
end

-- the next few functions are just taken from a site for bezier intersection, hence the terribly variables. don't hate.
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
        local th = acos( R / (-(Q^3))^.5 )
        
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

local function getLinearIntersectionPoint( points, y, line, minX, maxX )
	if line.x1 == line.x2 then
		if y >= min( line.y1, line.y2 ) and y <= max( line.y1, line.y2 ) then
			points[#points + 1] = line.x1
		end
	else
		local m = ( line.y2 - line.y1 ) / ( line.x2 - line.x1 )
		local c = line.y1 - m * line.x1
		local x = ( y - c ) / m
		if x >= min( line.x1, line.x2 ) - .00001 and x <= max( line.x1, line.x2 ) + .0001 then
			points[#points + 1] = x
		end
	end
end

local function getCurvedIntersectionPoints( points, y, line, minX, maxX )
	if not line.xCoefficients or not line.yCoefficients then
		line.xCoefficients = bezierCoeffs( line.x1, line.controlPoint1X, line.controlPoint2X, line.x2 )
		line.yCoefficients = bezierCoeffs( line.y1, line.controlPoint1Y, line.controlPoint2Y, line.y2 )
	end

	local xCoefficients = line.xCoefficients
	local yCoefficients = line.yCoefficients

	local yRoots = cubicRoots( { yCoefficients[1], yCoefficients[2], yCoefficients[3], yCoefficients[4] - y } )

    for i = 1, 3 do
        t = yRoots[i];
        if t > 0 and t < 1 then
	        local x = xCoefficients[1] * t * t * t + xCoefficients[2] * t * t + xCoefficients[3] * t + xCoefficients[4];
			x = min( max( x, minX ), maxX )
			points[#points + 1] = x
	    end
    end
end

class "Path" extends "GraphicsObject" {
	lines = {};
	defined = false; -- when true the path becomes immutable. set to true after :close is called
	width = 0;
	height = 0;
	x = 0;
	y = 0;
	currentX = 0;
	currentY = 0;
	outlinePoints = {}; -- the generic outline pixels used for fill and outline
}

--[[
	@constructor
	@desc Creates the start of a path
	@param [number] x -- the starting x coordinate
	@param [number] y -- the starting y coordinate
]]
function Path:init( x, y, width, height, fillColour, currentX, currentY )
	self.super:init( x, y, width, height )
	self.fillColour = fillColour
	self.currentX = currentX or 1
	self.currentY = currentY or 1
end

--[[
	@instance
	@desc Adds a straight line from the current position to the specified position
	@param [number] x -- the x coordinate to add a line to
	@param [number] y -- the y coordinate to add a line to
	@return [boolean] didAdd -- whether the line was added
]]
function Path:lineTo( x, y )
	if self.defined or not x or not y or (x == self.currentX and y == self.currentY) then return false end
	self.lines[#self.lines + 1] = {
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
	if self.defined or not endX or not endY or not controlPoint1X or not controlPoint1Y or not controlPoint2X or not controlPoint2Y then return false end
	
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
	@instance
	@desc Adds an arc from the current position of the specified position. This is always circular (constant radius).
	@param [number] endX -- the x coordinate to create the arc to
	@param [number] endY -- the y coordinate to create the arc to
	@param [number] startAngle -- the angle to start (in radians)
	@param [number] endAngle -- the angle to end (in radians)
	@return [boolean] didAdd -- whether the line was added
]]

local SPECIAL_CONST = 8 / 30 / PI

function Path:arc( startAngle, endAngle, radius )
	if self.defined then return false end

	local lines = self.lines

	local currentX, currentY = self.currentX, self.currentY
	local centreX, centreY = currentX - sin( startAngle ) * radius, currentY + cos( startAngle ) * radius

	local length = endAngle - startAngle
	local segments = floor( radius * abs( length ) * SPECIAL_CONST + .5 )

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
function Path:close()
	if self.defined then return false end

	if #self.lines == 0 then
		error( "Path has no lines!", 2 )
	end
	if self.lines[1].x1 ~= self.lines[#self.lines].x2 or self.lines[1].y1 ~= self.lines[#self.lines].y2 then
		self:lineTo( self.lines[1].x1, self.lines[1].y1 )
	end

	self.defined = true;
	self.currentX = nil
	self.currentY = nil
	return true
end

--[[
    @instance
    @desc Gets the points on the outline of the path
    @param [number] outlineWidth -- the outline width
    @param [boolean] dualAxis -- whether or not to check both axis
    	this should be true if generating outline points for fill mode
    @return [table] points -- an array of points { [y] = { [1] = x1, [n] = xn } }
    @return [number] minY -- the minimum Y coord
    @return [number] maxY -- the maximum Y coord
]]
function Path:getFill()
	if self.fill then
		return self.fill
	end

	local minY, maxY, minX, maxX = 1, self.height, 1, self.width
	local fill = {}

	for y = minY, maxY do

		local points = {}

		for i = 1, #self.lines do
			local line = self.lines[i]
			if line.mode == "linear" then
				getLinearIntersectionPoint( points, y, line, minX, maxX )
			else
				getCurvedIntersectionPoints( points, y, line, minX, maxX )
			end
		end

		local vertex = {}
		table.sort( points )
		for i = #points, 2, -1 do
			if points[i] == points[i-1] then
				vertex[i] = true
				vertex[i-1] = true
			elseif round( points[i] ) == round( points[i-1] ) then
				vertex[i] = true
				vertex[i-1] = true
			end
		end

		if #points == 1 then
			local x = floor( points[1] + .5 )
			fill[x] = fill[x] or {}
			fill[x][y] = true
		else
			local filling = false
			for i = 1, #points - 1 do
				if vertex[i] and filling then

				else
					filling = not filling
				end
				if filling then
					for x = floor( points[i] + .5 ), floor( points[i + 1] + .5 ) do
						fill[x] = fill[x] or {}
						fill[x][y] = true
					end
				end
			end
		end
	end

	self.fill = fill
	return fill
end