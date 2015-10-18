
-- cache the names of the property getter/setter functions
local setters, getters = {}, {}
setmetatable( setters, {
	__index = function( self, k )
		local v = "set" .. k:sub( 1, 1 ):upper() .. k:sub( 2 )
		self[k] = v
		return v
	end;
} )
setmetatable( getters, {
	__index = function( self, k )
		local v = "get" .. k:sub( 1, 1 ):upper() .. k:sub( 2 )
		self[k] = v
		return v
	end;
} )

local classes = {}
local creating
local USE_GLOBALS = true


local class = {}

local classDefined = { dispose = true, can = true, properties = true, alias = true, type = true, typeOf = true, get = true, instance = true, application = true, isDefinedFunction = true, isDefinedProperty = true, isDefined = true, ifDefined = true, ifDefinedProperty = true, ifDefinedFunction = true } -- essentially the properties that instances can access
class.defined = classDefined

function class.get( type )
	return classes[type]
end

-- ensures that all tables that should be unique to an instance are (designated by assigning the table to {} as class a property)
local function uniqueTable( _class, raw )
	for k, v in pairs( _class ) do
		-- if the properties contain any blank tables generate a new table so it's not shared between instances
		if type( v ) == "table" then
			if #v == 0 then
				local keyFound = false
				for k2, v2 in pairs( v ) do
					keyFound = true
					break
				end

				if not keyFound then
					raw[k] = {}
				end
			end
		end
	end
end

-- @static
function class:newSuper( instance, eq, ... )
	local _class = self
	local raw = {}
	local super
	if _class._extends then
		-- super needs it's super too
		super = _class._extends:newSuper( instance, eq, ... )
		raw.super = super
	end

	local definedFunctions = _class.definedFunctions
	local definedProperties = _class.definedProperties
	local definedFunctions = _class.definedFunctions

	uniqueTable( _class, instance )

	raw.class = _class
	raw.instance = instance
	raw.mt = {}

	-- Super needs to be able to act like it's own instance in that it has all of it's own methods and properties, yet the subclass needs to be able to use super as if it were itself
	-- So, for example, setting a value in a super method would actually set the value in the subclass
	-- Likewise, indexing a value that's present 
	-- super:initialise is not automatically called, that's up to the subclass (although, one init will always be called, which might reach in to super)

	raw.mt.__eq = eq

	local _rawSuper = raw.super
	function raw.mt:__index( k )
		if k == "super" then
			-- only ever called if this class doesn't have a super, to prevent super refering back to itself return nil
			return nil
		end

		if definedFunctions[k] then
			-- we want super functions to be callable and not overwritten when accessed directly (e.g. self.super:initialise( ) )
			local f = _class[k]
			return function(_self, ...)
				if _self == raw then
					-- when calling a function on super, the instance needs to be given, but the super needs to be the super's super
					local oldSuper = rawget( instance, "super" )
					rawset( instance, "super", _rawSuper )
					local v = { f( instance, ... ) }
					rawset( instance, "super", oldSuper )
					return unpack( v )
				else
					return f( _self, ... )
				end
			end
		end

		local _instanceValue = instance[k]
		if _instanceValue and type( _instanceValue ) ~= "function" then 
			-- however, we don't want any properties (i.e. mutable values) to come from super if they exist in the instanceclass. we also don't want instance functions called from self.super
			return _instanceValue
		elseif _classValue then
			-- try to use the super's class values
			return _classValue
		end
	end

	function raw.mt:__newindex( k, v )
		if k == nil then error( "Attempt to set value with nil key", 2 ) end
		-- we don't want to save values in super, save them in the subclass
		instance[k] = v
	end

	local rawId = tostring( raw):sub(8 ) -- remove 'table: ' from the id
	function raw.mt:__tostring()
		return 'instance of `' .. _class.className .. '` as super: ' .. rawId
	end

	setmetatable( raw, raw.mt )

	return raw
end

-- @instance
-- returns true if there is a property or function for the given key 
function class:isDefined( key )
	return self.definedBoth[key] or self.class._extends and self.class._extends.definedBoth[key]
end

-- @instance
-- returns true if there is a function for the given key 
function class:isDefinedFunction( key )
	return self.definedFunctions[key] or self.class._extends and self.class._extends.definedFunctions[key]
end

-- @instance
-- returns true if there is a property for the given key 
function class:isDefinedProperty( key )
	return self.definedProperties[key] or self.class._extends and self.class._extends.definedProperties[key]
end

