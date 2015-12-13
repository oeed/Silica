
class "SearchBox" extends "TextBox" {
    
    placeholder = String( "Search..." ).allowsNil;

}

function SearchBox:initialiseCanvas()
    self:super()
    local theme = self.theme
    local symbol = theme:value( "symbol" )
    self.canvas:fill( theme:value( "symbolColour" ), SymbolMask( 1 + theme:value( "symbolMargin" ), 1 + math.floor( ( self.height - symbol.height ) / 2 ), symbol ) )
end