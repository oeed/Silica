
class "SymbolSegmentButton" extends "SegmentButton" {
    
    symbol = false;
    symbolObject = false;

}

function SymbolSegmentButton:initialiseCanvas()
    self:super()
    local canvas = self.canvas
    canvas:remove( self.textObject )
    self.textObject = false
    local symbolObject = canvas:insert( SymbolObject( 1 + self.leftMargin, 5, self.symbol ) )
    self.theme:connect( symbolObject, "fillColour", "symbolColour" )
    self.symbolObject = symbolObject
end

function SymbolSegmentButton.symbol:set( symbol )
    if type( symbol ) == "string" then
        symbol = Symbol.fromName( symbol )
    end
    self.symbol = symbol
    self.symbolObject.symbol = symbol
    self.needsAutosize = true
end

function SymbolSegmentButton:updateWidth( width )
    self:super( width )
    local leftMargin, rightMargin = self.leftMargin, self.rightMargin
    self.symbolObject.x = self.isPressed and leftMargin + 2 or leftMargin + 1
end

function SymbolSegmentButton:onSiblingOrParentChanged( Event event, Event.phases phase )
    self:super( event )
    local isFirst = self.isFirst
    local isLast = self.isLast 
    local symbolObject = self.symbolObject

    -- symbolObject.x = 
end

function SymbolSegmentButton:autosize()
    local symbol = self.symbol
    if symbol then
        self.width = symbol.width + self.leftMargin + self.rightMargin + 1
        self.height = symbol.height + 9
    end
    self.needsAutosize = false
end

function SymbolSegmentButton.isPressed:set( isPressed )
    self:super( isPressed )
    local symbolObject = self.symbolObject
    symbolObject.x = isPressed and self.leftMargin + 2 or self.leftMargin + 1
    symbolObject.y = isPressed and 6 or 5
end