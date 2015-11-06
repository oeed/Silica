local interfaces = {}
class.interfaces = interfaces

local USE_GLOBALS = true

local interface = {}
local creating
local constructing

function interface.get( type )
    return interfaces[type]
end

function interface:construct( _, interfaceName )
    if interfaceName == "" or interfaceName:sub(1,1) ~= "I" then
        error( "The name of interface '" .. interfaceName .. "' does not start with a capital I (i.e. IClickable)")
    end
    local _interface ={}
    local mt = { __index = self }

    mt.interfaceName = interfaceName
    local definedProperties = { } -- the properties that were defined in the table at interface construction
    mt.definedProperties = definedProperties
    local definedFunctions = { } -- the interface functions defined 
    mt.definedFunctions = definedFunctions
    local definedBoth = {} -- the properties AND functions defined
    mt.definedBoth = definedBoth

    setmetatable( _interface, mt )
    _interface.mt = mt

    function mt:__call( ... )
        error( "Attempted to call interface '" .. interfaceName .. "'", 2 )
    end

    local interfaceOutletActions = definedProperties.interfaceOutletActions
    function mt:__newindex( k, v )
        if self ~= constructing and not definedProperties[k] then -- TODO: doesn't work if the function is already made (just overwrites it)
            error( "Attempted to set interface property or create function '" .. k .. "' after interface construction completion for interface '" .. interfaceName .. "'.", 2 )
        end
        if k == nil then error( "Attempt to set value with nil key", 2 ) end
        if definedFunctions[k] then
            error( "Attempted to redeclare function '" .. k .. "' for interface '" .. interfaceName .. "'", 2 )
        -- elseif selfDefinedProperties[k] then
            -- error( "Attempted to redeclare property '" .. k .. "' for interface '" .. interfaceName .. "'", 2 )
        end
        local isFunction = type( v ) == "function"
        if isFunction then
            definedFunctions[k] = true
        else
            definedProperties[k] = true
        end
        definedBoth[k] = true

        rawset(_interface, k, v)
    end

    function mt:__tostring()
        return 'interface: ' .. interfaceName
    end

    setmetatable( _interface, mt )

    constructing = _interface

    interfaces[interfaceName] = _interface
    _G[interfaceName] = _interface -- TODO: this is just temporary due to the temporary loading system in Silica

    creating = _interface
    return function( properties )
        for k, v in pairs( properties ) do
            if type( v ) == "function" then
                error( "Attempted to set function from properties table for key '" .. k .. "' and interface '" .. tostring( self ) .. "'", 0 )
            end
            creating[k] = v
        end
        creating = nil

        return _interface
    end
end

function interface:cement() -- the class finished construction, there shouldn't be any more function or property additions now
    constructing = nil
end

setmetatable( interface, {
    __call = function( ... ) 
        return interface:construct( ... )
    end
} )

if USE_GLOBALS then
    getfenv().interface = interface
else
    return interface
end