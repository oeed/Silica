
class LoadingClassException extends ClassException {

}

function LoadingClassException:initialise( String message, Number.allowsNil level )
    message = "Error occured during class loading: " .. message
    self:super( message, level )
end
