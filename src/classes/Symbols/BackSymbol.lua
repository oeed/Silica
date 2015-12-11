
class "BackSymbol" extends "Symbol" {

    static = {
        symbolName = String( "back" );
        width = Number( 4 );
    };

}

function BackSymbol.static:initialise()
    local path = Path( self.width, self.height, 1, 1 )
    path:lineTo( 1, 1 )
    path:lineTo( 4, 4 )
    path:lineTo( 1, 7 )
    path:close()

    self:super( path )
end
