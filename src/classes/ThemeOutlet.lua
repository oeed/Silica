
class "ThemeOutlet" {
	style = "default";
	owner = nil;
	ownerClass = nil;
	connections = {};
}

--[[
	@constructor
	@desc Creates a ThemeOutlet
	@param [class] owner -- the outlet owner
]]
function ThemeOutlet:init( owner )
	self.owner = owner
	self.ownerClass = owner.class
end

--[[
	@instance
	@desc Returns the value for the given key, using the current theme style
	@param [string] key -- the key of the value
	@return value -- the value
]]
function ThemeOutlet:get( key )
	if key == 'themeValue' or self[key] or key == 'instance' then return false end
	return true, self:themeValue( key, self.style )
end

--[[
	@instance
	@desc Connect a class value to a theme value, updating it each time the style is changed
	@param [class] _class -- the class to connect the value to
	@param [string] classKey -- the key of the class' value
	@param [string] key -- the key of the value
]]
function ThemeOutlet:connect( _class, classKey, key )
	self:disconnect( _class, classKey, key )
	key = key or classKey
	table.insert( self.connections, { _class, classKey, key, _class[classKey] } )
	_class[classKey] = self:themeValue( key, style )
end

--[[
	@instance
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
	@instance
	@desc Sets the current style (pressed, checked, disabled, etc) for the owner
	@param [string] style -- the style name
]]
function ThemeOutlet:setStyle( style )
	self.style = style

	for i, connection in ipairs( self.connections ) do
		connection[1][connection[2]] = self:themeValue( connection[3], style )
	end
end

--[[
	@instance
	@desc Returns the value for the current theme given the property name and style)
	@param [string] propertyName -- the name of the property
	@param [string] styleName -- default is 'default', the name of the style
	@return themeValue -- the theme value
]]
function ThemeOutlet:themeValue( valueName, styleName )
	return Theme.active:value( self.ownerClass, valueName, styleName )
end