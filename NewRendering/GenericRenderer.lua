
local TRANSPARENT = 0

class "GenericRenderer" {
	x = 1;
	y = 1;
	width = 0;
	height = 0;
	hasChanged = false;

	topOutlineWidth = 1;
	bottomOutlineWidth = 1;
	leftOutlineWidth = 1;
	rightOutlineWidth = 1;

	outlineColour = 1;
}

function GenericRenderer:initialise( x, y, width, height )
	self.buffer = {}
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

function GenericRenderer:setWidth( width )
	self.hasChanged = true
	self.width = width
end

function GenericRenderer:setHeight( height )
	self.hasChanged = true
	self.height = height
end

function GenericRenderer:setOutlineColour( colour )
	self.outlineColour = colour
	self.hasChanged = true
end

function GenericRenderer:setOutlineWidth( outlineWidth )
	self.hasChanged = true
	self.leftOutlineWidth = outlineWidth
	self.topOutlineWidth = outlineWidth
	self.rightOutlineWidth = outlineWidth
	self.bottomOutlineWidth = outlineWidth
end

function GenericRenderer:setTopOutlineWidth( width )
	self.hasChanged = true
	self.topOutlineWidth = width
end

function GenericRenderer:setBottomOutlineWidth( width )
	self.hasChanged = true
	self.bottomOutlineWidth = width
end

function GenericRenderer:setLeftOutlineWidth( width )
	self.hasChanged = true
	self.leftOutlineWidth = width
end

function GenericRenderer:setRightOutlineWidth( width )
	self.hasChanged = true
	self.rightOutlineWidth = width
end

function GenericRenderer:clear()
	self.buffer = {}
	self.hasChanged = true
end

function GenericRenderer:setPixel( x, y, colour )
	if colour ~= TRANSPARENT and x > 0 and x <= self.width and y > 0 and y <= self.height then
		self.hasChanged = true
		self.buffer[( y - 1 ) * self.width + x] = colour
	end
end

function GenericRenderer:getPixel( x, y )
	return self.buffer[( y - 1 ) * self.width + x]
end

function GenericRenderer:getOutline()
	local pixels = {}

	local function xScanline( min, max, inc, y, outlineWidth )
		local xPixels = 0
		for x = min, max, inc do
			local px = self:getPixel( x, y )
			if px and px ~= TRANSPARENT then
				if xPixels < outlineWidth then
					xPixels = xPixels + 1
					pixels[y][x] = true
				end
			else
				xPixels = 0
			end
		end
	end

	local function yScanline( min, max, inc, x, outlineWidth )
		local yPixels = 0
		for y = min, max, inc do
			local px = self:getPixel( x, y )
			if px and px ~= TRANSPARENT then
				if yPixels < outlineWidth then
					yPixels = yPixels + 1
					pixels[y][x] = true
				end
			else
				yPixels = 0
			end
		end
	end

	local width, height = self.width, self.height
	for y = 1, height do
		pixels[y] = {}
		xScanline( 1, width,  1, y, self.leftOutlineWidth )
		xScanline( width, 1, -1, y, self.rightOutlineWidth )
	end
	for x = 1, width do
		yScanline( 1, height,  1, x, self.topOutlineWidth )
		yScanline( height, 1, -1, x, self.bottomOutlineWidth )
	end

	return pixels
end

function GenericRenderer:drawOutline( colour )
	colour = colour or self.outlineColour
	if not colour or colour == 0 then return end
	local pixels = self:getOutline()
	local width = self.width
	for y = 1, #pixels do
		for x = 1, width do
			if pixels[y][x] then
				self:setPixel( x, y, colour )
			end
		end
	end
end

function GenericRenderer:map( shader, x, y, w, h )
	local width = self.width
	local new = {}
	local buffer = self.buffer
	local setHasChanged = false
	for _y = y or 1, ( y or 1 ) + ( h or self.height ) - 1 do
		for _x = x or 1, ( x or 1 ) + ( w or width ) - 1 do
			local index = ( _y - 1 ) * width + _x
			local current = buffer[index]
			local newpixel = shader( _x, _y, current )
			if newpixel then
				if not setHasChanged then
					self.hasChanged = true
					setHasChanged = true
				end
				new[index] = newpixel
			else
				new[index] = current
			end
		end
	end
	self.buffer = new
end

function GenericRenderer:getRenderer()
	local obj = self
	local t = {}
	t.width = self.width
	t.height = self.height
	t.buffer = self.buffer

	t.topOutlineWidth = self.topOutlineWidth
	t.bottomOutlineWidth = self.bottomOutlineWidth
	t.leftOutlineWidth = self.leftOutlineWidth
	t.rightOutlineWidth = self.rightOutlineWidth

	t.outlineColour = self.outlineColour

	t.clear = self.clear
	t.setPixel = self.setPixel
	t.getPixel = self.getPixel
	t.getOutline = self.getOutline
	t.drawOutline = self.drawOutline
	t.map = self.map

	function t:finish() -- very, very important...
		obj.buffer = self.buffer
		obj.hasChanged = obj.hasChanged or self.hasChanged
	end

	return t
end

function GenericRenderer:drawBufferTo( canvas, x, y )
	local buffer = self.buffer
	local renderer = canvas:getRenderer()
	local ox, oy = x - 1, y - 1
	for y = 1, self.height do
		local bufferY = self.width * ( y - 1 )
		for x = 1, self.width do
			local colour = buffer[bufferY + x]
			if colour then
				renderer:setPixel( x + ox, y + oy, colour )
			end
		end
	end
	renderer:finish()
end

function GenericRenderer:drawTo( canvas, x, y )
	return self:drawBufferTo( canvas, x, y )
end
