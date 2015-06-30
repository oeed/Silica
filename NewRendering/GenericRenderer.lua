
local TRANSPARENT = 0

class "GenericRenderer" {
	x = 1;
	y = 1;
	width = 0;
	height = 0;
	changed = false;

	topOutlineWidth = 1;
	bottomOutlineWidth = 1;
	leftOutlineWidth = 1;
	rightOutlineWidth = 1;
}

function GenericRenderer:init( width, height )
	self.buffer = {}
	self.width = width
	self.height = height
end

function GenericRenderer:setPixel( x, y, colour )
	if colour ~= TRANSPARENT and x > 0 and x <= self.width and y > 0 and y <= self.height then
		self.buffer[( y - 1 ) * self.width + x] = colour
	end
end

function GenericRenderer:getPixel( x, y )
	return self.buffer[( y - 1 ) * self.width + x]
end

function GenericRenderer:getOutlinePixels()

end

function GenericRenderer:map( shader, x, y, w, h )
	local width = self.width
	local new = {}
	for _y = y, y + h - 1 do
		for _x = x, x + w - 1 do
			local index = ( _y - 1 ) * width + _x
			local current = self.buffer[index]
			new[index] = shader( _x, _y, current ) or current
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

	t.setPixel = self.setPixel
	t.getPixel = self.getPixel
	t.getOutline = self.getOutline
	t.map = self.map

	function t:finish()
		obj.buffer = self.buffer
	end

	return t
end

function GenericRenderer:drawTo( canvas )
	local buffer = self.buffer
	local renderer = canvas:getRenderer()
	local ox, oy = self.x - 1, self.y - 1
	for y = 1, self.height do
		local bufferY = self.width * ( y - 1 )
		for x = 1, self.width do
			renderer:setPixel( x + ox, y + oy, buffer[bufferY + x] )
		end
	end
end
