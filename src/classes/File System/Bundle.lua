
local function tidy( path )
    path = ("/" .. path)
        :gsub( "/.-/%.%./", "/" )
        :gsub( "^.-/%.%./", "" )
        :gsub( "/%./", "/" )
        :gsub( "^%.%./", "" )
        :gsub( "^%.%.$", "" )
        :gsub( "//+", "/" )
        -- :gsub( "^[^/]", "/" )
        :gsub( "/$", "" )
    return path
end

class "Bundle" extends "Folder" {}

function Bundle.metatable:__call( path, ... )
    if fs.exists( path ) and fs.isDir( path ) and not fs.isReadOnly( path ) and fs.exists( tidy( path .. "/bundle.sconfig" ) ) then
        local name = fs.getName( path )
        if name ~= ".DS_Store" and name ~= ".metadata" then
            return self.spawn( false, path, ... )
        end
    end
end