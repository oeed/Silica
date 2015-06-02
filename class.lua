local class = {}

function class:new( ... )
	local newRaw = {}

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
    newProxy:init( ... )

	return newProxy
end

-- constructs an actual class (NOT instance)
function class:construct(name)
    function(name)
        -- not sure if _G is the right thing to use here
        _G[name] = {}
        return function(superClass)
            print(textutils.serialize(superClass))
        end
    end
end

setmetatable(class, {
    __call = function(...) return class:construct(...) end
})

local somethingSuper = {
    y = 2;
}

class "Button" extends somethingSuper {
    x = 1;
}