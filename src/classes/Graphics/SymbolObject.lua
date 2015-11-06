
class "SymbolObject" extends "Canvas" {

    symbol = false;
    paths = {};

}

function SymbolObject:initialise( x, y, symbol )
    if not symbol then
        self.super:initialise( x, y, 1, 1 )
        return
    end
    
    if not symbol:typeOf( Symbol ) then
        error( "SymbolObject must be given a class that extends Symbol.", 4 )
    end
    self.super:initialise( x, y, symbol.width, symbol.height )
    self.symbol = symbol
end

function SymbolObject:setSymbol( symbol )
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

function SymbolObject:setFillColour( fillColour )
    for i, path in ipairs( self.paths ) do
        path.fillColour = fillColour
    end
end

function SymbolObject:setOutlineColour( outlineColour )
    for i, path in ipairs( self.paths ) do
        path.outlineColour = outlineColour
    end
end

function SymbolObject:setOutlineWidth( outlineWidth )
    for i, path in ipairs( self.paths ) do
        path.outlineWidth = outlineWidth
    end
end

function SymbolObject:setLeftOutlineWidth( leftOutlineWidth )
    for i, path in ipairs( self.paths ) do
        path.leftOutlineWidth = leftOutlineWidth
    end
end

function SymbolObject:setRightOutlineWidth( rightOutlineWidth )
    for i, path in ipairs( self.paths ) do
        path.rightOutlineWidth = rightOutlineWidth
    end
end

function SymbolObject:setTopOutlineWidth( topOutlineWidth )
    for i, path in ipairs( self.paths ) do
        path.topOutlineWidth = topOutlineWidth
    end
end

function SymbolObject:setBottomOutlineWidth( bottomOutlineWidth )
    for i, path in ipairs( self.paths ) do
        path.bottomOutlineWidth = bottomOutlineWidth
    end
end
