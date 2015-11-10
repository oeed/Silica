
local DEFAULT_TIMESTAMP = 1417305600; -- default date 1/1/2015

local SAVED_PROPERTIES = { mime = true; createdTimestamp = true; openedTimestamp = true; modifiedTimestamp = true; icon = true; }

local EXTENSION_MIMES = {
    lua = "text/lua";
    txt = "text/plain";
    text = "text/plain";
    image = "image/paint";
    nfp = "image/paint";
    nft = "image/nft";
    skch = "image/sketch";
    sinterface = "text/silicainterface";
    stheme = "text/silicatheme";
    sconfig = "text/silicaconfig";
}

class "Metadata" {
    
    file = false;
    metadataPath = false;

    mime = false; -- MIME mime of the file (e.g. image/nft)
    createdTimestamp = DEFAULT_TIMESTAMP;
    openedTimestamp = DEFAULT_TIMESTAMP;
    modifiedTimestamp = DEFAULT_TIMESTAMP;
    icon = false; -- by default, if this is empty it will get the default system icon for it. it allows for custom icons

}

function Metadata:initialise( file )
    self.file = file
    self.metadataPath = file.metadataPath
    self:load()
end

function Metadata:load()
    local metadataPath = self.metadataPath
    if fs.exists( metadataPath ) then
        local h = fs.open( metadataPath, "r" )
        if h then
            local properties = textutils.unserialize( h.readAll() )
            h.close()
            local raw = self.raw
            for key, value in pairs( properties ) do
                if SAVED_PROPERTIES[key] then
                    raw[key] = value
                end
            end
        end
    else
        local metadataFolderPath = self.file.parentPath .. "/.metadata"
        if fs.exists( metadataFolderPath ) and not fs.isDir( metadataFolderPath ) then
            fs.delete( metadataFolderPath )
        else
            fs.makeDir( metadataFolderPath )
        end
        self:create()
    end
end

function Metadata:save()
    local h = fs.open( self.metadataPath, "w" )
    if h then
        local properties = {}
        for key, _ in pairs( SAVED_PROPERTIES ) do
            local value = self[key]
            if value then
                properties[key] = value
            end
        end
        h.write( textutils.serialize( properties ) )
        h.close()
    end
end

-- create metadata for the file based on it's content
function Metadata:create()
    self:updateCreatedTimestamp()
    self:updateOpenedTimestamp()
    self:updateModifiedTimestamp()
    local file = self.file
    local path = file.path
    local extension = file.extension
    if extension then
        -- try to guess the MIME based on the extension
        self.mime = EXTENSION_MIMES[extension] or "unknown"
    elseif fs.isDir( path ) then
        self.mime = "folder"
    end
    self:save()
end

function Metadata:delete()
    fs.delete( self.metadataPath )
    local oldParentMetadataPath = self.file.parentPath .. "/.metadata"
    if #fs.list( oldParentMetadataPath ) == 0 then
        fs.delete( oldParentMetadataPath )
    end
end

function Metadata:moveTo( folder )
    local folderMetadataFolderPath = folder.path .. "/.metadata"
    if not fs.exists( folderMetadataFolderPath ) then
        fs.makeDir( folderMetadataFolderPath )
    elseif fs.isDir( folderMetadataFolderPath ) then
        fs.delete( folderMetadataFolderPath )
        fs.makeDir( folderMetadataFolderPath )
    end
    local newMetadataPath = folderMetadataFolderPath .. "/" .. self.file.fullName
    fs.move( self.metadataPath, newMetadataPath )
    self.metadataPath = newMetadataPath
    local oldParentMetadataPath = self.file.parentPath .. "/.metadata"
    if #fs.list( oldParentMetadataPath ) == 0 then
        fs.delete( oldParentMetadataPath )
    end
end

function Metadata:copyTo( folder, newFile )
    local copyMetadataPath = folder.path .. "/.metadata/" .. self.file.fullName
    fs.copy( self.metadataPath, copyMetadataPath )
    newFile.metadata:updateModifiedTimestamp()
end

function Metadata:rename( fullName )
    local newMetadataPath = self.file.parentPath .. "/.metadata/" .. fullName
    fs.move( self.metadataPath, newMetadataPath )
    self.metadataPath = newMetadataPath
    self:updateModifiedTimestamp()
end

function Metadata:updateCreatedTimestamp()
    self.createdTimestamp = os.time()
end

function Metadata:updateOpenedTimestamp()
    self.openedTimestamp = os.time()
end

function Metadata:updateModifiedTimestamp()
    self.modifiedTimestamp = os.time()
end

function Metadata:setCreatedTimestamp( createdTimestamp )
    self.createdTimestamp = createdTimestamp
    self:save()
end

function Metadata:setOpenedTimestamp( openedTimestamp )
    self.openedTimestamp = openedTimestamp
    self:save()
end

function Metadata:setModifiedTimestamp( modifiedTimestamp )
    self.modifiedTimestamp = modifiedTimestamp
    self:save()
end
