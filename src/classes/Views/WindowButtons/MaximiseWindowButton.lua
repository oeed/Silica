
class "MaximiseWindowButton" extends "WindowButton" {}

function MaximiseWindowButton:onMouseUp( event )    
    if self.window then
        self.window:close()
        return true
    end
end