
class "SymbolObject" extends "Canvas" {

    symbol = false;
    paths = {};

}

function SymbolObject:initialise( x, y, symbol )
    if not symbol then
        self:super( x, y, 1, 1 )
        return
    end
    
    if not symbol:typeOf( Symbol ) then
        error( "SymbolObject must be given a class that extends Symbol.", 4 )
    end
    self:super( x, y, symbol.width, symbol.height )
    self.symbol = symbol
end

function SymbolObject.symbol:set( symbol )
    self.symbol = symbol
    for i, child in ipairs( self.children ) do
        self:remove( child )
    end

    self.width = symbol.width
    self.height = symbol.height

    local paths = self.paths
    for i, serialisedPath in ipairs( symbol.serialisedPaths ) do
        local path = Path.fromSerialisedPath( serialisedPath )
        self:insert( path )
        table.insert( paths, path )
    end
end

function SymbolObject.fillColour:set( fillColour )
    for i, path in ipairs( self.paths ) do
        path.fillColour = fillColour
    end
end

function SymbolObject.outlineColour:set( outlineColour )
    for i, path in ipairs( self.paths ) do
        path.outlineColour = outlineColour
    end
end

function SymbolObject.outlineWidth:set( outlineWidth )
    for i, path in ipairs( self.paths ) do
        path.outlineWidth = outlineWidth
    end
end

function SymbolObject.leftOutlineWidth:set( leftOutlineWidth )
    for i, path in ipairs( self.paths ) do
        path.leftOutlineWidth = leftOutlineWidth
    end
end

function SymbolObject.rightOutlineWidth:set( rightOutlineWidth )
    for i, path in ipairs( self.paths ) do
        path.rightOutlineWidth = rightOutlineWidth
    end
end

function SymbolObject.topOutlineWidth:set( topOutlineWidth )
    for i, path in ipairs( self.paths ) do
        path.topOutlineWidth = topOutlineWidth
    end
end

function SymbolObject.bottomOutlineWidth:set( bottomOutlineWidth )
    for i, path in ipairs( self.paths ) do
        path.bottomOutlineWidth = bottomOutlineWidth
    end
end
