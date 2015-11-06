
class "FilesApplication" extends "Application" {
	name = "Files";
	interfaceName = "files";
}

-- For the demo the below code isn't really needed, it's just for debug

--[[
	@constructor
	@desc Initialise the custom application
]]
function FilesApplication:initialise()
	self.super:initialise()
	self:event( Event.CHARACTER, self.onChar )
end

--[[
	@instance
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function FilesApplication:onChar( event )
	if not self:hasFocus() and event.character == '\\' then
		os.reboot()
	elseif event.character == "s" then
		self.container.fileStyle = 3 - self.container.fileStyle
	end
end