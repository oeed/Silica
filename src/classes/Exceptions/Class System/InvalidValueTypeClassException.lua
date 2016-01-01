
class InvalidValueTypeClassException extends ClassException {

}

function InvalidValueTypeClassException:initialise( String message, Number.allowsNil level )
    message = "Invalid value/ValueType of property/argument: " .. message
    self:super( message, level )
end
