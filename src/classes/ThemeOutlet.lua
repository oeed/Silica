
class "ThemeOutlet" {
	style = "default";
	owner = false;
	ownerClass = false;
	connections = {};
}

--[[
	@constructor
	@desc Creates a ThemeOutlet
	@param [class] owner -- the outlet owner
]]
function ThemeOutlet:initialise( owner )
	self.owner = owner
	self.ownerClass = owner.class
	owner.event:connectGlobal( ThemeChangedInterfaceEvent, self.onThemeChange, nil, self )
end

--[[
	@desc Returns the value for the given key, using the current theme style
	@param [string] key -- the key of the value
	@return value -- the value
]]
-- function ThemeOutlet:get( key )
-- 	if key == "class" or self.definedBoth[key] or class.defined[key] then return false end
-- 	return true, self:themeValue( key, self.style )
-- end

--[[
	@desc Connect a class value to a theme value, updating it each time the style is changed
	@param [class] _class -- the class to connect the value to
	@param [string] classKey -- the key of the class' value
	@param [string] key -- the key of the value
]]
function ThemeOutlet:connect( _class, classKey, key )
	self:disconnect( _class, classKey, key )
	key = key or classKey
	if not _class:isDefinedProperty( classKey ) then
		error( "Attempted to connect theme to undefined property '" .. classKey .. "' for object '" .. tostring( _class ) .. "'", 4 )
	end
	table.insert( self.connections, { _class, classKey, key, _class[classKey] } )
	_class[classKey] = self:value( key, style )
end

--[[
	@desc Disconnect a class value from a theme value
	@param [class] _class -- the class that was connected
	@param [string] classKey -- the key of the class' value
	@param [string] key -- the key of the value
]]
function ThemeOutlet:disconnect( _class, classKey, key )
	key = key or classKey
	for i, connection in pairs( self.connections ) do
		if _class == connection[1] and classKey == connection[2] and key == connection[3] then
			self.connections[i] = nil
			_class[classKey] = connection[4]
			return
		end
	end
end

--[[
	@desc Fired when the theme changes, updates the value
	@param [string] style -- the style name
]]
function ThemeOutlet:onThemeChange( Event event, Event.phases phase )
	local style = self.style
	for i, connection in pairs( self.connections ) do
		connection[1][connection[2]] = self:value( connection[3], style )
	end

end

--[[
	@desc Sets the current style (pressed, checked, disabled, etc) for the owner
	@param [string] style -- the style name
]]
function ThemeOutlet.style:set( style )
	self.style = style
	for i, connection in pairs( self.connections ) do
		connection[1][connection[2]] = self:value( connection[3], style )
	end
end

--[[
	@desc Returns the value for the current theme given the property name and style)
	@param [string] propertyName -- the name of the property
	@param [string] styleName -- defaults to the current style
	@return themeValue -- the theme value
]]
function ThemeOutlet:value( valueName, styleName )
	return Theme.static.active:value( self.ownerClass, valueName, styleName or self.style )
end