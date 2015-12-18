
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

class "Bundle" extends "Folder" {
    
    config = Table;

}

function Bundle.metatable:__call( path, ... )
    if fs.exists( path ) and fs.isDir( path ) and not fs.isReadOnly( path ) and fs.exists( tidy( path .. "/bundle.sconfig" ) ) then
        local name = fs.getName( path )
        if name ~= ".DS_Store" and name ~= ".metadata" then
            return self.spawn( false, path, ... )
        end
    end
end

function Bundle.path:set( path )
    path = tidy( path )
    self:super( path )

    local configFile = self:find( "bundle", Metadata.mimes.SCONFIG, true )
    if not configFile then
        error( "Bundle is corrupt (no bundle.sconfig or file mime is incorrect)." )
    end

    local config = configFile.serialisedContents
    if not config then
        error( "Bundle is corrupt (bundle.sconfig could not be parsed)." )
    end

    self.config = config
end