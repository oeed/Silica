
class MenuOpenSymbol extends Symbol {

    static = {
        symbolName = String( "menuOpen" );
        height = Number( 4 );
    };

}

function MenuOpenSymbol.static:initialise()
    local path = Path( self.width, self.height, 1, 1 )
    path:lineTo( 4, 4 )
    path:lineTo( 7, 1 )
    path:close()

    self:super( path )
end
