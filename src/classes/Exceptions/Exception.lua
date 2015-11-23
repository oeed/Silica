
local thrownExceptions = {}
local nextID = 1

function _G.try( func )
    local ok, err = pcall( func )

    if not ok and type( err ) == "string" then
        local id = err:match( "SilicaException: (%d+)" )
        if id then
            local exception = thrownExceptions[tonumber( id )]
            return function( handles )
                for i, handle in ipairs( handles ) do
                    if exception:typeOf( handle.catch ) or handle.default then
                        return handle.handler( exception )
                    end
                end
            end
        end
    end

    return error( err, 0 )
end

function _G.catch( exceptionClass, handler )
    return { catch = exceptionClass, handler = handler }
end

function _G.default( handler )
    return { default = true, handler = handler }
end

class "Exception" {
    
    message = String;
    level = Number( 1 );
    id = Number;
    traceback = Table( {} );

}

function Exception:initialise( String message, Number( 1 ) level )
    self.message = message
    level = level + 1
    self.level = level
    self.id = nextID
    nextID = nextID + 1

    local traceback = self.traceback
    for i = 1, 5 do
        local src = select( 2, pcall( error, "", i + level ) )
        if src == "pcall: " then
            break
        else
            traceback[i] = src:gsub( ":%s$", "", 1 )
        end
    end

    -- throw the exception
    -- TODO: check that these won't leak out of OS programs (maybe .. self.application and compare the application id)
    local id = self.id
    thrownExceptions[id] = self
    error( "SilicaException: " .. self.id, 0 )
end
