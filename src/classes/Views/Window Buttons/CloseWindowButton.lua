
class "CloseWindowButton" extends "WindowButton" {}

function CloseWindowButton:initialiseCanvas()
	self:super()

	local symbolObject = Path( 4, 3, 3, 3 )
    symbolObject:lineTo( 3, 3 )
    symbolObject:moveTo( 3, 1 )
    symbolObject:lineTo( 1, 3 )
    symbolObject:close( false )

    self.theme:connect( symbolObject, "outlineColour", "symbolColour" )
    self.symbolObject = self.canvas:insert( symbolObject )
end

function CloseWindowButton:onMouseUp( Event event, Event.phases phase )    
    if self.window then
        self.window:close()
        return true
    end
end