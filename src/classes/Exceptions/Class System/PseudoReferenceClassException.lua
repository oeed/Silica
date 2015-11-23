
class "PseudoReferenceClassException" extends "ClassException" {

}

function PseudoReferenceClassException:initialise( String message, Number.allowsNil level )
    message = "Incorrect usage of PseudoReferences: " .. message
    self:super( message, level )
end
