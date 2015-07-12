
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

	uniqueTable( _class, instance )

	raw.class = _class
	raw.instance = instance
	raw.mt = {}

	-- Super needs to be able to act like it's own instance in that it has all of it's own methods and properties, yet the subclass needs to be able to use super as if it were itself
	-- So, for example, setting a value in a super method would actually set the value in the subclass
	-- Likewise, indexing a value that's present 
	-- super:init is not automatically called, that's up to the subclass (although, one init will always be called, which might reach in to super)

	raw.mt.__eq = eq

	local _rawSuper = raw.super
	function raw.mt:__index( k )
		if k == "super" then
			-- only ever called if this class doesn't have a super, to prevent super refering back to itself return nil
			return nil
		end

		local _classValue = _class[k]
		if _classValue and type( _classValue ) == "function" then
			-- we want super functions to be callable and not overwritten when accessed directly (e.g. self.super:init( ) )
			local f = _classValue
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

-- @static
function class:new( ... )
	local _class = self
	local raw = {}
	local proxy = { hasInit = false } -- the proxy. "self" always needs to be this, NOT raw
	local super
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
	function raw.mt:__index( k )
		local rawClassValue = rawget( _class, k )
		if rawClassValue ~= nil then
			-- try to take it from the self class (only, not super)
			return rawClassValue
		end

		if _superClass then
			local f = _superClass[k]
			if f then
				-- otherwise, check super classes for a value
				if type( f ) == "function" then
					return function(_self, ...)
						if _self == proxy then
							-- when calling a function on super, the instance needs to be given, but the super needs to be the super's super
							local oldSuper = rawget( proxy, "super" )
							rawset( proxy, "super", _superSuper )
							local v = { f( proxy, ... ) }
							rawset( proxy, "super", oldSuper ) -- as it's the proxy setting to nil simply causes it to look in raw again
							return unpack( v )
						else
							return f( _self, ... )
						end
					end
				else
					return f
				end
			end
		end

		return class[k]
	end
	
	setmetatable( raw, raw.mt )

	-- these are to prevent infinite loops in getters and setters ( so, for example, doing self.speed = 10 in setSpeed doesn't cause setSpeed to be called a million times )
	local lockedSetters = {}
	local lockedGetters = {}

	proxy.__lockedSetters = lockedSetters
	proxy.__lockedGetters = lockedGetters
	proxy.raw = raw -- not sure about this, although i guess it can't hurt
	-- TODO: the getter/setter ifs could be made more efficient

	local _rawGet = ( raw.get and type( raw.get ) == "function" ) and raw.get or nil
	function proxy.mt:__index( k )
		local isRawFunc
		local rawV
		if not lockedGetters[k] then

			-- this basically allows a global filter or notification on all get
			if _rawGet then
				lockedGetters[k] = true
				local use, value = _rawGet( proxy, k )
				lockedGetters[k] = nil
				if use then
					return value
				end	
			end

			-- basically, if the get"Key" function is set, return it's value
			-- non-function properties can't use it, because, well, it's just futile really
			-- 
			rawV = raw[k]
			isRawFunc = type( rawV ) == "function"
			if not isRawFunc then
				local rawFunc = raw[getters[k]]
				if rawFunc and type( rawFunc ) == "function" then
					lockedGetters[k] = true

					local value = rawFunc( proxy )
					-- if the super has been masked then change it back, then change it again
					local oldSuper = rawget( proxy, "super" )
					rawset( proxy, "super", nil ) -- as it's the proxy setting to nil simply causes it to look in raw again
					local v = { rawFunc( proxy ) }
					rawset( proxy, "super", oldSuper )
					local value =  unpack( v )

					lockedGetters[k] = nil
					return value
				end
			end
		end

		rawV = ( rawV == nil ) and raw[k] or rawV
		isRawFunc = ( isRawFunc == nil ) and type( rawV ) == "function" or isRawFunc

		if isRawFunc then
			return function( _self, ... )
				if rawequal( _self, proxy ) then
					-- if the super has been masked then change it back, then change it again
					local oldSuper = rawget( proxy, "super" )
					rawset( proxy, "super", nil ) -- as it's the proxy setting to nil simply causes it to look in raw again
					local v = { rawV( proxy, ... ) }
					rawset( proxy, "super", oldSuper )
					return unpack( v )
				else
					return rawV( _self, ... )
				end
			end
		end

		return rawV
	end

	local _rawSet = ( raw.set and type( raw.set ) == "function" ) and raw.set or nil
	function proxy.mt:__newindex( k, v )
		if k == "super" or k == "class" then
			error( 'Cannot set reserved property: ' .. k, 0 )
		end

		if not lockedSetters[k] then
			-- TODO: maybe don't make the setter call if the value hasn't changed
			-- this basically allows a global filter or notification on all sets
			if _rawSet then
				lockedSetters[k] = true
				local use, value = _rawSet( proxy, k, v )
				lockedSetters[k] = nil
				if use then
					raw[k] = value
					return
				end	
			end

			-- if the filter wasn't applied, if the set"Key" function is set, call it
			local isRawFunc = type( raw[k] ) == "function"
			if not isRawFunc then
				local rawFunc = raw[setters[k]]
				if rawFunc and type( rawFunc ) == "function" then
					lockedSetters[k] = true

					-- if the super has been masked then change it back, then change it again
					local oldSuper = rawget( proxy, "super" )
					rawset( proxy, "super", nil ) -- as it's the proxy setting to nil simply causes it to look in raw again
					local v = { rawFunc( proxy, v ) }
					rawset( proxy, "super", oldSuper )

					lockedSetters[k] = nil
					return
				end
			end
		end

		raw[k] = v -- use the passed value if not using a setter
	end

	local proxyId = tostring( proxy):sub( 8 ) -- remove 'table: ' from the id
	function proxy.mt:__tostring()
		local identifier = proxy.identifier
		return "instance of `" .. _class.className .. "`" .. (identifier and " ('" .. identifier .. "')" or "") .. ": " .. proxyId
	end

	setmetatable( proxy, proxy.mt )

	for k, v in pairs( _class ) do
		if type( v ) == "table" and v.typeOf and v:typeOf( InterfaceOutlet ) then
			-- link interface outlets, they set the class property to a share instance, so we need to generate a unique one
			proxy[k] = InterfaceOutlet( v.viewIdentifier or k, v.trackAll, proxy )
		end
	end

	-- once the class has been created, pass the arguments to the init function for handling
	if proxy.init and type( proxy.init ) == "function" then
		proxy:init( ... )
	end
	proxy.hasInit = true

	return proxy
end

-- constructs an actual class ( NOT instance )
-- @static
function class:construct( _, className )
	local _class = {}
	_class.className = className
	_class.interfaceOutletActions = { 1 }

	local mt = { __index = self }
	_class.mt = mt

	function mt:__call( ... )
		return self:new( ... )
	end

	function mt:__newindex( k, v )
		if type( v ) == "function" and #k >= 3 and k:sub( 1, 2 ) == "on" then
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

	setmetatable( _class, mt )

	classes[className] = _class
	_G[className] = _class -- TODO: this is just temporary due to the temporary loading system in Silica
	-- getfenv( 2 )[className] = _class
	creating = _class

	return function( properties )
		creating = nil
		_class:properties( properties )
		if _class.constructed then
			_class:constructed()
		end
		return _class
	end
end

-- @erm, class instance?
function class:alias( shorthand, property )
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
function class:properties( properties )
	for k, v in pairs( properties ) do
		self[k] = v
	end
end

-- @instance
function class:typeOf( _class )
	_self = self.instance or self -- gets the class at the bottom of the chain (i.e. the one who has the most supers above)

	if type( _self ) ~= "table" then -- will this ever be true?? class.typeOf( "", MyClass )
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
	if not classes[superName] then
		-- try to load the class
		-- TODO: set this system up correctly
		local ourCreating = creating
		loadName( superName )
		creating = ourCreating
		if not classes[superName] then
			error( 'Super class for `' .. creating.className .. '` was not found: ' .. superName, 0 )
		end
	end

	creating._extends = classes[superName]
	for k, v in pairs( classes[superName].mt ) do
		if not creating.mt[k] then
			creating.mt[k] = v
		end
	end
	creating.mt.__index = classes[superName]
	-- function(self, k)
	-- 	return classes[superName][k]
	-- end
	-- local super = classes[superName]
 --    function creating.mt:__index( k )
 --    	local v = super[k]

 --    	if type( rawget( super, k ) ) == "function" then -- rawget is used just to prevent calls compounding
 --    		return function(_, ...)
 --    			return 
 --    		end
 --    	else
 --    		return v
 --    	end
 --    end

	setmetatable( creating, creating.mt )

	return function( properties )
		local _class = creating
		creating = nil
		_class:properties( properties )
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
