local classes = {}
local creating
local USE_GLOBALS = true

local class = {}

function class.get( type )
	return classes[type]
end

-- Not sure if 'sub' is the right word here, basically it's the opposite of super
-- @static
function class:newSuper( sub, ... )
	local _class = self
	local raw = {}

	if _class._extends then
		-- super needs it's super too
		raw.super = _class._extends:newSuper( sub, ... )
	end

	raw.class = _class
	raw.mt = {}

	-- Super needs to be able to act like it's own instance in that it has all of it's own methods and properties, yet the subclass needs to be able to use super as if it were itself
	-- So, for example, setting a value in a super method would actually set the value in the subclass
	-- Likewise, indexing a value that's present 
	-- super:init is not automatically called, that's up to the subclass (although, one init will be called, which might reach in to super)

	function raw.mt:__index( k )
		if k == 'super' then
			-- this class doesn't have a super, to prevent super refering back to itself return nil
			return nil
		elseif _class[k] and type( _class[k] ) == 'function' then
			-- we want super functions to be callable and not overwritten when accessed directly (e.g. self.super:init())
			return _class[k]
		elseif sub[k] then
			-- however, we don't want any properties (i.e. mutable values) to come from super if they exist in the subclass
			return sub[k]
		else
			-- otherwise use the super's class values
			return _class[k]
		end
	end

	function raw.mt:__newindex( k, v )
		-- we don't want to save values in super, save them in the subclass
		sub[k] = v
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

	if _class._extends then
		raw.super = _class._extends:newSuper( proxy, ... ) -- super needs to be an instance, not class
	end

	raw.class = _class
	raw.mt = {}

	function raw.mt:__index( k )
		if _class[k] then
			-- try to take it from the class
			-- TODO: this might have issues regarding super overriding a 'class' method and it being ignored. it's unlikely though I guess
			return _class[k]
		end

		local super = rawget(raw, 'super')
		if super and super.class and super.class[k] then
			-- otherwise, check super classes for a value
			return super.class[k]
		end
	end

	-- I think that given how we need to make super work, we can't really do this anymore
	setmetatable( raw, raw.mt )

	-- these are to prevent infinite loops in getters and setters ( so, for example, doing self.speed = 10 in setSpeed doesn't cause setSpeed to be called a million times )
	local lockedSetters = {}
	local lockedGetters = {}

	proxy.raw = raw -- not sure about this, although i guess it can't hurt
	proxy.mt = {}

	function proxy.mt:__index( k )
		-- this basically allows a global filter or notification on all get
		if not lockedGetters[k] and raw.get and type( raw.get ) == 'function' then
			lockedGetters[k] = true
			local use, value = raw.get( proxy, k )
			lockedGetters[k] = nil
			if use then
				return value
			end	
		end

		-- basically, if the get'Key' function is set, return it's value
		-- non-function properties can't use it, because, well, it's just futile really
		local getFunc = 'get' .. k:sub( 1, 1 ):upper() .. k:sub( 2, -1 )
		if not lockedGetters[k] and type( raw[k] ) ~= 'function' and raw[getFunc] and type( raw[getFunc] ) == 'function' then
			lockedGetters[k] = true
			local value = raw[getFunc]( proxy )
			lockedGetters[k] = nil
			return value
		else
			return raw[k]
		end
	end

	function proxy.mt:__newindex( k, v )
		if k == 'super' or k == 'class' then
			error( 'Cannot set reserved property: ' .. k)
		end

		-- this basically allows a global filter or notification on all sets
		if not lockedSetters[k] and type( raw.set ) and type( raw.set ) == 'function' then
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
		if not lockedSetters[k] and type( raw[k] ) ~= 'function' and raw[setFunc] and type( raw[setFunc] ) == 'function' then
			lockedSetters[k] = true
			raw[setFunc]( proxy, v )
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

	-- use the setters with all the starting values. this will be useful, trust me
	local prepared = {}
	local function prepare( obj )
		for k, v in pairs( obj.class ) do
			local setFunc = 'set' .. k:sub( 1, 1 ):upper() .. k:sub( 2, -1 )
			if not prepared[k] and k ~= 'class' and k ~= 'mt' and  k ~= 'super' and type( raw[setFunc] ) == 'function' and type( raw[k] ) ~= 'function' then
				prepared[k] = true
				proxy[k] = v
			end
		end

		if obj.super then
			prepare( obj.super )
		end
	end

	prepare( raw )

    -- once the class has been created, pass the arguments to the init function for handling
    if proxy.init and type( proxy.init ) == 'function' then
    	proxy:init( ... )
    end

	return proxy
end

-- constructs an actual class ( NOT instance )
-- @static
function class:construct( _, className ) -- for some reason self is passed twice, not sure why
    local _class = {}
    _class.className = className

    local mt = { __index = self }
    _class.mt = mt

    function mt:__call( ... )
        return self:new( ... )
    end

	local classId = tostring(_class):sub(7) -- remove 'table: ' from the id
 	function mt:__tostring()
    	return 'class: ' .. self.className
    end

    setmetatable( _class, mt )

    classes[className] = _class
    getfenv( 2 )[className] = _class
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
    	self[k] = v
    end
end

-- @instance
function class:typeOf( _class )
	if type( self ) ~= "table" then
		return false
	elseif self.class then
		return self.class:typeOf( _class )
	elseif self == _class then
		return true
	elseif self._extends then
		return self._extends:typeOf( _class )
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
        error( 'Super class for `' .. creating.className .. '` was not found: ' .. superName )
    end

    creating._extends = classes[superName]
	for k, v in pairs( classes[superName].mt ) do
		creating.mt[k] = v
	end
    creating.mt.__index = classes[superName]

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


--- tests

class 'Object' {
    x = 1;
    fruit = 'pear';
}

function Object:init()
	self.fruit = 'apple'
end

function Object:setFruit( fruit )
	self.fruit = fruit 
	print("It's " .. fruit .. ' time!')
end

function Object:eat()
	print(self.fruit)
end

class 'Button' extends 'Object' {
    y = 2;
}

function Button:init( fruit ) -- again, we need to figure out the best way of doing arguments that works with super classes
	self.super:init()
	if fruit then
		self.fruit = fruit
	end
end

local button1 = Button( 'orange' )
button1:eat() -- orange

local button2 = Button()
button2:eat() -- apple, if self.super:init isn't called this is pear

class 'Something' extends 'Button' {
	z = 3;
}

local something = Something()
print(something.x) -- 1
print(something.y) -- 2
print(something.z) -- 3
something:eat() -- apple (because self.super:init was called as Button's init was used)
