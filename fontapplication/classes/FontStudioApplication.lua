
class "FontStudioApplication" extends "Application" {
	name = "FontStudio";
	interfaceName = "fontstudio";
}

-- For the demo the below code isn't really needed, it's just for debug

--[[
	@constructor
	@desc Initialise the custom application
]]
function FontStudioApplication:initialise()
	self.super:initialise()
	self:event( Event.CHARACTER, self.onChar )
end

--[[
	@instance
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function FontStudioApplication:onChar( event )
	if not self:hasFocus() and event.character == '\\' then
		os.reboot()
	end
end