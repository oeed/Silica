
class "MaximiseWindowButton" extends "WindowButton" {}

function MaximiseWindowButton:initialiseCanvas()
	self:super()

	-- local symbolObject = Path( 4, 3, 3, 3, 2, 1 )
 --    symbolObject:lineTo( 2, 3 )
 --    symbolObject:moveTo( 1, 2 )
 --    symbolObject:lineTo( 3, 2 )
 --    symbolObject:close( false )
 --    self.theme:connect( symbolObject, "outlineColour", "symbolColour" )
 --    self.symbolObject = self.canvas:insert( symbolObject )
end

function MaximiseWindowButton:onMouseUp( Event event, Event.phases phase )    
    if self.window then
        self.window:close()
        return true
    end
end