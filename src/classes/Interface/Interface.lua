
local RESERVED_NAMES = { super = true, static = true, metatable = true, class = true, raw = true, application = true, className = true, typeOf = true, isDefined = true, isDefinedProperty = true, isDefinedFunction = true }
local TYPETABLE_ALLOWS_NIL = 4

class "Interface" {

	name = String; -- the name of the interface (the file name without the extension)
	container = Container; -- if you want to generate a container based on the interface (i.e. not use the properties and children for an already made interface) you can use the value
	containerNode = Table; -- the properties given to the root element

}

--[[
	@constructor
	@desc Creates and loads an interface with the given name
	@param [string] interfaceName -- the file name of the interface
]]
function Interface:initialise( interfaceName, extend, containerView )
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
			self.containerNode = rootNode
			self:loadContainer( containerView )
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
function Interface:loadContainer( containerView )
	local loadedEvent = LoadedInterfaceEvent()
	local function loadChild( childNode, parentContainer, childView )
		local childClass = class.get( childNode.type )
		if not childClass then
			return nil, "Class not found: " .. childNode.type
		elseif not childClass:typeOf( View ) then
			return nil,"Class does not extend 'View': " .. childNode.type
		end

		childView = childView or childClass.spawn( true )
		if not childView then
			return nil, "Failed to initialise " .. childNode.type .. ". Identifier: " .. tostring( childNode.attributes.identifier )
		end

		local identifier = childNode.attributes.identifier
		if identifier then
			childView.identifier = identifier
		end
		
		if parentContainer then
			parentContainer:insert( childView )
		end
		
		for k, v in pairs( childNode.attributes ) do
			childView[k] = v
		end

		local children = {}
		if childNode.body and #childNode.body > 0 then
			if not childClass:typeOf( Container ) then
				return nil, "Class does not extend 'Container' but has children: " .. childNode.type
			else
				for i, _childNode in ipairs( childNode.body ) do
					table.insert( children, loadChild( _childNode, childView ) )
				end
			end
		end

		childView.event:handleEvent( loadedEvent )

	    -- check for any nil values that aren't allowed to be nil
	    local instanceProperties = childClass.instanceProperties
	    for k, v in pairs( childClass.instanceDefinedProperties ) do
	        if not RESERVED_NAMES[v] and k == v and not instanceProperties[k][TYPETABLE_ALLOWS_NIL] then -- i.e. it's not an alias
	            if childView[k] == nil then -- TODO: maybe this should use instance[k] so getters are called
	                error( childNode.type .. "." .. k .. " was nil after initialisation and ReadyInterfaceEvent, but type does not specify .allowsNil" )
	            end
	        end
	    end

		return childView
	end

	local container = loadChild( self.containerNode, nil, containerView )
	self.container = container
end

--[[
	@desc Must be called when the container has been assigned to, for example, Application.container
	@return Any returnedValue
]]
function Interface:ready()
	local container = self.container
	container.event:handleEvent( ReadyInterfaceEvent( container ) )
end