-- @instance
-- returns the value for a key if it's defined
-- return nil if not defined
function class:ifDefined( key )
	return self:isDefined( key ) and self[key]
end

-- @instance
-- returns the value for a property if it's defined
-- return nil if not defined
function class:ifDefinedProperty( key )
	return self:isDefinedProperty( key ) and self[key]
end

-- @instance
-- returns the function if it's defined
-- will ALWAYS return a function, but will do nothing if it's not.
-- will pass self to the function
-- if you want more control use one of the other functions
function class:ifDefinedFunction( key )
	local func = self:isDefinedFunction( key ) and self[key]
	if not func then return function()end end

	return function( ... )
		return func( self, ... )
	end
end

function class:ifFunc( key )
	return self:isDefinedFunction( key )
end

-- @static
function class:new( ... )
	local _class = self
	local raw = {}
	local proxy = { hasInitialised = false } -- the proxy. "self" always needs to be this, NOT raw
	local super
	local definedProperties = _class.definedProperties
	local definedFunctions = _class.definedFunctions
	local definedBoth = _class.definedBoth
	proxy.mt = {}

	raw.class = _class
	raw.mt = {}
	function proxy.mt.__eq( l, r )
		return rawequal( l, r ) or ( rawequal( l.instance, r ) ) or ( rawequal( l, r.instance ) ) or ( rawequal( l.instance, r.instance ) )
	end

	if _class._extends then
		super = _class._extends:newSuper( proxy, proxy.mt.__eq, ... ) -- super needs to be an instance, not class
		raw.super = super
	end

	uniqueTable( _class, raw )

	local _superClass = super and super.class or nil
	local _superSuper = super and super.super or nil
	local superDefinedProperties = _superClass and _superClass.definedProperties
	local superDefinedFunctions = _superClass and _superClass.definedFunctions
	function raw.mt:__index( k )
		local selfDefined = definedBoth[k]
		if selfDefined then
			local rawClassValue = rawget( _class, k )
			-- if rawClassValue ~= nil then -- TODO: maybe this check should be skipped
				-- try to take it from the self class (only, not super)
				return rawClassValue
			-- end
		end

		if _superClass then
			-- check super classes for a value
			if superDefinedFunctions[k] then
				local f = _superClass[k]
				return function(_self, ...)
					if _self == proxy then
						-- when calling a function on super, the instance needs to be given, but the super needs to be the super's super
						local oldSuper = rawget( proxy, "super" )
						rawset( proxy, "super", _superSuper )
						local v = { f( proxy, ... ) }
						rawset( proxy, "super", oldSuper ) -- as it's the proxy setting to nil simply causes it to look in raw again
						return unpack( v )
					else
						-- calling this second
						return f( _self, ... )
					end
				end
			elseif superDefinedProperties[k] then
				-- .size having issues
				-- calling this first
				return _superClass[k]
			end
		end
	
		if classDefined[k] then
			return class[k]
		end
		error( "Attempt to access undeclared property '" .. tostring( k ) .. "' for class '" .. _class.className .. "'", 3 )
	end
	
	setmetatable( raw, raw.mt )

	-- these are to prevent infinite loops in getters and setters ( so, for example, doing self.speed = 10 in setSpeed doesn't cause setSpeed to be called a million times )
	local lockedSetters = {}
	local lockedGetters = {}

	proxy.definedFunctions = definedFunctions
	proxy.definedProperties = definedProperties
	proxy.definedBoth = definedBoth
	proxy.__lockedSetters = lockedSetters
	proxy.__lockedGetters = lockedGetters
	proxy.raw = raw -- not sure about this, although i guess it can't hurt
	-- TODO: the getter/setter ifs could be made more efficient

	-- this basically allows a global filter or notification on all get
	-- local _rawGet = ( raw.get and type( raw.get ) == "function" ) and raw.get or nil
	local getFunc = definedFunctions['get'] and raw.get
	function proxy.mt:__index( k )
		-- this is called each get call for classes that need it (i.e. ThemeOutlet)
		-- it allows them to by pass the default class get behaviour and add their own
		local notLocked = not lockedGetters[k]
		if getFunc and notLocked then
			lockedGetters[k] = true
			local use, value = getFunc( proxy, k )
			lockedGetters[k] = nil
			if use then
				return value
			end	
		end

		-- handle getters
		local getterName = getters[k]
		if definedFunctions[getterName] and notLocked then
			local rawFunc = raw[getterName]
			lockedGetters[k] = true

			-- if the super has been masked then change it back, then change it again
			local oldSuper = rawget( proxy, "super" )
			rawset( proxy, "super", nil ) -- as it's the proxy setting to nil simply causes it to look in raw again
			local v = { rawFunc( proxy ) }
			rawset( proxy, "super", oldSuper )
			local value =  unpack( v )

			lockedGetters[k] = nil
			return value
		end

		-- handle class functions
		if definedFunctions[k] then
			return function( _self, ... )
				if rawequal( _self, proxy ) then
					-- if the super has been masked then change it back, then change it again
					local oldSuper = rawget( proxy, "super" )
					rawset( proxy, "super", nil ) -- as it's the proxy setting to nil simply causes it to look in raw again
					local v = { raw[k]( proxy, ... ) }
					rawset( proxy, "super", oldSuper )
					return unpack( v )
				else
					return raw[k]( _self, ... )
				end
			end
		end

		return raw[k]
	end

	-- TODO: i have no idea what this does
	-- local _rawSet = ( raw.set and type( raw.set ) == "function" ) and raw.set or nil
	local setFunc = definedFunctions['set'] and raw.set
	function proxy.mt:__newindex( k, v )
		if k == nil then error( "Attempt to set value with nil key", 2 ) end
		if v == nil then
			error( "Attempt to set property '" .. k .. "' to nil for class: '" .. _class.className .. "'. Use false instead.", 2 )
		end

		local notLocked = not lockedSetters[k]
		-- this is called each set call for classes that need it (i.e. ThemeOutlet does it for get)
		-- it allows them to by pass the default class set behaviour and add their own
		if setFunc and notLocked then
			lockedSetters[k] = true
			local use, value = setFunc( proxy, k, v )
			lockedSetters[k] = nil
			if use then
				raw[k] = value
				return
			end	
		end

		if classDefined[k] then
			error( 'Cannot set reserved property: ' .. k, 2 )
		end

		if definedFunctions[k] then
			error( 'Cannot overwrite class function: ' .. k, 2 )
		end

		-- setters
		local setterName = setters[k]
		if definedFunctions[setterName] and notLocked then
				-- if the filter wasn't applied, if the set"Key" function is set, call it
			local rawFunc = raw[setterName]
			lockedSetters[k] = true

			-- if the super has been masked then change it back, then change it again
			local oldSuper = rawget( proxy, "super" )
			rawset( proxy, "super", nil ) -- as it's the proxy setting to nil simply causes it to look in raw again
			local v = { rawFunc( proxy, v ) }
			rawset( proxy, "super", oldSuper )

			lockedSetters[k] = nil
			return
		end

		if definedProperties[k] then
			raw[k] = v -- use the passed value if not using a setter
		else
			error( "Attempt to set undeclared property '" .. tostring( k ) .. "' for class '" .. _class.className .. "'", 2 )
		end
	end

	local proxyId = tostring( proxy):sub( 8 ) -- remove 'table: ' from the id
	function proxy.mt:__tostring()
		local identifier = definedProperties['identifier'] and proxy.identifier
		return "instance of `" .. _class.className .. "`" .. (identifier and " ('" .. identifier .. "')" or "") .. ": " .. proxyId
	end

	setmetatable( proxy, proxy.mt )

	if definedProperties.interfaceOutlets then
		local interfaceOutlets = proxy.interfaceOutlets
		for k, v in pairs( _class ) do
			if type( v ) == "table" and v.typeOf and v:typeOf( InterfaceOutlet ) then
				-- link interface outlets, they set the class property to a share instance, so we need to generate a unique one
				-- proxy[k] = false--InterfaceOutlet( v.viewIdentifier or k, v.trackAll, proxy )
				interfaceOutlets[k] = InterfaceOutlet( v.viewIdentifier or k, v.trackAll, k, proxy )
			end
		end
	end

	-- once the class has been created, pass the arguments to the init function for handling
	if definedFunctions.initialise then
		proxy:initialise( ... )
	end
	proxy.hasInitialised = true

	return proxy
end

local lastConstructed
-- constructs an actual class ( NOT instance )
-- @static
function class:construct( _, className )
	local _class = {}
	_class.className = className
	local definedProperties = { } -- the properties that were defined in the table at class construction
	_class.definedProperties = definedProperties
	local definedFunctions = { } -- the class functions defined 
	_class.definedFunctions = definedFunctions
	local definedBoth = {} -- the properties AND functions defiend
	_class.definedBoth = definedBoth

	local mt = { __index = self }
	_class.mt = mt

	function mt:__call( ... )
		return self:new( ... )
	end

	local interfaceOutletActions = definedProperties.interfaceOutletActions
	function mt:__newindex( k, v )
		if self ~= lastConstructed then -- TODO: doesn't work if the function is already made (just overwrites it)
			error( "Attempted to set class property or function '" .. k .. "' after class construction completion for class '" .. className .. "'.", 2 )
		end
		if k == nil then error( "Attempt to set value with nil key", 2 ) end
		local isFunction = type( v ) == "function"
		if isFunction then
			definedFunctions[k] = true
		else
			definedProperties[k] = true
		end
		definedBoth[k] = true

		if definedProperties.interfaceOutletActions and isFunction and #k >= 3 and k:sub( 1, 2 ) == "on" then
			local firstLetter = k:sub( 3, 3 )
			if firstLetter:upper() == firstLetter then
				local property = firstLetter:lower() .. k:sub( 4 )
				local existingValue = _class[property]
				if existingValue and type( existingValue ) == "table" and existingValue:typeOf( InterfaceOutlet ) then
					-- the value is being set to a function, but it's already an InterfaceOutlet. in this circumstance we treat it as an action
					_class.interfaceOutletActions[property] = v
				end
			end
		end

		rawset(_class, k, v)
	end

	function mt:__tostring()
		return 'class: ' .. self.className
	end

	lastConstructed = _class

	setmetatable( _class, mt )

	classes[className] = _class
	_G[className] = _class -- TODO: this is just temporary due to the temporary loading system in Silica
	-- getfenv( 2 )[className] = _class
	creating = _class
	return function( properties )
		creating = nil
		_class:properties( properties, true )
		if _class.constructed then
			_class:constructed()
		end
		return _class
	end
end

-- @static
function class:alias( shorthand, property )
	self.definedProperties[property] = true
	self[ setters[shorthand] ] = function( self, value )
		self[property] = value
	end
	self[ getters[shorthand] ] = function( self )
		return self[property]
	end
end

-- @instance
function class:dispose()end

-- @instance
function class:properties( properties, isConstruct )
	for k, v in pairs( properties ) do
		if isConstruct and type( v ) == "function" then
			error( "Attempted to set function from properties table for key '" .. k .. "' and class '" .. tostring( self ) .. "'", 0 )
		end
		self[k] = v
	end
end

-- @instance
function class:typeOf( _class )
	_self = self.instance or self -- gets the class at the bottom of the chain (i.e. the one who has the most supers above)

	if type( _self ) ~= "table" then
		return false
	elseif _self.class then
		return _self.class:typeOf( _class )
	elseif _self == _class then
		return true
	elseif _self._extends then
		return _self._extends:typeOf( _class )
	end
	return false
end

-- @instance
function class:type()
	local _type = type( self )
	pcall( function()
		_type = getmetatable( self ).__type or _type
	end )
	return _type
end

-- @instance
function class:can( method )
	return type( self[method] ) == "function"
end

setmetatable( class, {
	__call = function( ... ) 
		return class:construct( ... )
	end
} )

local function extends( superName )
	local superClass = classes[superName]
	if not superClass then
		-- try to load the class
		-- TODO: set this system up correctly
		local ourCreating = creating
		__loadClassNamed( superName )
		superClass = classes[superName]
		creating = ourCreating
		lastConstructed = creating
		if not superClass then
			error( 'Super class for `' .. creating.className .. '` was not found: ' .. superName, 0 )
		end
	end

	local definedFunctions = creating.definedFunctions
	local definedProperties = creating.definedProperties
	local definedBoth = creating.definedBoth

	for k, v in pairs( superClass.definedFunctions ) do
		if not definedBoth[k] then
			definedFunctions[k] = true
		end
	end

	for k, v in pairs( superClass.definedProperties ) do
		if not definedBoth[k] then
			definedProperties[k] = true
		end
	end

	creating._extends = superClass
	for k, v in pairs( superClass.mt ) do
		if not creating.mt[k] then
			creating.mt[k] = v
		end
	end
	creating.mt.__index = superClass

	setmetatable( creating, creating.mt )

	return function( properties )
		local _class = creating
		creating = nil
		_class:properties( properties, true )
		if _class.constructed then
			_class:constructed()
		end
		return _class
	end
end

if USE_GLOBALS then
	getfenv().class = class
	getfenv().extends = extends
else
	class.extends = extends
	return class
end
