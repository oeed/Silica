
local floor = math.floor

class "OutlinePath" extends "Path" {}

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
function OutlinePath:init( x, y, width, height, currentX, currentY )
	self.super:init( x, y, width, height, currentX, currentY )
	self.outlineColour = outlineColour
end

function OutlinePath:getFill()
	return nil
end

function OutlinePath:getOutline()
	if self.outline then
		return self.outline
	end

	local minY, maxY, minX, maxX = 1, self.height, 1, self.width
	local outline = {}

	for y = minY, maxY do
		local points, vertices = self:getPointsAndVertices( y, minX, maxX )
		for i = 1, #points do
			local x = floor( points[i] + .5 )
			outline[x] = outline[x] or {}
			outline[x][y] = true
		end
	end

	local thickendOutline = {}
	local function xScanline( min, max, inc, outlineWidth )
		if outlineWidth <= 1 then return end
		for y = 1, self.height do
			for x = min, max, inc do
				if outline[x] and outline[x][y] then
					for i = 1 - outlineWidth, outlineWidth - 1 do
						thickendOutline[x + i] = thickendOutline[x + i] or {}
						thickendOutline[x + i][y] = true
					end	
				end
			end
		end
	end

	local function yScanline( min, max, inc, outlineWidth )
		for x = 1, self.width do
			local lastY = 0
			local yPixels = 0
			local outlineX = outline[x]
			if outlineX then
				for y, isSet in pairs( outlineX ) do
					if isSet then
						for i = 1 - outlineWidth, outlineWidth - 1 do
							thickendOutline[x + i] = thickendOutline[x + i] or {}
							thickendOutline[x][y + i] = true
						end	
					end
				end
			end
		end
	end

	xScanline( 1, self.width, 1, self.leftOutlineWidth )
	xScanline( self.width, 1, -1, self.rightOutlineWidth )
	yScanline( 1, self.height, 1, self.topOutlineWidth )
	yScanline( self.height, 1, -1, self.bottomOutlineWidth )

	self.outline = thickendOutline
	return thickendOutline
end

function OutlinePath:close( linkedToEnd )
	linkedToEnd = (linkedToEnd == nil) and false or true
	self.super:close( linkedToEnd )
end