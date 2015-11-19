
class "GraphicsObject" {
	x = 1; -- @property x [number] - The x position of the object
	y = 1; -- @property y [number] - The y position of the object
	width = 0; -- @property width [number] - The width of the object
	height = 0; -- @property height [number] - The height of the object
	hasChanged = false; -- @property hasChanged [boolean] - Whether or not the object's internals have hasChanged since it was last drawn
	parent = false; -- @property parent [Canvas] - The parent of the object, if it exists
	outlineColour = Graphics.colours(); -- @property [Graphics.colours] -- The colour of the outline
	leftOutlineWidth = 1; -- @property [number] -- The thickness of the outline
	topOutlineWidth = 1; -- @property [number] -- The thickness of the outline
	rightOutlineWidth = 1; -- @property [number] -- The thickness of the outline
	bottomOutlineWidth = 1; -- @property [number] -- The thickness of the outline
	outlineWidth = Number( 1 ); -- @property [number] -- The thickness of the outline
	fillColour = Graphics.colours.TRANSPARENT; -- @property [Graphics.colours] -- The fill colour of the object
	isVisible = true;
	fill = false;
	outline = false;
	drawsShadow = false;
}

--[[
	@constructor
	@desc Creates a graphics object
	@param [number] x -- the x coordinate of the graphics object
	@param [number] y -- the y coordinate of the graphics object
	@param [number] width -- the width of the graphics object
	@param [number] height -- the height of the graphics object
]]
function GraphicsObject:initialise( x, y, width, height )
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
function GraphicsObject.x:set( x )
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
function GraphicsObject.y:set( y )
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
function GraphicsObject.width:set( width )
	if self.width ~= width then
		self.hasChanged = true
		self.width = width
	end
end

--[[
	@instance
	@desc Sets the height of the graphics object
	@param [number] height -- the height of the graphics object
]]
function GraphicsObject.height:set( height )
	if self.height ~= height then
		self.hasChanged = true
		self.height = height
	end
end

--[[
	@instance
	@desc Sets the outlineWidth of the graphics object
	@param [number] outlineWidth -- the outlineWidth of the graphics object
]]
function GraphicsObject.outlineWidth:set( outlineWidth )
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
function GraphicsObject.leftOutlineWidth:set( leftOutlineWidth )
	self.hasChanged = true
	self.leftOutlineWidth = leftOutlineWidth
end

--[[
	@instance
	@desc Sets the outlineWidth of the graphics object
	@param [number] outlineWidth -- the outlineWidth of the graphics object
]]
function GraphicsObject.topOutlineWidth:set( topOutlineWidth )
	self.hasChanged = true
	self.topOutlineWidth = topOutlineWidth
end

--[[
	@instance
	@desc Sets the outlineWidth of the graphics object
	@param [number] outlineWidth -- the outlineWidth of the graphics object
]]
function GraphicsObject.rightOutlineWidth:set( rightOutlineWidth )
	self.hasChanged = true
	self.rightOutlineWidth = rightOutlineWidth
end

--[[
	@instance
	@desc Sets the outlineWidth of the graphics object
	@param [number] outlineWidth -- the outlineWidth of the graphics object
]]
function GraphicsObject.bottomOutlineWidth:set( bottomOutlineWidth )
	self.hasChanged = true
	self.bottomOutlineWidth = bottomOutlineWidth
end

--[[
	@instance
	@desc Sets the fillColour of the graphics object
	@param [number] fillColour -- the fillColour of the graphics object
]]
function GraphicsObject.fillColour:set( fillColour )
	-- assert( type( fillColour ) == "number", "fillColour must be a valid colour.")
	self.hasChanged = true
	self.fillColour = fillColour
end

--[[
	@instance
	@desc Sets the outlineColour of the graphics object
	@param [number] outlineColour -- the outlineColour of the graphics object
]]
function GraphicsObject.outlineColour:set( outlineColour )
	-- assert( type( outlineColour ) == "number", "outlineColour must be a valid colour.")
	self.hasChanged = true
	self.outlineColour = outlineColour
end

--[[
	@instance
	@desc Sets the visibility of the graphics object
	@param [boolean] isVisible -- whether the graphics object is visible
]]
function GraphicsObject.isVisible:set( isVisible )
	self.hasChanged = true
	self.isVisible = isVisible
end

--[[
	@instance
	@desc Sets the changed state of the graphics object, applying it to the parent too
	@param [boolean] hasChanged -- the changed state
]]
function GraphicsObject.hasChanged:set( hasChanged )
	if hasChanged then
		local parent = self.parent
		if parent then
			parent.hasChanged = true
		end
		if self.raw.fill then
			self.fill = false
		end
	end
	self.hasChanged = hasChanged
end

--[[
	@instance
	@desc Sets the parent of the graphics object, removing the old one if it exists
	@param [boolean] hasChanged -- the parent
]]
function GraphicsObject.parent:set( parent )
	if self.parent then
		self.parent:remove( self )
	end
	self.parent = parent
	if parent then
		parent:insert( self )
	end
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
function GraphicsObject:drawTo( canvas, isShadow )
	if self.isVisible and ( not isShadow or ( isShadow and self.drawsShadow ) ) then
		local fill = self.fill
		local outline
		local outlineColour = self.outlineColour
		if outlineColour ~= Graphics.colours.TRANSPARENT then
			outline = self:getOutline( fill )
		end

		local fillColour = self.fillColour
		local _x = self.x - 1
		local _y = self.y - 1

		local buffer = canvas.buffer
		local width, height = canvas.width, canvas.height
		local TRANSPARENT = Graphics.colours.TRANSPARENT
		local function setPixel( x, y, colour )
			if colour ~= TRANSPARENT and x >= 1 and y >= 1 and x <= width and y <= height then
				buffer[ ( y - 1 ) * width + x ] = colour
			end
		end

		if fill then
			for x, row in pairs( fill ) do
				local outlineX = outline and outline[x]
				for y, isFilled in pairs( row ) do
                    if isFilled and (not outline or not outlineX or not outlineX[y]) then
                        setPixel( _x + x, _y + y, fillColour )
                    end
                end
			end
		end

		if outline then
			for x, row in pairs( outline ) do
				for y, _ in pairs( row ) do
					setPixel( _x + x, _y + y, outlineColour )
				end
			end
		end
	end
	
	return self
end

--[[
    @instance
    @desc Draws a graphics object to an image
	@param [boolean] isShadow -- whether just the shadow should be drawn
    @return [Image] image -- the image of the graphics object
]]
function GraphicsObject:toImage( isShadow )
	local parent = self.parent or self
    local canvasWidth, canvasHeight = parent.width, parent.height
    local width, height = self.width, self.height
    local fakeCanvas = { width = canvasWidth; height = canvasHeight; buffer = {} }

    self:drawTo( fakeCanvas, isShadow )

    local _x = self.x - 1
    local _y = self.y
    local pixels, canvasBuffer = {}, fakeCanvas.buffer
	local TRANSPARENT = Graphics.colours.TRANSPARENT

    for x = 1, width do
    	local pixelsX = {}
        for y = 1, height do
            local nx, ny = x + _x, y + _y - 1
            pixelsX[y] = canvasBuffer[( ny - 1 ) * canvasWidth + nx] or TRANSPARENT
        end
        pixels[x] = pixelsX
    end

    return Image.fromPixels( pixels, width, height )
end

--[[
    @instance
    @desc Draws a graphics object's shadow to an image
    @return [Image] image -- the image of the graphics object
]]
function GraphicsObject:toShadowImage()
    return self:toImage( true )
end