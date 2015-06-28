
class "CloseWindowButton" extends "WindowButton" {}

function CloseWindowButton:onMouseUp( event )    
    if self.window then
        self.window:close()
        return true
    end
end