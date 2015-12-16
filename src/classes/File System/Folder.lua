
local function tidy( path )
    if type(path)~="string" then logtraceback() end
    path = "/" .. path
    return path
        :gsub( "/.-/%.%./", "/" )
        :gsub( "^.-/%.%./", "" )
        :gsub( "/%./", "/" )
        :gsub( "^%.%./", "" )
        :gsub( "^%.%.$", "" )
        :gsub( "//+", "/" )
        -- :gsub( "^[^/]", "/" )
        :gsub( "/$", "" )
end

class "Folder" extends "FileSystemItem" {
    
    allItems = false;
    items = false;
    files = false;
    folders = false;
    fs = false; -- an fs API sandbox 
    io = false; -- an fs API sandbox 

}

function Folder.metatable:__call( path, ... )
    if fs.exists( path ) and fs.isDir( path ) and not fs.isReadOnly( path ) then
        local name = fs.getName( path )
        if name ~= ".DS_Store" and name ~= ".metadata" then
            return self.spawn( false, path, ... )
        end
    end
end

function Folder.static:make( path, overwrite )
    local exists = fs.exists( path )
    if overwrite and exists then
        fs.delete( path )
        exists = false
    end

    if not exists then
        fs.makeDir( path )
        return Folder( path )
    end
end

function Folder:serialise( flatten, metadataProperties )
    local allItems = {}

    local path = self.path
    for i, name in ipairs( fs.list( path ) ) do
        local item = FileSystemItem( path .. "/" .. name, self )
        if item then
            local itemName = item.name
            local isFolder = item:typeOf( Folder )
            if not isFolder or not flatten then
                if flatten and allItems[flatten and itemName or name] then
                    allItems[flatten and itemName or name][item.metadata.mime] = item.contents
                else
                    allItems[flatten and itemName or name] = flatten and {[item.metadata.mime] = item.contents} or { isFolder and {} or item.contents, item.metadata:serialise( metadataProperties ) }
                end
            end
            if isFolder then
                local subItems = item:serialise( flatten, metadataProperties )
                if flatten and not item:typeOf( Bundle ) then
                    for k, subItem in pairs( subItems ) do
                        -- if flatten then
                            allItems[k] = subItem--{ subItem., item.metadata:serialise() }
                        -- else
                            -- allItems[name][1][subItem.fullName] = { item, item.metadata:serialise() }
                        -- end
                    end
                else
                    allItems[name][1] = subItems
                end
            end
        end
    end

    return allItems
end

function Folder:getItems( noFiles, noFolders )
    local items = {}
    local path = self.path
    for i, name in ipairs( fs.list( path ) ) do
        if name ~= ".DS_Store" and name ~= ".metadata" then
            local item = FileSystemItem( path .. "/" .. name, self )
            if not ( noFolders and noFolders ) or ( noFiles and not item:typeOf( IEditableFileSystemItem ) ) or ( noFolders and not item:typeOf( Folder ) ) then
                table.insert( items, item )
            end
        end
    end
    return items
end

function Folder.items:get()
    return self:getItems( false, false )
end

function Folder.files:get()
    return self:getItem( false, true )
end

function Folder.folders:get()
    return self:getItem( true, false )
end

function Folder.items:set( items )
    error( "Folder.items is a read-only property.", 2 ) -- TODO: check if 2 is correct error level
end

function Folder.files:set( files )
    error( "Folder.files is a read-only property.", 2 ) -- TODO: check if 2 is correct error level
end

function Folder.folders:set( folders )
    error( "Folder.folders is a read-only property.", 2 ) -- TODO: check if 2 is correct error level
end

function Folder:itemFromPath( path )
    return FileSystemItem( self.path .. tidy( path ) )
end

function Folder:fileFromPath( path )
    return File( self.path .. tidy( path ) )
end

function Folder:folderFromPath( path )
    return Folder( self.path .. tidy( path ) )
end

--[[
    @desc Find an IEditableFileSystemItem that matches the name (without the extension) and the mime type.
    @param [string] name -- the exact name of the file without extension to match
    @param [Metatable.mimes/table{Metatable.mimes}] mimes -- a mime or table of mimes
    @param [boolean] noSubfolders -- whether to not look in subfolders, by default subfolders will be searched
    @return [IEditableFileSystemItem] returnedValue -- description
]]
function Folder:find( name, mimes, noSubfolders )
    local items = self.items
    local folders = {}
    if type( mimes ) == "string" then mimes = { mimes } end
    for i, fileSystemItem in ipairs( items ) do
        if fileSystemItem:typeOf( IEditableFileSystemItem ) then
            if --[[(]] name == fileSystemItem.name --[[ or name == fileSystemItem.fullName )]] then
                local mime = fileSystemItem.metadata.mime
                for i, _mime in ipairs( mimes ) do
                    if _mime == mime then
                        return fileSystemItem
                    end
                end
            end
        end
        if not noSubfolders and fileSystemItem:typeOf( Folder ) then
            -- look through folders last
            table.insert( folders, fileSystemItem )
        end
    end

    for i, folder in ipairs( folders ) do
        local found = folder:find( name, mimes )
        if found then
            return found
        end
    end
    return false
end

function Folder.fs:get()
    local _fs = self.fs
    if _fs then return _fs end
    _fs = {
        combine = fs.combine;
        getDir = fs.getDir;
        getName = fs.getName;
        getDrive = fs.getDrive;
    }

    local relativePath = self.path
    local function resolve( path )
        return relativePath .. tidy( path )
    end

    local resolveFunctions = { "list"; "exists"; "isDir"; "isReadOnly"; "getSize"; "getFreeSpace"; "makeDir"; "delete"; "open"; "find"; } -- TODO: will find will work
    for i, name in ipairs( resolveFunctions ) do
        local func = fs[name]
        _fs[name] = function ( path, ... )
            path = path and resolve( path ) or path
            return func( path, ... )
        end
    end

    local doubleResolveFunctions = { "copy"; "move"; }
    for i, name in ipairs( doubleResolveFunctions ) do
        local func = fs[name]
        _fs[name] = function ( fromPath, toPath, ... )
            return func( resolve( fromPath ), resolve( toPath ), ... )
        end
    end

    -- function _fs.combine( partial, path, ... )
    --     return fs.combine( partial, resolve( path), ... )
    -- end

    self.raw.fs = _fs
    return _fs
end

function Folder.fs:set( fs )
    error( "Folder.fs is a read-only property.", 2 ) -- TODO: check if 2 is correct error level
end

function Folder.io:get()
    local _io = self.io
    if _io then return _io end
    _io = {
        input = io.input;
        output = io.output;
        type = io.type;
        close = io.close;
        write = io.write;
        flush = io.flush;
        lines = io.lines;
        read = io.read;
    }

    function _io.open( path, ... )
        return io.open( resolve( path), ... )
    end

    self.raw.io = _io
    return _io
end

function Folder.io:set( io )
    error( "Folder.io is a read-only property.", 2 ) -- TODO: check if 2 is correct error level
end

function Folder:package( path, overwrite, isResourcePackage )
    return Package.static:make( path, overwrite, self, isResourcePackage )
end
