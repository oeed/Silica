
local function tidy( path )
    return path
        :gsub( "/.-/%.%./", "/" )
        :gsub( "^.-/%.%./", "" )
        :gsub( "/%./", "/" )
        :gsub( "^%.%./", "" )
        :gsub( "^%.%.$", "" )
        :gsub( "//+", "/" )
        :gsub( "^[^/]", "/" )
        :gsub( "/$", "" )
end

class "FileSystemItem" {
    
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

function FileSystemItem.mt:__call( path, ... )
    if not fs.exists( path ) then
        return false
    end

    if fs.isDir( path ) then
        return Folder( path, ... )
    else
        return File( path, ... )
    end
end

function FileSystemItem:initialise( path, parent )
    self.path = path
    if parent then
        self.raw.parent = parent
    end
end

function FileSystemItem:setPath( path )
    path = tidy( path )
    if not fs.exists( path ) then error( "Attempted to set FileSystemItem.path to non-existant path '" .. path .. "'.", 2 ) end
    self.path = path

    local parentPath, fullName = path:match( "(.*)/(.+)" )
    self.fullName = fullName
    self.raw.parentPath = parentPath
    local name, extension = fullName:match( "^(.+)%.(%w-)$" )
    self.name = name or fullName
    self.extension = extension or false
end

function FileSystemItem:getSize()
    return fs.getSize( self.path )
end

function FileSystemItem:setSize( items )
    error( "FileSystemItem.size is a read-only property.", 2 )
end

function FileSystemItem:getSizeString()
    local size = fs.getSize( self.path )
    if size == 0 then return "0 B" end
    local prefixes = { [0] = ""; "k"; "M"; "G"; "T"; "P"; }
    local order = math.floor( math.log( size ) / math.log( 1024 ) )
    local bytes = math.ceil( (size / ( 1024 ^ order) ) * 100 )
    return bytes / 100 .. " " .. prefixes[order] .. "B"
end

function FileSystemItem:setSizeString( items )
    error( "FileSystemItem.sizeString is a read-only property.", 2 )
end

function FileSystemItem:getParent()
    local parent = self.parent
    if parent then return parent end
    if self.path == "" then return false end

    local parentPath = self.parentPath
    return Folder( parentPath )
end

function FileSystemItem:setParent( items )
    error( "FileSystemItem.parent is a read-only property. To move a FileSystemItem use :moveTo", 2 )
end

function FileSystemItem:setParentPath( items )
    error( "FileSystemItem.parentPath is a read-only property. To move a FileSystemItem use :moveTo", 2 )
end

function FileSystemItem:moveTo( folder )
    local folderPath = folder.path
    if folderPath == self.parentPath then return end

    local newPath = folderPath .. "/" .. self.fullName
    fs.move( self.path, newPath )
    self.metadata:moveTo( folder )
    self.raw.parentPath = folderPath
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

function FileSystemItem:getMetadataPath()
    return self.parentPath .. "/.metadata/" ..self.fullName
end

function FileSystemItem:getMetadata()
    local metadata = self.metadata
    if metadata then return metadata end

    metadata = Metadata( self )
    self.raw.metadata = metadata
    return metadata
end

function FileSystemItem:setMetadata( items )
    error( "FileSystemItem.metadata is a read-only property.", 2 )
end
