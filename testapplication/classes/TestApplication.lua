
class "TestApplication" extends "Application" {

	name = String( "Test" );
	interfaceName = String( "test" ).allowsNil;

}

function TestApplication:initialise()
	self:super()
	self:event( CharacterEvent, self.onChar )
end

--[[
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function TestApplication:onChar( CharacterEvent event, Event.phases phase )
	if not self:hasFocus() and event.character == '\\' then
		os.reboot()
	end
end