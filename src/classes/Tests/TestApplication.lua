
class "TestApplication" extends "Application" {
	name = "A test application";
	-- interfaceName = "main";
}

--[[
	@instance
	@desc Initialise the custom application
]]
function TestApplication:init()
	self.super:init()
	self:event( Event.CHAR, self.onChar )
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
