
local symbolClasses = {}

class Symbol {
    
    static = {

        symbolName = String( "" );
        width = Number( 7 );
        height = Number( 7 );
        path = Path.allowsNil;

    };

}

function Symbol.static:initialise( Path.allowsNil path )
    if path then
        local symbolName = self.symbolName
        if not symbolName then
            error( "Symbol '" .. tostring( self ) .. "' does not have a symbolName.", 0 )
        end

        if symbolClasses[symbolName] then
            error( "Symbol '" .. tostring( self ) .. "' attempted to overwite symbol with name '" .. symbolName .. "' ('" .. tostring( symbolClasses[symbolName] ) .. "')", 0 )
        end

        self.path = path
        symbolClasses[symbolName] = self
    end
end

function Symbol.static:fromName( String name )
    local symbol = symbolClasses[name]
    if not symbol then
        error( "Unable to find symbol with name '" .. name .. "'", 3 )
    end
    return symbol
end
