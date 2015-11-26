
class "ValidationException" extends "Exception" {
    
}

function ValidationException:initialise( String message, Number.allowsNil level )
    message = "Value validation exception: " .. message
    self:super( message, level )
end

