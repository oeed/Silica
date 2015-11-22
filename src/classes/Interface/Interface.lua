
-- local function callSetters( instance, _class )
-- 	local definedFunctions, setters, raw = _class.definedFunctions, class.setters, instance.raw
-- 	for k, _ in pairs( _class.definedProperties ) do
-- 		local classValue = _class[k]
-- 		local instanceValue = raw[k]
-- 		if classValue and type( classValue ) ~= "table" and instanceValue == classValue and definedFunctions[setters[k]] then
-- 			instance[k] = classValue
-- 		end
-- 	end
-- end

class "Interface" {
	name = false; -- the name of the interface (the file name without the extension)
	container = false; -- if you want to generate a container based on the interface (i.e. not use the properties and children for an already made interface) you can use the value
	containerProperties = false; -- the properties given to the root element
	children = false; -- the children of the interface
	containerClass = false; -- the class type of the interface
	childNodes = false; -- the nodes from the root elements XML
}

--[[
	@constructor
	@desc Creates and loads an interface with the given name
	@param [string] interfaceName -- the file name of the interface
]]
function Interface:initialise( interfaceName, extend )
	self.name = interfaceName
	extend = extend or ApplicationContainer

	-- TODO: dynamic path resolving for interfaces and other files
	local resource = Resource( interfaceName, Metadata.mimes.SINTERFACE, "interfaces" )
	local contents = resource.contents
	if contents then
		local nodes, err = XML.static:fromText( contents )
		if not err and #nodes ~= 1 then err = "Interfaces must only have 1 root element." end
		if not nodes or err then
			error( "Interface XML invaid: " .. interfaceName .. ".sinterface. Error: " .. tostring( err ), 0 )
		end

		local rootNode = nodes[1]
		local containerClass = class.get( rootNode.type )
		local err

		if not containerClass then
			err = "Container class not found: " .. rootNode.type
		elseif not containerClass:typeOf( extend ) then
			err = "Container class does not extend '" .. extend.className .. "': " .. rootNode.type
		else
			self.containerClass = containerClass
			self.containerProperties = rootNode.attributes
			self.childNodes = rootNode.body
		end

		if err then
			error( "Interface XML invaid: " .. interfaceName .. ".sinterface. Error: " .. err, 0 )
		end
	else
		error( "Interface file not found: " .. interfaceName .. ".sinterface", 0 )
	end
end

--[[
	@desc Returns and generates if needed a container from the interface.
	@return [Container] container -- the container
]]
function Interface.container:get()
	local container = self.container
	if container then return container end

	local containerProperties = self.containerProperties
	local containerClass = self.containerClass
	container = containerClass.spawn( containerProperties )
	container.interfaceProperties = containerProperties
	if not container then
		error( "Interface XML invaid: " .. self.name .. ".sinterface. Error: Failed to initialise Container class: " .. tostring( self.class ) .. ". Identifier: " .. tostring( properties.identifier ), 0 )
	end

	self.container = container
	-- callSetters( container, containerClass )

	local children = self.children
	for i, tbl in ipairs( children ) do
		local childView = tbl[1]
		container:insert( childView )

		for k, v in pairs( tbl[2] ) do
			childView[k] = v
		end
	end


	container.event:handleEvent( LoadedInterfaceEvent( container ) )
	return container
end

--[[
	@desc Creates a table of children from the interface file
	@return [table] children -- the table of child views
]]
function Interface.children:get()
	local children = self.children
	if children then return children end
	local function insertTo( childNode, parentContainer )
		local childClass = class.get( childNode.type )
		if not childClass then
			return nil, "Class not found: " .. childNode.type
		elseif not childClass:typeOf( View ) then
			return nil,"Class does not extend 'View': " .. childNode.type
		end

		local childView = childClass()

		if not childView then
			return nil, "Failed to initialise " .. childNode.type .. ". Identifier: " .. tostring( childNode.attributes.identifier )
		end


		if childNode.body and #childNode.body > 0 then
			if not childClass:typeOf( Container ) then
				return nil, "Class does not extend 'Container' but has children: " .. childNode.type
			else
				for i, _childNode in ipairs( childNode.body ) do
					local child, err = insertTo( _childNode, childView )
					if err then return nil, err end
					if child then
						childView:insert( child )
						for k, v in pairs( _childNode.attributes ) do
							child[k] = v
						end
					end
				end
			end
		end

		return childView
	end

	local children = {}
	for i, childNode in ipairs( self.childNodes ) do
		local childView, err = insertTo( childNode )
		if err then error( "Interface XML invaid: " .. self.name .. ".sinterface. Error: " .. err, 0 ) end
		if childView then table.insert( children, { childView, childNode.attributes } ) end
	end
	self.children = children
	return children
end
