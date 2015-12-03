
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
	self:super()
	self:event( CharacterEvent, self.onChar )
end

--[[
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function FontStudioApplication:onChar( Event event, Event.phases phase )
	if not self:hasFocus() and event.character == '\\' then
		os.reboot()
	end
end