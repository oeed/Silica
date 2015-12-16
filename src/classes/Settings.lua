
local hasInitialised = false

local DEFAULT_KEYS = { defaults = true, }

class "Settings" {
    
    defaults = Table;

}

function Settings:initialise()
    if hasInitialised then
        MultipleInstanceSettingsException( "You have already initialised another Settings instance. There can only be ONE per application, even if they are different classes. If you disagree with this make a GitHub issue, I might consider changing it." )
    end

    local defaults = {}
    for key, value in pairs( self.raw ) do
        if not DEFAULT_KEYS[key] then
            defaults[key] = value
        end
    end
    self.defaults = defaults

    
end

function Settings:saveDefaults()
    for k, v in pairs( defaults ) do
        self[k] = v
    end
    self:save()
end

function Settings:save()
    for key, _ in pairs( self.raw ) do
        if not DEFAULT_KEYS[key] then
            log( key .. ": " .. self[key] ) -- we use self[key] rather than the value to call the getter
        end
    end
end
