
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
    if not path or #path == 0 then return "/" .. relativePath else local _ = tidy( path ):gsub( "^[^/]", relativePath .. "%1" ) return _ end
end

class FileSystemItem {
    
    path = false;
    name = false;
    fullName = false;
    extension = false;
    icon = false;
    size = false;
    sizeString = false;
    parent = false;
    parentPath = false;
    metadata = false;
    metadataPath = false;

}

function FileSystemItem.metatable:__call( path, ... )
    path = resolve( path )
    if fs.isDir( path ) then
        -- for speed we asume here that if has a bundle.scfg file then it's a bundle, we'll check in greater depth once we create the bundle
        if fs.exists( tidy( path .. "/bundle.sconfig" ) ) then
            return Bundle( path, ... )
        else
            return Folder( path, ... )
        end
    else
        return File( path, ... )
    end
end

--[[
    @desc Tidys a path (removes double slashes etc.)
]]
function FileSystemItem.static:tidy( String path )
    return tidy( path )
end

--[[
    @desc Resolves a path (makes absolute)
]]
function FileSystemItem.static:resolve( String path )
    return resolve( path )
end

--[[
    @desc Returns true if the file exists
]]
function FileSystemItem.static:exists( String path )
    return fs.exists( resolve( path ) )
end

function FileSystemItem:initialise( path, parent )
    self.path = resolve( path )
    if parent then
        self.raw.parent = parent
    end
end

function FileSystemItem.path:set( path )
    path = resolve( path )
    if not fs.exists( path ) then error( "Attempted to set FileSystemItem.path to non-existant path '" .. path .. "'.", 2 ) end
    self.path = path

    local parentPath, fullName = path:match( "(.*)/(.+)" )
    fullName = fullName or ""
    self.fullName = fullName
    self.raw.parentPath = parentPath
    local name, extension = fullName:match( "^(.+)%.(%w-)$" )
    self.name = name or fullName
    self.extension = extension or false
end

function FileSystemItem.size:get()
    return fs.getSize( self.path )
end

function FileSystemItem.size:set( size )
    error( "FileSystemItem.size is a read-only property.", 2 )
end

function FileSystemItem.sizeString:get()
    local size = fs.getSize( self.path )
    if size == 0 then return "0 B" end
    local prefixes = { [0] = ""; "k"; "M"; "G"; "T"; "P"; }
    local order = math.floor( math.log( size ) / math.log( 1024 ) )
    local bytes = math.ceil( (size / ( 1024 ^ order) ) * 100 )
    return bytes / 100 .. " " .. prefixes[order] .. "B"
end

function FileSystemItem.sizeString:set( sizeString )
    error( "FileSystemItem.sizeString is a read-only property.", 2 )
end

-- function FileSystemItem:{ Number, String }:doSomething( x, label )
-- end

function FileSystemItem.parent:get()
    local parent = self.parent
    if parent then return parent end
    if self.path == "" then return false end

    local parentPath = self.parentPath
    return Folder( parentPath )
end

function FileSystemItem.parent:set( parent )
    error( "FileSystemItem.parent is a read-only property. To move a FileSystemItem use :moveTo", 2 )
end

function FileSystemItem.parentPath:set( parentPath )
    error( "FileSystemItem.parentPath is a read-only property. To move a FileSystemItem use :moveTo", 2 )
end

function FileSystemItem:delete()
    fs.delete( self.path )
    self.metadata:delete( folder )
    self:dispose()
end

function FileSystemItem:moveTo( folder )
    local folderPath = folder.path
    if folderPath == self.parentPath then return end

    local newPath = folderPath .. "/" .. self.fullName
    fs.move( self.path, newPath )
    self.metadata:moveTo( folder )
    self.raw.parentPath = folderPath
    self.raw.parent = false -- delete the cache of the old parent
end

function FileSystemItem:copyTo( folder )
    local folderPath = folder.path
    if folderPath == self.parentPath then return end
    
    local newPath = folderPath .. "/" .. self.fullName
    fs.copy( self.path, newPath )
    local newFile = FileSystemItem( newPath )
    self.metadata:copyTo( folder, newFile )
end

function FileSystemItem:rename( fullName )
    local newPath = self.parentPath .. "/" .. fullName
    fs.move( self.path, newPath )
    self.metadata:rename( fullName )
end

function FileSystemItem.metadataPath:get()
    return self.parentPath .. "/.metadata/" ..self.fullName
end

function FileSystemItem.metadata:get()
    local metadata = self.metadata
    if metadata then return metadata end

    metadata = Metadata( self )
    self.raw.metadata = metadata
    return metadata
end

function FileSystemItem.metadata:set( metadata )
    error( "FileSystemItem.metadata is a read-only property.", 2 )
end
