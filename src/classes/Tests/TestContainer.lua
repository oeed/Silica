-- testing out the menu issue you had before
-- if y is greater than 15 it acts like the menu content, less than that it closes the menu

class "TestContainer" extends "Container" {
	isOpen = false;
}

function TestContainer:init( ... )
	self.super:init( ... )
	self.event:connectGlobal( Event.MOUSE_DOWN, self.onGlobalClick )
	self:event( Event.MOUSE_DOWN, self.onClick )
end

function TestContainer:setIsOpen( isOpen )
	self.isOpen = isOpen

	-- Don't worry, this is only temporary for testing until Canvas is ready
	term.setTextColor(colors.white)
	if isOpen then
		term.setBackgroundColour( colours.lime )
		for i = 1, 15 do
			term.clearLine()
		end

		term.setBackgroundColour( colours.red )
		for i = 16, 19 do
			term.clearLine()
		end
	else
		term.setBackgroundColour( colours.blue )
		term.clear()
		term.setCursorPos(1, 1)
	end
end

function TestContainer:onClick( event )
	print( "Clicked! " .. tostring( event ) )
end

function TestContainer:hitTest( x, y, parent )
	-- just for testing
	return x > 26
end