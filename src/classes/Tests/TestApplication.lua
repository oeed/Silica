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

	self.container:addChild( TestView(
		{
			x = 5;
			y = 9;
			width = 10;
			height = 14;
		}
	) )
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