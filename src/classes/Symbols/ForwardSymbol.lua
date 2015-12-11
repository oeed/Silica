
class "ForwardSymbol" extends "Symbol" {

    static = {
        symbolName = String( "forward" );
        width = Number( 4 );
    };

}

function ForwardSymbol.static:initialise()
    local path = Path( self.width, self.height, 4, 1 )
    path:lineTo( 1, 4 )
    path:lineTo( 4, 7 )
    path:close()

    self:super( path )
end

