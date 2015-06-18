
class "Interface" {
	name = nil;
	container = nil;
}

--[[
	@constructor
	@desc Creates and loads an interface with the given name
	@param [string] interfaceName -- the file name of the interface
]]
function Interface:init( interfaceName )
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

--[[
	@instance
	@desc Creates the container from the interface file
]]
function Interface:initContainer( nodes )
	if not nodes then
		return "Format invalid."
	end

	local containerClass = class.get( nodes.name )

	if not containerClass then
		return "Container class not found: " .. nodes.name
	elseif not containerClass:typeOf( ApplicationContainer ) then
		return "Container class does not extend 'ApplicationContainer': " .. nodes.name
	end

	local container = containerClass( nodes.attributes )
	if not container then
		return "Failed to initialise " .. nodes.name .. ". Identifier: " .. tostring( nodes.attributes.identifier )
	end

	local function insertTo( childNode, parentContainer )
		local childClass = class.get( childNode.name )

		if not containerClass then
			return "Class not found: " .. childNode.name
		elseif not containerClass:typeOf( View ) then
			return "Class does not extend 'View': " .. childNode.name
		end

		local child = childClass( childNode.attributes )
		if not child then
			return "Failed to initialise " .. childNode.name .. ". Identifier: " .. tostring( childNode.attributes.identifier )
		end

		parentContainer:insert( child )

		if #childNode.childNodes > 0 then
			if not containerClass:typeOf( Container ) then
				return "Class does not extend 'Container' but has children: " .. childNode.name
			else
				for i, _childNode in ipairs( childNode.childNodes ) do
					insertTo( _childNode, child )
				end
			end
		end
	end

	for i, childNode in ipairs( nodes.childNodes ) do
		insertTo( childNode, container )
	end

	self.container = container
end
