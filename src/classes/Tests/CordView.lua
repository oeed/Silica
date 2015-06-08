
class "CordView" extends "Container" {
	backgroundColour = colours.white;
}

function CordView:init( ... )
	self.super:init( ... )
	-- self:event( Event.MOUSE_DOWN, self.onClick )
end

function CordView:draw()
	local x, y = self:position( )
	for _x = x, self.width + x - 1 do
		for _y = y, self.height + y - 1 do
			term.setCursorPos( _x, _y)
			term.setBackgroundColour( self.backgroundColour )
			term.write( ' ' )
		end
	end

	self.super:draw()
end
