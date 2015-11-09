
class "File" extends "FileSystemItem" {

    contents = false; -- the string contents of the file
    binaryContents = false; -- a table of bytes; the file contents, read and written using the rb/wb mode 
    serialisedContents = false; -- the texutils.(un)serialised contents of the file. automatically serialises/unserialises each time
    
}

function File:setContents( contents )
    local handle = fs.open( self.path, "w" )
    if handle then
        handle.write( contents )
        handle.close()
    else
        -- TODO: file writting error handling
    end
end

function File:setSerialiseContents( serialisedContents )
    self.contents = textutils.serialize( serialisedContents )
end

function File:setBinaryContents( binaryContents )
    if type( binaryContents ) ~= "binaryContents" then error( "File.binaryContents must be set with a table of bytes.", 2 ) end
    local handle = fs.open( self.path, "wb" )
    if handle then
        for i, byte in ipairs( binaryContents ) do
            handle.write( byte )
        end
        handle.close()
    else
        -- TODO: file writing error handling
    end
end

function File:getContents()
    local handle = fs.open( self.path, "r" )
    if handle then
        local contents = handle.readAll( contents )
        handle.close()
        return contents
    else
        -- TODO: file reading error handling
    end
end

function File:getSerialiseContents()
    return textutils.unserialize( self.contents )
end

function File:getBinaryContents( binaryContents )
    local handle = fs.open( self.path, "rb" )
    if handle then
        local contents = {}
        local lastByte = handle.read()
        local tinsert = table.insert
        repeat
            tinsert( contents, lastByte )
            lastByte = handle.read()
        until not lastByte
        handle.close()
        return contents
    else
        -- TODO: file writing error handling
    end
end