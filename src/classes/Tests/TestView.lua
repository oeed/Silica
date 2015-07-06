
class "TestView" extends "View" {
	position = 1;
}

function TestView:init()
	self.super:init()
	self.application:schedule( 2, self.flash, self, "hello" )
end

function TestView:flash( text )
	term.clear()
	print( text )
end

function TestView:update( deltaTime )
	self.position = self.position + 1
end

function TestView:draw()
	term.setFillColour( Graphics.colours.BLACK )
	term.clear()

	local function xy( position )
		position = position % (52 * 19)
		return position % 52, math.ceil( position / 52 )
	end

	term.setFillColour( Graphics.colours.GREY )
	term.setCursorPos( xy( self.position - 2 ) )
	term.write( " " )

	term.setFillColour( Graphics.colours.LIGHT_GREY )
	term.setCursorPos( xy( self.position - 1 ) )
	term.write( " " )

	term.setFillColour( Graphics.colours.WHITE )
	term.setCursorPos( xy( self.position ) )
	term.write( " " )
end
