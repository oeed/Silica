
class "ProgressBarStripes" extends "RoundedRectangle" {
	stripeColour = nil;
	animationStep = 0;
	stripeWidth = 9;
}

function ProgressBarStripes:init( x, y, width, height, fillColour, outlineColour, stripeColour, radius ) -- @constructor( number x, number y, number width, number height, graphics.fillColour fillColour )
	self.super:init( x, y, width, height, fillColour, outlineColour, radius, 0, radius, 0 )
	self.fillColour = fillColour
	self.outlineColour = fillColour
	self.stripeColour = stripeColour
end

function ProgressBarStripes:setAnimationStep( animationStep )
	self.hasChanged = true
	self.animationStep = math.floor( animationStep )
end

-- doing this is a little naughty, but it is the easiest and nope way to doing it
function ProgressBarStripes:drawTo( canvas )
	if self.isVisible then
		local fill = self.fill
		local outline
		if self.outlineColour ~= Graphics.colours.TRANSPARENT then
			outline = self:getOutline( fill )
		end

		local fillColour = self.fillColour
		local stripeColour = self.stripeColour
		local outlineColour = self.outlineColour
		local stripeWidth = self.stripeWidth
		local animationStep = self.animationStep
		local _x = self.x - 1
		local _y = self.y - 1

		local function fmap( x, y, colour )
			if fill[x] and fill[x][y] then
				return ( ( ( x + y - animationStep ) / stripeWidth ) % 2 < 1 ) and fillColour or stripeColour
			end
		end
		local function ofmap( x, y, colour )
			if outline[x] and outline[x][y] then
				return outlineColour
			elseif fill[x] and fill[x][y] then
				return ( ( ( x + y - animationStep ) / stripeWidth ) % 2 < 1 ) and fillColour or stripeColour
			end
		end
		canvas:map( outline and ofmap or fmap, _x, _y, self.width, self.height )

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