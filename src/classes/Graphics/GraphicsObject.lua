
class "GraphicsObject" {
	x = 1; -- @property x [number] - The x position of the object
	y = 1; -- @property y [number] - The y position of the object
	width = 0; -- @property width [number] - The width of the object
	height = 0; -- @property height [number] - The height of the object
	hasChanged = false; -- @property hasChanged [boolean] - Whether or not the object's internals have hasChanged since it was last drawn
	parent = nil; -- @property parent [View] - The parent of the object, if it exists
	outlineColour = Graphics.colours.TRANSPARENT; -- @property [Graphics.colours] -- The colour of the outline
	leftOutlineWidth = 1; -- @property [number] -- The thickness of the outline
	topOutlineWidth = 1; -- @property [number] -- The thickness of the outline
	rightOutlineWidth = 1; -- @property [number] -- The thickness of the outline
	bottomOutlineWidth = 1; -- @property [number] -- The thickness of the outline
	fillColour = Graphics.colours.TRANSPARENT; -- @property [Graphics.colours] -- The fill colour of the object
	isVisible = true;
}

--[[
	@constructor
	@desc Creates a graphics object
	@param [number] x -- the x coordinate of the graphics object
	@param [number] y -- the y coordinate of the graphics object
	@param [number] width -- the width of the graphics object
	@param [number] height -- the height of the graphics object
]]
function GraphicsObject:init( x, y, width, height )
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

--[[
	@instance
	@desc Sets the x coordinate of the graphics object
	@param [number] x -- the x coordinate of the graphics object
]]
function GraphicsObject:setX( x )
	if self.parent then
		self.parent.hasChanged = true
	end
	self.x = x
end

--[[
	@instance
	@desc Sets the y coordinate of the graphics object
	@param [number] y -- the y coordinate of the graphics object
]]
function GraphicsObject:setY( y )
	if self.parent then
		self.parent.hasChanged = true
	end
	self.y = y
end

--[[
	@instance
	@desc Sets the width of the graphics object
	@param [number] width -- the width of the graphics object
]]
function GraphicsObject:setWidth( width )
	self.hasChanged = true
	self.width = width
end

--[[
	@instance
	@desc Sets the height of the graphics object
	@param [number] height -- the height of the graphics object
]]
function GraphicsObject:setHeight( height )
	self.hasChanged = true
	self.height = height
end

--[[
	@instance
	@desc Sets the outlineWidth of the graphics object
	@param [number] outlineWidth -- the outlineWidth of the graphics object
]]
function GraphicsObject:setOutlineWidth( outlineWidth )
	self.hasChanged = true
	self.leftOutlineWidth = outlineWidth
	self.topOutlineWidth = outlineWidth
	self.rightOutlineWidth = outlineWidth
	self.bottomOutlineWidth = outlineWidth
end

--[[
	@instance
	@desc Sets the outlineWidth of the graphics object
	@param [number] outlineWidth -- the outlineWidth of the graphics object
]]
function GraphicsObject:setLeftOutlineWidth( outlineWidth )
	self.hasChanged = true
	self.leftOutlineWidth = outlineWidth
end

--[[
	@instance
	@desc Sets the outlineWidth of the graphics object
	@param [number] outlineWidth -- the outlineWidth of the graphics object
]]
function GraphicsObject:setTopOutlineWidth( outlineWidth )
	self.hasChanged = true
	self.topOutlineWidth = outlineWidth
end

--[[
	@instance
	@desc Sets the outlineWidth of the graphics object
	@param [number] outlineWidth -- the outlineWidth of the graphics object
]]
function GraphicsObject:setRightOutlineWidth( outlineWidth )
	self.hasChanged = true
	self.rightOutlineWidth = outlineWidth
end

--[[
	@instance
	@desc Sets the outlineWidth of the graphics object
	@param [number] outlineWidth -- the outlineWidth of the graphics object
]]
function GraphicsObject:setBottomOutlineWidth( outlineWidth )
	self.hasChanged = true
	self.bottomOutlineWidth = outlineWidth
end

--[[
	@instance
	@desc Sets the fillColour of the graphics object
	@param [number] fillColour -- the fillColour of the graphics object
]]
function GraphicsObject:setFillColour( fillColour )
	self.hasChanged = true
	self.fillColour = fillColour
end

--[[
	@instance
	@desc Sets the visibility of the graphics object
	@param [boolean] isVisible -- whether the graphics object is visible
]]
function GraphicsObject:setIsVisible( isVisible )
	self.hasChanged = true
	self.isVisible = isVisible
end

--[[
	@instance
	@desc Sets the changed state of the graphics object, applying it to the parent too
	@param [boolean] hasChanged -- the changed state
]]
function GraphicsObject:setHasChanged( hasChanged )
	if hasChanged then
		if self.parent then
			self.parent.hasChanged = true
		end
		if self.fill then
			self.fill = nil
		end
	end
	self.hasChanged = hasChanged
end

--[[
	@instance
	@desc Sets the parent of the graphics object, removing the old one if it exists
	@param [boolean] hasChanged -- the parent
]]
function GraphicsObject:setParent( parent )
	if self.parent then
		self.parent:remove( self )
	end
	parent:insert( self )
end

--[[
	@instance
	@desc Generates the outline pixels from the given fill
	@param [table] fill -- the fill returned from self.getFill
	@return [table] outline -- the outline
]]
function GraphicsObject:getOutline( fill )
	local outline = {}

	local function xScanline( min, max, inc, outlineWidth )
		for y = 1, self.height do
			local lastX = 0
			local xPixels = 0
			for x = min, max, inc do
				outline[x] = outline[x] or {}
				if fill[x] and fill[x][y] then
					if xPixels < outlineWidth then
						xPixels = xPixels + 1
						outline[x][y] = true
					end
					lastX = x
				else
					xPixels = 0
				end
			end
		end
	end

	local function yScanline( min, max, inc, outlineWidth )
		for x = 1, self.width do
			local lastY = 0
			local yPixels = 0
			for y = min, max, inc do
				if fill[x] and fill[x][y] then
					if yPixels < outlineWidth then
						yPixels = yPixels + 1
						outline[x][y] = true
					end
					lastX = x
				else
					yPixels = 0
				end
			end
		end
	end

	xScanline( 1, self.width, 1, self.leftOutlineWidth )
	xScanline( self.width, 1, -1, self.rightOutlineWidth )
	yScanline( 1, self.height, 1, self.topOutlineWidth )
	yScanline( self.height, 1, -1, self.bottomOutlineWidth )

	return outline
end

--[[
    @instance
    @desc Draws a the graphics object to the canvas
    @param [Canvas] canvas -- the canvas to draw to
    @return self
]]
function GraphicsObject:drawTo( canvas )
	if self.isVisible then
		local fill = self.fill
		local outline
		if self.outlineColour ~= Graphics.colours.TRANSPARENT then
			outline = self:getOutline( fill )
		end

		local fillColour = self.fillColour
		local outlineColour = self.outlineColour
		local _x = self.x - 1
		local _y = self.y - 1

		for x, row in pairs( fill ) do
			for y, _ in pairs( row ) do
				if not outline or not outline[x] or not outline[x][y] then
					canvas:setPixel( _x + x, _y + y, fillColour )
				end
			end
		end

		if outline then
			for x, row in pairs( outline ) do
				for y, _ in pairs( row ) do
					canvas:setPixel( _x + x, _y + y, outlineColour )
				end
			end
		end
	end
	
    return self
end
