
class "MinimiseWindowButton" extends "WindowButton" {}

function MinimiseWindowButton:onMouseUp( event )    
    if self.window then
        self.window:close()
        return true
    end
end