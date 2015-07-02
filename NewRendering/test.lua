
local files = {
	"src/class.lua";
	"NewRendering/GenericRenderer.lua";
	"NewRendering/FilledRenderer.lua";
	"NewRendering/CircleRenderer.lua";
	"NewRendering/Canvas.lua";
	"NewRendering/RoundedRectangleRenderer.lua";
	"NewRendering/PathRenderer.lua";
}

for i = 1, #files do
	local f, err = loadfile( files[i] )
	if not f then
		error( err, 0 )
	end
	f()
end

local startTime = os.clock()

local canvas = Canvas( 1, 1, 300, 160 )

local illuminati = PathRenderer( 1, 1, 51, 51, 26, 1 )
illuminati.fillColour = colours.blue
illuminati.outlineColour = 0-- colours.green
illuminati:lineTo( 51, 51 )
illuminati:lineTo( 1, 51 )
illuminati:lineTo( 26, 1 )
illuminati:moveTo( 26, 20 )
illuminati:arc( 0, math.pi * 2, 12 )
-- illuminati:lineTo(  )

canvas:draw( illuminati )

local renderer = canvas.renderer

log( 'Delta 1: ' .. os.clock() - startTime )
startTime = os.clock()

log( 'Delta 2: ' .. os.clock() - startTime )
startTime = os.clock()

renderer:finish()

renderer:map( function( x, y, colour )
	term.setBackgroundColour( colour or 1 )
	term.setCursorPos( x, y )
	term.write " "
end )

log( 'Delta 3: ' .. os.clock() - startTime )
