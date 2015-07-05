
local sin, cos, floor, min, max, abs, acos, PI = math.sin, math.cos, math.floor, math.min, math.max, math.abs, math.acos, math.pi

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

local function getHorizontalLinearIntersectionPoint( points, y, line, minX, maxX )
	if abs( line.x1 - line.x2 ) < .00001 then
		if y >= min( line.y1, line.y2 ) - .00001 and y <= max( line.y1, line.y2 ) + .0001 then
			points[#points + 1] = floor( line.x1 + .5 )
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

local function getVerticalLinearIntersectionPoint( points, x, line, minY, maxY )
	if abs( line.y1 - line.y2 ) < .00001 then
		if x >= math.min( line.x1, line.x2 ) - .00001 and x <= math.max( line.x1, line.x2 ) + .0001 then
			points[#points + 1] = floor( line.y1 + 0.5 )
		end
	else
		local m = ( line.y2 - line.y1 ) / ( line.x2 - line.x1 )
		local c = line.y1 - m * line.x1
		local y = m * x + c
		if y >= min( line.y1, line.y2 ) - .00001 and y <= max( line.y1, line.y2 ) + .0001 then
			points[#points + 1] = y
		end
	end
end

local function getHorizontalCurvedIntersectionPoints( points, y, line, minX, maxX )
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

local function getVerticalCurvedIntersectionPoints( points, x, line, minY, maxY )
	if not line.xCoefficients or not line.yCoefficients then
		line.xCoefficients = bezierCoeffs( line.x1, line.controlPoint1X, line.controlPoint2X, line.x2 )
		line.yCoefficients = bezierCoeffs( line.y1, line.controlPoint1Y, line.controlPoint2Y, line.y2 )
	end

	local xCoefficients = line.yCoefficients
	local yCoefficients = line.xCoefficients

	local yRoots = cubicRoots( { yCoefficients[1], yCoefficients[2], yCoefficients[3], yCoefficients[4] - x } )

    for i = 1, 3 do
        t = yRoots[i];
        if t > 0 and t < 1 then
	        local y = xCoefficients[1] * t * t * t + xCoefficients[2] * t * t + xCoefficients[3] * t + xCoefficients[4];
			y = min( max( y, minY ), maxY )
			points[#points + 1] = y
	    end
    end
end

class "PathRenderer" extends "FilledRenderer" {
	lines = {};
	defined = false; -- when true the path becomes immutable. set to true after :close is called
	currentX = 0;
	currentY = 0;
	outlinePoints = {};
}

function PathRenderer:init( x, y, width, height, currentX, currentY )
	self.super:init( x, y, width, height )
	self.currentX = currentX or 1
	self.currentY = currentY or 1
end

function PathRenderer:getRenderer()
	local renderer = FilledRenderer.getRenderer( self )
	renderer.getHorizontalIntersections = self.getHorizontalIntersections
	renderer.getVerticalIntersections = self.getVerticalIntersections
	renderer.lines = self.lines
	return renderer
end

function PathRenderer:moveTo( x, y )
	self.currentX = x
	self.currentY = y
end

function PathRenderer:lineTo( x, y )
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
	return true
end

function PathRenderer:curveTo( endX, endY, controlPoint1X, controlPoint1Y, controlPoint2X, controlPoint2Y )
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

function PathRenderer:arc( startAngle, endAngle, radius )
	if self.defined then return false end

	local lines = self.lines
	local currentX, currentY = self.currentX, self.currentY
	local centreX, centreY = currentX - sin( startAngle ) * radius, currentY + cos( startAngle ) * radius
	local length = endAngle - startAngle
	local segments = floor( radius * abs( length ) * PI / 8 + .5 )

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

function PathRenderer:close( linkedToEnd )
	linkedToEnd = (linkedToEnd == nil) and true or false
	if self.defined then return false end

	if #self.lines == 0 then
		error( "Path has no lines!", 2 )
	end
	if linkedToEnd and (self.lines[1].x1 ~= self.lines[#self.lines].x2 or self.lines[1].y1 ~= self.lines[#self.lines].y2) then
		self:lineTo( self.lines[1].x1, self.lines[1].y1 )
	end

	self.defined = true;
	self.currentX = nil
	self.currentY = nil
	return true
end


function PathRenderer:getHorizontalIntersections( y, minX, maxX )
	local points = {}
	local lines = self.lines
	for i = 1, #lines do
		if lines[i].mode == "linear" then
			getHorizontalLinearIntersectionPoint( points, y, lines[i], minX, maxX )
		else
			getHorizontalCurvedIntersectionPoints( points, y, lines[i], minX, maxX )
		end
	end
	table.sort( points )
	return points
end

function PathRenderer:getVerticalIntersections( x, minY, maxY )
	local points = {}
	local lines = self.lines
	for i = 1, #lines do
		if lines[i].mode == "linear" then
			getVerticalLinearIntersectionPoint( points, x, lines[i], minY, maxY )
		else
			getVerticalCurvedIntersectionPoints( points, x, lines[i], minY, maxY )
		end
	end
	table.sort( points )
	return points
end

function PathRenderer:getFill()
	if self.fillcache then return self.fillcache end

	local minY, maxY, minX, maxX = 1, self.height, 1, self.width
	local fill = {}

	for y = minY, maxY do

		local fillY = {}

		local points = self:getHorizontalIntersections( y, minX, maxX )

		if #points == 1 then
			local x = floor( points[1] + .5 )
			fillY[x] = true
		else
			local filling = false
			for i = 1, #points - 1 do
				local isVertex = ( round( points[i] ) == round( points[i + 1] ) ) or ( points[i-1] and round( points[i] ) == round( points[i - 1] ) )
				if not isVertex then
					filling = not filling
				end
				if filling then
					for x = floor( points[i] + .5 ), floor( points[i + 1] + .5 ) do
						fillY[x] = true
					end
				end
			end
		end

		fill[y] = fillY
	end

	self.fillcache = fill
	return fill
end
