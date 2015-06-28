
class "MaximiseWindowButton" extends "WindowButton" {}

function MaximiseWindowButton:initCanvas()
	self.super:initCanvas()

	local symbolObject = Path( 4, 3, 3, 3 )
	symbolObject:moveTo( 2, 1 )
    symbolObject:lineTo( 2, 2 )
    symbolObject:lineTo( 3, 2 )
    symbolObject:lineTo( 1, 2 )
    symbolObject:lineTo( 2, 2 )
    symbolObject:lineTo( 2, 3 )
    symbolObject:lineTo( 2, 1 )
    symbolObject:close()
    self.theme:connect( symbolObject, 'outlineColour', 'symbolColour' )
    self.symbolObject = self.canvas:insert( symbolObject )
end

function MaximiseWindowButton:onMouseUp( event )    
    if self.window then
        self.window:close()
        return true
    end
end