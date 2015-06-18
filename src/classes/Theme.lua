
class "Theme" {
	
}

--[[
	@constructor
	@desc Loads a theme from file path
	@param [string] filePath -- the file path of the theme
]]
function Theme:init( filePath )
	self.name = interfaceName

	-- TODO: dynamic path resolving for interfaces and other files
	local path = "/src/interface/" .. interfaceName .. ".slayout"
	if fs.exists( path ) then
		local nodes = XML.fromFile( path )
		local err = self:initContainer( nodes )
		if err then
			error( "Interface XML invaid: " .. self.name .. ".slayout. Error: " .. err )
		end
	else
		error( "Interface file not found: " .. interfaceName .. ".slayout" )
	end
end
