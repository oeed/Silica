local class = {}

-- @static
function class:new( ... )
	local newRaw = {}

	newRaw.super = self.__extends --:new(...) -- not sure here, do we want super to be a class or instance? i'll do some testing
	newRaw.class = self

	setmetatable(newRaw, { __index = self })

	-- these are to prevent infinite loops in getters and setters (so, for example, doing self.speed = 10 in setSpeed doesn't cause setSpeed to be called a million times)
	local lockedSetters = {}
	local lockedGetters = {}

	local newProxy = {} -- the proxy. 'self' always needs to be this, NOT newRaw
	setmetatable(newProxy, {
		__index = function(t, k)
			-- this basically allows a global filter or notification on all get
			if not lockedGetters[k] and newRaw.get and type(newRaw.get) == 'function' then
				lockedGetters[k] = true
				local use, value = newRaw.get(newProxy, k)
				lockedGetters[k] = nil
				if use then
					return value
				end	
			end

			-- basically, if the get'Key' function is set, return it's value
			-- names are capitalised, so .name becomes getName; This might cause a few issues regarding collisions, but really, how many (good) coders are using .name and .Name
			-- non-function properties can't use it, because, well, it's just futile really
			local getFunc = 'get' .. k:sub(1, 1):upper() .. k:sub(2, -1)
			if not lockedGetters[k] and type(newRaw[k]) ~= 'function' and newRaw[getFunc] and type(newRaw[getFunc]) == 'function' then
				lockedGetters[k] = true
				local value = newRaw[getFunc](newProxy)
				lockedGetters[k] = nil
				return value
			else
				return newRaw[k]
			end
		end,

		__newindex = function (t,k,v)
			-- this basically allows a global filter or notification on all sets
			if not lockedSetters[k] and type(newRaw.set) and type(newRaw.set) == 'function' then
				lockedSetters[k] = true
				local use, value = newRaw.set(newProxy, k, v)
				lockedSetters[k] = nil
				if use then
					newRaw[k] = value
					return
				end	
			end

			-- if the filter wasn't applied, if the set'Key' function is set, call it
			local setFunc = 'set' .. k:sub(1, 1):upper() .. k:sub(2, -1)
			if not lockedSetters[k] and type(newRaw[k]) ~= 'function' and newRaw[setFunc] and type(newRaw[setFunc]) == 'function' then
				lockedSetters[k] = true
				newRaw[setFunc](newProxy, v)
				lockedSetters[k] = nil
			else
				newRaw[k] = v -- use the passed value if not using the setter
			end
		end
	})

	-- use the setters with all the starting values
	for k, v in pairs(self) do
		if type(self[k]) ~= 'function' then
			newProxy[k] = v
		end
	end

    -- once the class has been created, pass the arguments to the init function for handling
    if newProxy.init and type(newProxy.init) == 'function' then
    	newProxy:init( ... )
    end

	return newProxy
end

-- constructs an actual class (NOT instance)
-- @static
function class:construct(_, name) -- for some reason self is passed twice, not sure why
    local _class = {}
    _class.name = name
    _class.__extends = nil
    _class.__metatable = {
        __call = function(self, ...)
            return self:new(...)
        end,
        __index = self
    }
    setmetatable(_class, _class.__metatable)

    -- not sure if _G is the right thing to use here
    _G[name] = _class

    -- _class can't directly be returned here, but nor can a single function (as :extends and {} are the possible options afterwards)
    local response = {}
    setmetatable(response, {
        __index = _class,
        __call = function(_response, properties)
            _class:properties(properties)
        end
    })
    return response
end

-- @instance
function class:properties(properties)
    for k, v in pairs(properties) do
    	self[k] = v
    end
end

-- @instance
function class:extends(superName)
    local _class = getmetatable(self).__index -- get the actual class from 'response'
    if not getfenv()[superName] then
        -- TODO: add an autoloading here to load the class if it's not found
        error('Super class for `' .. _class.name .. '` was not found: ' .. superName)
    end

    _class.__extends = getfenv()[superName]
    _class.__metatable.__index = _class.__extends
    setmetatable(_class, _class.__metatable)
    return function(properties)
        _class:properties(properties)
    end
end

setmetatable(class, {
    __call = function(...) return class:construct(...) end
})


--- tests

class "Object" {
    x = 5;
}

function Object:init(properties) -- we can decided how to structure the arguments to new later
	properties = properties or {}
	for k, v in pairs(properties) do
		self[k] = v
	end
end

class "Button" : extends 'Object' {
    y = 1;
}

print(Button.x) -- 5
print(Button.y) -- 1

local myButton = Button({
	x = 4;
	text = 'hi';
})
print(myButton.x) -- 4
print(myButton.y) -- 1
print(myButton.text) -- hi
