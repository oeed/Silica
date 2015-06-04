local class = {}
local classes = {}

local creating
local USE_GLOBALS = true

-- @static
function class:new( ... )
	local newRaw = {}

	newRaw.super = self._extends --:new( ... ) -- not sure here, do we want super to be a class or instance? i'll do some testing
	newRaw.class = self

	setmetatable( newRaw, { __index = self } )

	-- these are to prevent infinite loops in getters and setters ( so, for example, doing self.speed = 10 in setSpeed doesn't cause setSpeed to be called a million times )
	local lockedSetters = {}
	local lockedGetters = {}

	local newProxy = {} -- the proxy. 'self' always needs to be this, NOT newRaw
	setmetatable( newProxy, {
		__index = function( t, k )
			-- this basically allows a global filter or notification on all get
			if not lockedGetters[k] and newRaw.get and type( newRaw.get ) == 'function' then
				lockedGetters[k] = true
				local use, value = newRaw.get( newProxy, k )
				lockedGetters[k] = nil
				if use then
					return value
				end	
			end

			-- basically, if the get'Key' function is set, return it's value
			-- names are capitalised, so .name becomes getName; This might cause a few issues regarding collisions, but really, how many ( good ) coders are using .name and .Name
			-- non-function properties can't use it, because, well, it's just futile really
			local getFunc = 'get' .. k:sub( 1, 1 ):upper() .. k:sub( 2, -1 )
			if not lockedGetters[k] and type( newRaw[k] ) ~= 'function' and newRaw[getFunc] and type( newRaw[getFunc] ) == 'function' then
				lockedGetters[k] = true
				local value = newRaw[getFunc]( newProxy )
				lockedGetters[k] = nil
				return value
			else
				return newRaw[k]
			end
		end,

		__newindex = function ( t,k,v )
			-- this basically allows a global filter or notification on all sets
			if not lockedSetters[k] and type( newRaw.set ) and type( newRaw.set ) == 'function' then
				lockedSetters[k] = true
				local use, value = newRaw.set( newProxy, k, v )
				lockedSetters[k] = nil
				if use then
					newRaw[k] = value
					return
				end	
			end

			-- if the filter wasn't applied, if the set'Key' function is set, call it
			local setFunc = 'set' .. k:sub( 1, 1 ):upper() .. k:sub( 2, -1 )
			if not lockedSetters[k] and type( newRaw[k] ) ~= 'function' and newRaw[setFunc] and type( newRaw[setFunc] ) == 'function' then
				lockedSetters[k] = true
				newRaw[setFunc]( newProxy, v )
				lockedSetters[k] = nil
			else
				newRaw[k] = v -- use the passed value if not using the setter
			end
		end
	} )

	-- use the setters with all the starting values
	for k, v in pairs( self ) do
		if type( self[k] ) ~= 'function' then
			newProxy[k] = v
		end
	end

    -- once the class has been created, pass the arguments to the init function for handling
    if newProxy.init and type( newProxy.init ) == 'function' then
    	newProxy:init( ... )
    end

	return newProxy
end

-- constructs an actual class ( NOT instance )
-- @static
function class:construct( _, name ) -- for some reason self is passed twice, not sure why
    local _class = {}
    _class.name = name

    local mt = { __index = self }
    _class.mt = mt

    function mt:__call( ... )
        return self:new( ... )
    end

 	function mt:__tostring()
    	return self.name
    end

    setmetatable( _class, mt )

    classes[name] = _class
    getfenv( 2 )[name] = _class
    creating = _class

    return function( properties )
    	creating = nil
	_class:properties( properties )
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
        -- TODO: add an autoloading here to load the class if it's not found
        error( 'Super class for `' .. creating.name .. '` was not found: ' .. superName )
    end

    creating._extends = classes[superName]
	for k, v in pairs( classes[superName].mt ) do
		creating.mt[k] = v
	end
    creating.mt.__index = classes[superName]

    setmetatable( creating, creating.mt )

    return function( properties )
    	local _class = creating
        creating:properties( properties )
        creating = nil
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

class "Object" {
    x = 5;
}

function Object:init( properties ) -- we can decided how to structure the arguments to new later
	properties = properties or {}
	for k, v in pairs( properties ) do
		self[k] = v
	end
end

class "Button" extends 'Object' {
    y = 1;
}

function Button:init( properties )
	self.super.init( self, properties )
end

print( Button.x ) -- 5
print( Button.y ) -- 1

local myObject = Object( {
	text = 'hi';
} )

local myButton = Button( {
	x = 4;
	text = 'hi';
} )
print( myButton.x ) -- 4
print( myButton.y ) -- 1
print( myButton.text ) -- hi
