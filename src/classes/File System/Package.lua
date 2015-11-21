
local RESOURCE_PACKAGE_FOLDERS = { classes = true; fonts = true; interfaces = true; themes = true; resources = true; miscellaneous = true; }

local RESOURCE_PACKAGE_TEMPLATE = [[

local args = { ... }
if #args == 1 and args[1] == "contents" then
    return files
end

_G.__resourceTables = _G.__resourceTables or {}
_G.__resourceTables[#_G.__resourceTables + 1] = files
local loaded = {}
local classes = files["classes"]
local loadClass


local f, err = loadstring( classes["class"]["text/lua"], "class.lua" )
if err then error( err, 0 ) end
local ok, err = pcall( f )
if err then error( err, 0 ) end

table.insert( class.tables, classes )

for name, contents in pairs( classes ) do
    if name ~= "class" then
        class.get( name )
    end
end

]]

local g_tLuaKeywords = {
    [ "and" ] = true,
    [ "break" ] = true,
    [ "do" ] = true,
    [ "else" ] = true,
    [ "elseif" ] = true,
    [ "end" ] = true,
    [ "false" ] = true,
    [ "for" ] = true,
    [ "function" ] = true,
    [ "if" ] = true,
    [ "in" ] = true,
    [ "local" ] = true,
    [ "nil" ] = true,
    [ "not" ] = true,
    [ "or" ] = true,
    [ "repeat" ] = true,
    [ "return" ] = true,
    [ "then" ] = true,
    [ "true" ] = true,
    [ "until" ] = true,
    [ "while" ] = true,
}

-- A modified textutils.serialise that is slightly smaller (no indents, etc.)
local function serialise_( t, tTracking )
    local sType = type(t)
    if sType == "table" then
        if tTracking[t] ~= nil then
            error( "Cannot serialize table with recursive entries", 0 )
        end
        tTracking[t] = true

        if next(t) == nil then
            return "{}"
        else
            local sResult = "{"
            local tSeen = {}
            for k,v in ipairs(t) do
                tSeen[k] = true
                sResult = sResult .. serialise( v, tTracking ) .. ";"
            end
            for k,v in pairs(t) do
                if not tSeen[k] then
                    local sEntry
                    if type(k) == "string" and not g_tLuaKeywords[k] and string.match( k, "^[%a_][%a%d_]*$" ) then
                        sEntry = k .. "=" .. serialise( v, tTracking ) .. ";"
                    else
                        sEntry = "[" .. serialise( k, tTracking ) .. "]=" .. serialise( v, tTracking ) .. ";"
                    end
                    sResult = sResult .. sEntry
                end
            end
            sResult = sResult:sub( 1, #sResult - 1 ) .. "}"
            return sResult
        end
    elseif sType == "string" then
        return string.format( "%q", t )
    elseif sType == "number" or sType == "boolean" or sType == "nil" then
        return tostring(t)
    else
        error( "Cannot serialize type "..sType, 0 )
    end
end

class "Package" extends "File" {}

function Package.static:make( path, overwrite, Folder folder, isResourcePackage )
    local contents = ""
    if isResourcePackage then
        local folders = {}
        for i, item in ipairs( folder.items ) do
            local itemName = item.fullName
            logtraceback()
            if RESOURCE_PACKAGE_FOLDERS[itemName] and item:typeOf( Folder ) then
                folders[itemName] = item:serialise( true )
            elseif itemName == "loadfirst.scfg" and item.metadata.mime == Metadata.mimes.SCFG then
                folders["loadfirst"] = { [Metadata.mimes.SCFG] = item.contents }
            end
        end
        contents = "local files = " .. serialise_(folders, {}) .. RESOURCE_PACKAGE_TEMPLATE
        -- contents = textutils.serialize(folders)
    else
        local allItems = folder:serialise( false )
        contents = serialise_(allItems, {})
        -- contents = textutils.serialize(allItems)
    end
    -- log(contents)
    -- log( serialise( allItems, {} ) )
    return self:super( path, overwrite, isResourcePackage and Metadata.mimes.RESOURCEPKG or Metadata.mimes.PACKAGE, contents )
end

