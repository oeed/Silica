
local fs = Quartz and Quartz.fs or fs

local function tidy( path )
    path = path:gsub( "/.-/%.%./", "/" )
               :gsub( "^.-/%.%./", "" )
               :gsub( "/%./", "/" )
               :gsub( "^%.%./", "" )
               :gsub( "^%.%.$", "" )
               :gsub( "//+", "/" )
               :gsub( "/$", "" )
    return path
end

local relativePath = tidy( shell.getRunningProgram():match( "(.*)/.+" ) ):gsub( "[^/]$", "%1/" ):gsub( "^[^/]", "/%1" )
local function resolve( path )
    if not path or #path == 0 then return "/" .. relativePath else return tidy( path ):gsub( "^[^/]", relativePath .. "%1" ) end
end

class "File" extends "FileSystemItem" implements "IEditableFileSystemItem" {

    contents = false; -- the string contents of the file
    binaryContents = false; -- a table of bytes; the file contents, read and written using the rb/wb mode 
    serialisedContents = false; -- the texutils.(un)serialised contents of the file. automatically serialises/unserialises each time
    
}

function File.metatable:__call( path, ... )
    path = resolve( path )
    if fs.exists( path ) and not fs.isDir( path ) and not fs.isReadOnly( path ) then
        local name = fs.getName( path )
        if name ~= ".DS_Store" and name ~= ".metadata" then
            return self.spawn( false, path, ... )
        end
    end
end

function File.static:make( path, mime, overwrite, contents )
    local exists = fs.exists( path )
    if overwrite and exists then
        fs.delete( path )
        exists = false
    end

    if not exists then
        local h = fs.open( path, "w" )
        h.write( contents or "" )
        h.close()
        local file = self.class( path )
        file.metadata.mime = mime
        return file
    end
end

function File.contents:set( contents )
    local handle = fs.open( self.path, "w" )
    if handle then
        handle.write( contents )
        handle.close()
    else
        -- TODO: file writting error handling
    end
end

function File.serialisedContents:set( serialisedContents )
    self.contents = textutils.serialize( serialisedContents )
end

function File.binaryContents:set( binaryContents )
    if type( binaryContents ) ~= "table" then error( "File.binaryContents must be set with a table of bytes.", 2 ) end
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

function File.contents:get()
    local handle = fs.open( self.path, "r" )
    if handle then
        local contents = handle.readAll( contents )
        handle.close()
        return contents
    else
        -- TODO: file reading error handling
    end
end

function File.serialisedContents:get()
    return textutils.unserialize( self.contents )
end

function File.binaryContents:get()
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