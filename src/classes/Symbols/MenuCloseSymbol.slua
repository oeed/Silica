
class MenuCloseSymbol extends Symbol {

    static = {
        symbolName = String( "menuClose" );
        height = Number( 4 );
    };

}

function MenuCloseSymbol.static:initialise()
    local path = Path( self.width, self.height, 1, 4 )
    path:lineTo( 4, 1 )
    path:lineTo( 7, 4 )
    path:close()

    self:super( path )
end
