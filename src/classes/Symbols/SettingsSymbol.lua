
class SettingsSymbol extends Symbol {

    static = {
        symbolName = String( "settings" );
        width = Number( 6 );
    };

}

function SettingsSymbol.static:initialise()
    local path = Path( self.width, self.height, 2, 1 )
    path:lineTo( 2, 4 )
    path:lineTo( 5, 4 )
    path:lineTo( 5, 1 )
    path:lineTo( 6, 2 )
    path:lineTo( 6, 3 )
    path:lineTo( 4, 5 )
    path:lineTo( 4, 7 )
    path:lineTo( 3, 7 )
    path:lineTo( 3, 5 )
    path:lineTo( 1, 3 )
    path:lineTo( 1, 2 )
    path:close()

    self:super( path )
end
