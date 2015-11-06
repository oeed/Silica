
-- local function tidy( path )
--     return path
--         :gsub( "/.-/%.%./", "/" )
--         :gsub( "^.-/%.%./", "" )
--         :gsub( "/%./", "/" )
--         :gsub( "^%.%./", "" )
--         :gsub( "^%.%.$", "" )
--         :gsub( "//+", "/" )
--         :gsub( "^/", "" )
--         :gsub( "/$", "" )
-- end

-- local function formatDevicePath( path )
--     return path:gsub( "([%%%.%(%)%[%]%^%$%*%+%-%?])", "%%%1" )
-- end

class "FileSystem" {
    
    default = false; -- the default file system handle. relative to root, you normally want to use this
    relativePath = false;
--     mounts = {};

}

function FileSystem:initialise( relativePath )
    assert( type( relativePath ) == "string", "Expected realtive path as string." )
    self.relativePath = relativePath
end

-- function FileSystem:invoke( mathod, path, ... )
--     local device, localPath = self:getDeviceAndLocalPath( tidy( path ) )
--     return device[method]( localPath, ... )
-- end

-- function FileSystem:getDeviceAndLocalPath( path ) -- takes a tided path
--     local l, d, p = 0, nil, path

--     for i = 1, #mounts do
--         if path:find( mounts[i].pat .. "/" ) or path:find( mounts[i].pat .. "$" ) then
--             l, d, p = #path:match( mounts[i].pat ), mounts[i].device, path:gsub( mounts[i].pat, "", 1 )
--         end
--     end

--     return d or root, tidy( p )
-- end

-- function FileSystem:resolve( path ) -- the problem with this is, resolve in normal CC changes a local path (relative to the currentprogram path) to an absoulute path
--     if type( path ) ~= "string" then
--         return error( "expected string path, got " .. type( path ) )
--     end
--     return tidy( path )
-- end

-- function FileSystem:mount( path, device )
--     if type( path ) ~= "string" then
--         return error( "expected string path, got " .. type( path ) )
--     elseif type( device ) ~= "table" then
--         return error( "expected table device, got " .. type( device ) )
--     end

--     local mounts = self.mounts

--     path = tidy( path )
--     for i = 1, #mounts do
--         if mounts[i].path == path then
--             mounts[i].device = device
--             return
--         end
--     end

--     mounts[#mounts + 1] = {
--         path = path;
--         pat = "^" .. formatDevicePath( path );
--         device = device;
--     }
-- end

-- function FileSystem:unmount( path )
--     if type( path ) ~= "string" then
--         return error( "expected string path, got " .. type( path ) )
--     end

--     path = tidy( path )
--     for i = 1, #mounts do
--         if mounts[i].path == path then
--             return table.remove( mounts[i] ).device
--         end
--     end
-- end

-- function FileSystem:open( path, mode )
--     if type( path ) ~= "string" then
--         return error( "expected string path, got " .. type( path ) )
--     end
--     return invoke( "open", path, mode )
-- end

-- function FileSystem:list( path )
--     if type( path ) ~= "string" then
--         return error( "expected string path, got " .. type( path ) )
--     end
--     local device, localPath = getDeviceAndLocalPath( tidy( path ) )
--     return device[method]( localPath, ... )
-- end

-- function FileSystem:delete( path )
--     if type( path ) ~= "string" then
--         return error( "expected string path, got " .. type( path ) )
--     end
--     local device, localPath = getDeviceAndLocalPath( tidy( path ) )
--     if localPath == "" then
--         return error( "cannot delete device", 0 )
--     end
--     return device.delete( localPath, ... )
-- end

-- function FileSystem:isDir( path )
--     if type( path ) ~= "string" then
--         return error( "expected string path, got " .. type( path ) )
--     end
--     local device, localPath = getDeviceAndLocalPath( tidy( path ) )
--     if localPath == "" then
--         return true
--     end
--     return device.isDir( localPath, ... )
-- end

-- function FileSystem:makeDir( path )
--     if type( path ) ~= "string" then
--         return error( "expected string path, got " .. type( path ) )
--     end
--     local device, localPath = getDeviceAndLocalPath( tidy( path ) )
--     if localPath == "" then
--         return
--     end
--     return device.makeDir( localPath, ... )
-- end

--  -- ... etc

-- function FileSystem:newRedirectDevice( path )

-- end

-- function FileSystem:setRootDevice( device )
--     root = device
-- end

-- function FileSystem:setRoot( path )
--     root = self:newRedirectDevice( path )
-- end

-- function FileSystem:wrapper()
--     local fsFunctions = {}
--     local fs = {}
--     for i = 1, #fsFunctions do
--         fs[fsFunctions[i]] = filesystem[fsFunctions[i]]
--     end
--     return fs
-- end

-- --[[
--     @instance
--     @desc Saves the provided value to a file, serialising if needed
--     @param content -- the content to be saved
--     @param [string] path -- the path of the file
--     @param [boolean] isBinary -- whether the file should be saved in binary mode
--     @return [boolean] success -- whether the file was saved without an error
-- ]]
-- function FileSystem:save( content, path, isBinary )
--     assert( type( path ) == "string", "Expected path to be a string" )
--     local h = self:open( path, isBinary and "wb" or "w" )
--     if h then
--         if type( content ) == "table" then
--             content = textutils.serialize( content )
--         end
--         h.write( content )
--         return true
--     end
--     return false
-- end

-- --[[
--     @instance
--     @desc Reads the file at the given path
--     @param [string] path -- the path of the file
--     @param [boolean] unserialise -- whether the file should be unserialised
--     @param [boolean] isBinary -- whether the file should be read in binary mode
--     @return [boolean] success -- whether the file was saved without an error
--     @return content -- the content of the file
-- ]]
-- function FileSystem:read( path, unserialise, isBinary )
--     assert( type( path ) == "string", "Expected path to be a string" )
--     local h = self:open( path, isBinary and "rb" or "r" )
--     if h then
--         local content = h.readAll()
--         if unserialise then
--             content = textutils.unserialize( content )
--         end
--         return true, content
--     end
--     return false
-- end

--[[
    @instance
    @desc Returns the icon for a given file
    @param [string] path -- the path of the file
    @return [Image] icon -- the icon image
]]
function FileSystem:getIcon( path )
    return Image.fromPath( "folder.image" )
end
