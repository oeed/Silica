
local hasInitialised = false

local FILE_NAME = "settings.suserdata"
local TYPETABLE_NAME, TYPETABLE_TYPE, TYPETABLE_CLASS, TYPETABLE_ALLOWS_NIL, TYPETABLE_IS_VAR_ARG, TYPETABLE_IS_LINK, TYPETABLE_IS_ENUM, TYPETABLE_ENUM_ITEM_TYPE, TYPETABLE_HAS_DEFAULT_VALUE, TYPETABLE_IS_DEFAULT_VALUE_REFERENCE, TYPETABLE_DEFAULT_VALUE = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
local SYSTEM_KEYS = { defaults = true; settingsFile = true; }

class "Settings" {
    
    defaults = Table;
    settingsFile = File;

}

function Settings:initialise()
    if hasInitialised then
        MultipleInstanceSettingsException( "You have already initialised another Settings instance. There can only be ONE per application, even if they are different classes. If you disagree with this make a GitHub issue, I might consider changing it." )
    end

    local defaults = {}
    for key, property in pairs( self.instanceProperties ) do
        if not SYSTEM_KEYS[key] then
            local propertyType = property[TYPETABLE_TYPE]
            if propertyType ~= "string" and propertyType ~= "number" and propertyType ~= "table" and propertyType ~= "boolean" then
                InvalidValueTypeSettingsException( "Invalid ValueType for property '" .. key .. "', property values must be strings, numbers, tables or booleans." )
            end
            defaults[key] = self[key]
        end
    end
    self.defaults = defaults
    self:refresh()
end

--[[
    @desc Reloads the settings from the settings file
]]
function Settings:refresh()
    local userDataFolder = self.application.userDataFolder
    local settingsFile = userDataFolder:fileFromPath( FILE_NAME )
    if not settingsFile then
        self.settingsFile = userDataFolder:makeSubfile( FILE_NAME, Metadata.mimes.SUSERDATA )
        self:save()
    else
        self.settingsFile = settingsFile
        local serialisedContents = settingsFile.serialisedContents
        for key, property in pairs( self.instanceProperties ) do
            if not SYSTEM_KEYS[key] then
                local value = serialisedContents[key]
                local propertyClass = property[TYPETABLE_CLASS]
                if propertyClass then
                    if not propertyClass:typeOf( ISerialiseable ) then
                        InvalidValueTypeSettingsException( "Invalid ValueType for property '" .. key .. "', property values that are classes must implement ISerialiseable so they can be saved and read from files." )
                    end
                    if value then
                        value = propertyClass.static:unserialise( value )
                    end
                end
                self[key] = value
            end
        end
    end
end

function Settings:save()
    local serialisedContents = {}
    for key, property in pairs( self.instanceProperties ) do
        if not SYSTEM_KEYS[key] then
            local value = self[key]
            local propertyClass = property[TYPETABLE_CLASS]
            if propertyClass then
                if not propertyClass:typeOf( ISerialiseable ) then
                    InvalidValueTypeSettingsException( "Invalid ValueType for property '" .. key .. "', property values that are classes must implement ISerialiseable so they can be saved and read from files." )
                end
                if value then
                    value = value:serialise()
                end
            end
            serialisedContents[key] = value
        end
    end
    self.settingsFile.serialisedContents = serialisedContents
end
