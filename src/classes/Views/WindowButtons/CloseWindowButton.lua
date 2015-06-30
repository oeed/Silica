
class "CloseWindowButton" extends "WindowButton" {}

function CloseWindowButton:initCanvas()
	self.super:initCanvas()

	local symbolObject = OutlinePath( 4, 3, 3, 3 )
    symbolObject:lineTo( 3, 3 )
    symbolObject:moveTo( 3, 1 )
    symbolObject:lineTo( 1, 3 )
    symbolObject:close()

    self.theme:connect( symbolObject, 'outlineColour', 'symbolColour' )
    self.symbolObject = self.canvas:insert( symbolObject )
end

function CloseWindowButton:onMouseUp( event )    
    if self.window then
        self.window:close()
        return true
    end
end