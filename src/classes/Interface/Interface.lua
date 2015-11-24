
local RESERVED_NAMES = { super = true, static = true, metatable = true, class = true, raw = true, application = true, className = true, typeOf = true, isDefined = true, isDefinedProperty = true, isDefinedFunction = true }
local TYPETABLE_ALLOWS_NIL = 4

class "Interface" {

	name = String; -- the name of the interface (the file name without the extension)
	container = Container.allowsNil; -- if you want to generate a container based on the interface (i.e. not use the properties and children for an already made interface) you can use the value
	containerProperties = Table; -- the properties given to the root element
	children = Table.allowsNil; -- the children of the interface
	containerClass = false; -- TODO: Class type -- the class type of the interface
	childNodes = Table; -- the nodes from the root elements XML

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
	container = containerClass.spawn( true, containerProperties )
	if not container then
		error( "Interface XML invaid: " .. self.name .. ".sinterface. Error: Failed to initialise Container class: " .. tostring( self.class ) .. ". Identifier: " .. tostring( properties.identifier ), 0 )
	end

	self.container = container
	-- callSetters( container, containerClass )
	local readyEvent = ReadyInterfaceEvent()
	local children = self.children
	for i, tbl in ipairs( children ) do
		local childView = tbl[1]
		container:insert( childView )

		for k, v in pairs( tbl[2] ) do
			childView[k] = v
		end
		childView.event:handleEvent( readyEvent )

        -- check for any nil values that aren't allowed to be nil
        local class = childView.class
        local className = class.className
        local instanceProperties = class.instanceProperties
        for k, v in pairs( class.instanceDefinedProperties ) do
            if not RESERVED_NAMES[v] and k == v then -- i.e. it's not an alias
                local value = childView[k] -- TODO: maybe this should use instance[k] so getters are called
                if value == nil and not instanceProperties[k][TYPETABLE_ALLOWS_NIL] then
                    error( className .. "." .. k .. " was nil after initialisation and ReadyInterfaceEvent, but type does not specify .allowsNil" )
                end
            end
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

		local childView = childClass.spawn( true )

		if not childView then
			return nil, "Failed to initialise " .. childNode.type .. ". Identifier: " .. tostring( childNode.attributes.identifier )
		end

		local readyEvent = ReadyInterfaceEvent()
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
						childView.event:handleEvent( readyEvent )

					    -- check for any nil values that aren't allowed to be nil
					    local class = child.class
					    local instanceProperties = class.instanceProperties
					    for k, v in pairs( class.instanceDefinedProperties ) do
					        if not RESERVED_NAMES[v] and k == v then -- i.e. it's not an alias
					            local value = child[k] -- TODO: maybe this should use instance[k] so getters are called
					            if value == nil and not instanceProperties[k][TYPETABLE_ALLOWS_NIL] then
					                error( name .. "." .. k .. " was nil after initialisation and ReadyInterfaceEvent, but type does not specify .allowsNil" )
					            end
					        end
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
