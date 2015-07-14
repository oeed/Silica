
class "ExampleApplication" extends "Application" {
	name = "Example";
	interfaceName = "first";
}

-- For the demo the below code isn't really needed, it's just for debug

--[[
	@constructor
	@desc Initialise the custom application
]]
function ExampleApplication:init()
	self.super:init()
	self:event( Event.CHARACTER, self.onChar )
end

--[[
	@instance
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function ExampleApplication:onChar( event )
	if not self.focus and event.character == '\\' then
		os.reboot()
	end
end