
class "MinimiseWindowButton" extends "WindowButton" {}

function MinimiseWindowButton:initialiseCanvas()
	self:super()

	-- local symbolObject = Path( 4, 4, 3, 1, 1, 1 )
 --    symbolObject:lineTo( 3, 1 )
 --    symbolObject:close( false )
 --    self.theme:connect( symbolObject, "outlineColour", "symbolColour" )
 --    self.symbolObject = self.canvas:insert( symbolObject )
end

function MinimiseWindowButton:onMouseUp( Event event, Event.phases phase )    
    if self.window then
        self.window:close()
        return true
    end
end