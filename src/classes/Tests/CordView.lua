
class "CordView" extends "Container" {
	backgroundColour = colours.white;
}

function CordView:init( ... )
	self.super:init( ... )
	self:event( Event.MOUSE_DOWN, self.onClick )
	self:event( Event.MOUSE_DRAG, self.onClick )
end

function CordView:onClick( event )
	term.setCursorPos( self:coordinatesTo( event.x, event.y ) )
	term.setBackgroundColour( self.backgroundColour / 2 )
	term.write( ' ' )
end

function CordView:draw()
	local x, y = self:position()
	for _x = x, self.width + x - 1 do
		for _y = y, self.height + y - 1 do
			term.setCursorPos( _x, _y )
			term.setBackgroundColour( self.backgroundColour )
			term.write( ' ' )
		end
	end

	self.super:draw()
end
