
class "FilledRenderer" extends "GenericRenderer" {
	fillColour = 1;
}

function FilledRenderer:initialise( ... )
	return self.super:initialise( ... )
end

function FilledRenderer:getRenderer()
	local renderer = GenericRenderer.getRenderer( self )
	renderer.fillColour = self.fillColour
	renderer.getFill = self.getFill
	return renderer
end

function FilledRenderer:setWidth( width )
	self.width = width
	self.hasChanged = true
	self.fillCache = nil
end

function FilledRenderer:setHeight( height )
	self.height = height
	self.hasChanged = true
	self.fillCache = nil
end

function FilledRenderer:setFillColour( colour )
	self.fillColour = colour
	self.hasChanged = true
end

function FilledRenderer:setOutlineColour( colour )
	self.outlineColour = colour
	self.hasChanged = true
end

function FilledRenderer:getFill()
	return {}
end

function GenericRenderer:getOutline()
	local pixels = {}

	local fill = self:getFill()

	local function xScanline( min, max, inc, y, outlineWidth )
		local xPixels = 0
		for x = min, max, inc do
			local px = fill[y] and fill[y][x]
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
			local px = fill[y] and fill[y][x]
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

function FilledRenderer:drawTo( canvas, x, y )
	if self.hasChanged then
		log "I have changed"

		local renderer = self.renderer

		renderer:clear()
		local fill = self:getFill()
		local colour = renderer.fillColour
		for y, v in pairs( fill ) do
			for x, p in pairs( v ) do
				if p then
					renderer:setPixel( x, y, colour )
				end
			end
		end
		renderer:drawOutline()

		renderer:finish()
		self.hasChanged = false
	end
	self:drawBufferTo( canvas, x, y )
end
