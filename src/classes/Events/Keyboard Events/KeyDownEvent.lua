
class "KeyDownEvent" extends "KeyEvent" {
    
    isRepeat = Boolean;
    
    static = {
        eventType = "key"
    };

}

function KeyDownEvent:initialise( Number keyCode, Boolean isRepeat )
    self:super( keyCode )
    self.isRepeat = isRepeat
end