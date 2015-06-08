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
			term.setCursorPos( 1, i )
			term.clearLine()
		end

		term.setBackgroundColour( colours.red )
		for i = 16, 19 do
			term.setCursorPos( 1, i )
			term.clearLine()
		end
		term.setCursorPos(1, 1)
	else
		term.setBackgroundColour( colours.lightBlue )
		for i = 1, 15 do
			term.setCursorPos( 1, i )
			term.clearLine()
		end

		term.setBackgroundColour( colours.orange )
		for i = 16, 19 do
			term.setCursorPos( 1, i )
			term.clearLine()
		end
	end
end

function TestContainer:onClick( event )
	if not self.isOpen then
		self.isOpen = true
	else
		term.setBackgroundColour( colours.yellow )
		for i = 16, 19 do
			term.setCursorPos( 1, i )
			term.clearLine()
		end
	end
end

function TestContainer:onGlobalClick( event )
	if self.isOpen then
		if self:hitTestEvent( event ) then
			self.event:handleEvent( event )
		else
			self.isOpen = false
		end
		return true
	end
end

function TestContainer:hitTest( x, y, parent )
	-- just for testing
	return y > 15
end