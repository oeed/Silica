
class "UpSymbol" extends "Symbol" {

    static = {
        symbolName = String( "up" );
    };

}

function UpSymbol.static:initialise()
    local path = Path( self.width, self.height, 4, 1 )
    path:lineTo( 7, 4 )
    path:lineTo( 5, 4 )
    path:lineTo( 5, 7 )
    path:lineTo( 3, 7 )
    path:lineTo( 3, 4 )
    path:lineTo( 1, 4 )
    path:close()

    self:super( path )
end
