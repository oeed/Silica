
class "TestApplication" extends "Application" {
	name = "A test application";
}

--[[
	@instance
	@desc Initialise the custom application
]]
function TestApplication:init()
	self.super:init()

	self:event( Event.CHAR, self.onChar )

	local one = CordView(
		{
			x = 8;
			y = 3;
			width = 10;
			height = 14;
			backgroundColour = colours.green;
		}
	)

	local two = CordView(
		{
			x = 3;
			y = 2;
			width = 10;
			height = 14;
			backgroundColour = colours.blue;
		}
	)

	local three = CordView(
		{
			x = 3;
			y = 3;
			width = 10;
			height = 14;
			backgroundColour = colours.red;
		}
	)

	print( one )
	print( two )
	print( three )

	two:addChild( three )
	one:addChild( two )

	self.container:addChild( one )
end

--[[
	@instance
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function TestApplication:onChar( event )
	if event.char == '\\' then
		os.reboot()
	end
end
