
class "PathView" extends "View" {

    height = 100; -- the default height
    width = 100;

}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function PathView:init( ... )
    self.super:init( ... )
    self:event( Event.MOUSE_DOWN, self.onMouseDown )
end

function PathView:onMouseDown( event )
    if event.mouseButton == MouseEvent.mouseButtons.RIGHT then
    	local menu = Menu.fromInterface( "menu" )
    	menu:showContext( self, event.x, event.y )
    end
    return true
end


--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function PathView:initCanvas()
	self.super:initCanvas()
	self.canvas.fillColour = Graphics.colours.WHITE

	local path = Path( 1, 1, self.width - 20, self.height - 20, 1, 1 )
	path:curveTo( 20, 60, 50, 35 + 12.5, 0, 40 )
	path:lineTo( 50, 40 )
	path:lineTo( 1, 30 )
	path:lineTo( 40, 15 )
	path:lineTo( 40, 25 )
	path:lineTo( 60, 20 )
	path:lineTo( 50, 10 )

	local size = 3
	
	path:close()
	path.fillColour = Graphics.colours.BLUE
	path.outlineColour = Graphics.colours.RED

	-- local path2 = Path( 40, 40, 60, 60, 40, 40 )
	-- path2:lineTo( 1, 40 )
	-- path2:arc( math.pi * 3/2, math.pi * 2, 39 )
	-- path2:lineTo( 60, 20 )
	-- path2:close()

	local path3 = Path( 50, 50, 60, 60 )
	path3:lineTo( 20, 2 )
	path3:lineTo( 30, 25 )
	path3:arc( math.pi / 2, math.pi * 2, 15 )
	path3:lineTo( 15, 0 )
	path3:close( false )
	path3.outlineColour = Graphics.colours.BLACK

	-- self.canvas:insert( Shader( 1, 1, self.canvas.width, self.canvas.height, function( x, y )
	-- 	return ( math.ceil( x / size ) + math.ceil( y / size ) ) % 2 == 0 and Graphics.colours.LIGHT_GREY or Graphics.colours.WHITE
	-- end ) )

	self.canvas:insert( path )
	-- self.canvas:insert( path2 )
	self.canvas:insert( path3 )
end

--[[
m = .3
c = -10
]]
