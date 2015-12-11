
class "MaximiseWindowButton" extends "WindowButton" {}

function MaximiseWindowButton:onMouseUp( Event event, Event.phases phase )    
    if self.window then
        self.window:close()
        return true
    end
end