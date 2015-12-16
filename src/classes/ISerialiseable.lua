
interface "ISerialiseable" {
    
}

--[[
    @desc Serialises the instance into a string which can later be unserialised to create a copy of the instance
    @return String serialisedContent
]]
function ISerialiseable:serialise()

--[[
    @desc Unserialises a string previously serialised into an instance
    @return Instance unserialisedInstance
]]
function ISerialiseable.static.unserialise( String serialisedContent )