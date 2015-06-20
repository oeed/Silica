
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
		if type( v ) == 'table' then
			if v.typeOf and v:typeOf( InterfaceOutlet ) then
	    		-- InterfaceOutlets kinda cheat, they set the class property to a share instance, so we need to generate a unique one
	    		raw[k] = InterfaceOutlet( v.viewIdentifier, v.trackAll )
	    	elseif #v == 0 then
				local keyFound = false
				for k2, v2 in pairs(v) do
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

	function raw.mt:__index( k )
		if k == 'super' then
			-- only ever called if this class doesn't have a super, to prevent super refering back to itself return nil
			return nil
		elseif _class[k] and type( _class[k] ) == 'function' then
			-- we want super functions to be callable and not overwritten when accessed directly (e.g. self.super:init())
			local f = _class[k]
			return function(_self, ...)
				if _self == raw then
					-- when calling a function on super, the instance needs to be given, but the super needs to be the super's super
					local oldSuper = instance.super
					rawset( instance, 'super', raw.super )
					local v = { f( instance, ... ) }
					rawset( instance, 'super', oldSuper )
					return unpack( v )
				else
					return f( _self, ... )
				end
			end
			-- return _class[k]
		elseif instance[k] then
			-- however, we don't want any properties (i.e. mutable values) to come from super if they exist in the instanceclass
			return instance[k]
		elseif _class[k] then
			-- try to use the super's class values
			return _class[k]
		-- elseif super and super.class and super.class[k] then
		-- 	-- otherwise, check super's super classes for a value
		-- 	if type( super.class[k] ) == 'function' then
		-- 		local f = super.class[k]
		-- 		return function(_self, ...)
		-- 			if _self == instance then
		-- 				return f(super, ...)
		-- 			else
		-- 				return f(_self, ...)
		-- 			end
		-- 		end
		-- 	else
		-- 		return super.class[k]
		-- 	end
		end
	end

	function raw.mt:__newindex( k, v )
		-- we don't want to save values in super, save them in the subclass
		instance[k] = v
	end

	local rawId = tostring(raw):sub(8) -- remove 'table: ' from the id
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
	local proxy = {} -- the proxy. 'self' always needs to be this, NOT raw
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

	function raw.mt:__index( k )
		local rawClassValue = rawget( _class, k )
		if rawClassValue ~= nil then
			-- try to take it from the self class (only, not super)
			return rawClassValue
		end

		if super and super.class and super.class[k] then
			-- otherwise, check super classes for a value
			if type( super.class[k] ) == 'function' then
				-- TODO: if the value is a function we need to call it on super, not self.
				local f = super.class[k]
				return function(_self, ...)
					if _self == proxy then
						-- when calling a function on super, the instance needs to be given, but the super needs to be the super's super
						local oldSuper = proxy.super
						rawset( proxy, 'super', oldSuper.super )
						local v = { f( proxy, ... ) }
						rawset( proxy, 'super', oldSuper )
						return unpack( v )
					else
						return f( _self, ... )
					end
				end
			else
				return super.class[k]
			end
		end

		return class[k]
	end
	
	setmetatable( raw, raw.mt )

	-- these are to prevent infinite loops in getters and setters ( so, for example, doing self.speed = 10 in setSpeed doesn't cause setSpeed to be called a million times )
	local lockedSetters = {}
	local lockedGetters = {}

	proxy.raw = raw -- not sure about this, although i guess it can't hurt

	function proxy.mt:__index( k )
		-- TODO: if we find a use for this we'll turn it on. but otherwise it probably needs to be made more efficient
		-- this basically allows a global filter or notification on all get
		-- if not lockedGetters[k] and raw.get and type( raw.get ) == 'function' then
		-- 	lockedGetters[k] = true
		-- 	local use, value = raw.get( proxy, k )
		-- 	lockedGetters[k] = nil
		-- 	if use then
		-- 		return value
		-- 	end	
		-- end

		-- basically, if the get'Key' function is set, return it's value
		-- non-function properties can't use it, because, well, it's just futile really
		local getFunc = 'get' .. k:sub( 1, 1 ):upper() .. k:sub( 2, -1 )
		local rawV = raw[k]
		local rawFunc = raw[getFunc]
		if not lockedGetters[k] and type( rawV ) ~= 'function' and rawFunc and type( rawFunc ) == 'function' then
			lockedGetters[k] = true
			local value = rawFunc( proxy )
			lockedGetters[k] = nil
			return value
		else
			return rawV
		end
	end

	function proxy.mt:__newindex( k, v )
		if k == 'super' or k == 'class' then
			error( 'Cannot set reserved property: ' .. k)
		end

		-- this basically allows a global filter or notification on all sets
		if not lockedSetters[k] and type( raw.set ) == 'function' then
			lockedSetters[k] = true
			local use, value = raw.set( proxy, k, v )
			lockedSetters[k] = nil
			if use then
				raw[k] = value
				return
			end	
		end

		-- if the filter wasn't applied, if the set'Key' function is set, call it
		local setFunc = 'set' .. k:sub( 1, 1 ):upper() .. k:sub( 2, -1 )
		local rawFunc = raw[setFunc]
		if not lockedSetters[k] and type( raw[k] ) ~= 'function' and rawFunc and type( rawFunc ) == 'function' then
			lockedSetters[k] = true
			rawFunc( proxy, v )
			lockedSetters[k] = nil
		else
			raw[k] = v -- use the passed value if not using the setter
		end
	end

	local proxyId = tostring(proxy):sub(8) -- remove 'table: ' from the id
	function proxy.mt:__tostring()
    	return 'instance of `' .. _class.className .. '`: ' .. proxyId
    end

	setmetatable( proxy, proxy.mt )

    -- once the class has been created, pass the arguments to the init function for handling
    if proxy.init and type( proxy.init ) == 'function' then
    	proxy:init( ... )
    end

	-- use the setters with all the starting values. this will be useful, trust me
	local prepared = {}
	local function prepare( obj )
		local hasSet = type( obj.set ) == 'function'
		for k, _ in pairs( obj.class ) do
			local setFunc = 'set' .. k:sub( 1, 1 ):upper() .. k:sub( 2, -1 )
			local v = obj[k] -- TODO: sometimes this is nil when it shouldn't be

			if not prepared[k] and k ~= 'class' and k ~= 'mt' and  k ~= 'super' and type( v ) ~= 'function' and (hasSet or type( raw[setFunc] ) == 'function') then
				prepared[k] = true
				proxy[k] = v
			end
		end

		if obj.super then
			prepare( obj.super )
		end
	end

	prepare( raw )

	return proxy
end

-- constructs an actual class ( NOT instance )
-- @static
function class:construct( _, className )
    local _class = {}
    _class.className = className

    local mt = { __index = self }
    _class.mt = mt

    function mt:__call( ... )
        return self:new( ... )
    end

    -- function mt:__newindex( k, v )
    -- 	rawset(_class, k, v)
    -- end

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

-- @instance
function class:properties( properties )
    for k, v in pairs( properties ) do
    	if type( self[k] ) == 'number' then
    		v = tonumber( v )
    	end
    	
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
        	error( 'Super class for `' .. creating.className .. '` was not found: ' .. superName )
        end
    end

    creating._extends = classes[superName]
	for k, v in pairs( classes[superName].mt ) do
		if not creating.mt[k] then
			creating.mt[k] = v
		end
	end
	creating.mt.__index = --classes[superName]
	function(self, k)
		return classes[superName][k]
	end
	-- local super = classes[superName]
 --    function creating.mt:__index( k )
 --    	local v = super[k]

 --    	if type( rawget( super, k ) ) == 'function' then -- rawget is used just to prevent calls compounding
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
