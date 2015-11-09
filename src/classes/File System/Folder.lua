
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

class "Folder" extends "FileSystemItem" {
    
    items = false;
    files = false;
    folders = false;
    fs = false; -- an fs API sandbox 
    io = false; -- an fs API sandbox 

}

function Folder:getItems( noFiles, noFolders)
    local items = {}
    local path = self.path
    for i, name in ipairs( fs.list( path ) ) do
        if name ~= ".DS_Store" then
            local item = FileSystemItem( path .. "/" .. name, self )
            if not ( noFolders and noFolders ) or ( noFiles and not item:typeOf( File ) ) or ( noFolders and not item:typeOf( Folder ) ) then
                table.insert( items, item )
            end
        end
    end
    return items
end

function Folder:getFiles()
    return self:getItem( false, true )
end

function Folder:getFolders()
    return self:getItem( true, false )
end

function Folder:setItems( items )
    error( "Folder.items is a read-only property.", 2 ) -- TODO: check if 2 is correct error level
end

function Folder:setFiles( items )
    error( "Folder.files is a read-only property.", 2 ) -- TODO: check if 2 is correct error level
end

function Folder:setFolders( items )
    error( "Folder.folders is a read-only property.", 2 ) -- TODO: check if 2 is correct error level
end

function Folder:getFs()
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
            func( resolve( path ), ... )
        end
    end

    local doubleResolveFunctions = { "copy"; "move"; }
    for i, name in ipairs( doubleResolveFunctions ) do
        local func = fs[name]
        _fs[name] = function ( fromPath, toPath, ... )
            func( resolve( fromPath ), resolve( toPath ), ... )
        end
    end

    function _fs.combine( partial, path, ... )
        return fs.combine( partial, resolve( path), ... )
    end

    self.raw.fs = _fs
    return _fs
end

function Folder:setFs( fs )
    error( "Folder.fs is a read-only property.", 2 ) -- TODO: check if 2 is correct error level
end

function Folder:getIo()
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

function Folder:setIo( io )
    error( "Folder.io is a read-only property.", 2 ) -- TODO: check if 2 is correct error level
end
