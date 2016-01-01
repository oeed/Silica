
class ArgumentValueTypeParsingClassException extends ClassException {

}

function ArgumentValueTypeParsingClassException:initialise( String message, Number.allowsNil level )
    message = "Incorrect declaration of function or argument: " .. message
    self:super( message, level )
end