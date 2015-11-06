
class "Symbol" {
    
    symbolName = false;
    width = 7;
    height = 7;
    serialisedPaths = {};
    
}

local symbolClasses = {}

function Symbol.register( symbolName, subclass )
    if not symbolName then
        error( "Symbol subclass '" .. tostring( subclass ) .. "' does not have a symbolName.", 0 )
    end

    if symbolClasses[symbolName] then
        error( "Symbol subclass '" .. tostring( subclass ) .. "' attempted to overwite symbol with name '" .. symbolName .. "' ('" .. tostring( symbolClasses[symbolName] ) .. "')", 0 )
    end

    symbolClasses[symbolName] = subclass
end

function Symbol.constructed( _class )
    if _class ~= Symbol then
        Symbol.register( _class.symbolName, _class )
    end
end

function Symbol.fromName( name )
    local symbol = symbolClasses[name]
    if not symbol then
        error( "Unable to find symbol with name '" .. name .. "'", 3 )
    end
    return symbol
end
