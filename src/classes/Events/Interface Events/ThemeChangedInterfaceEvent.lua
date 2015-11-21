
class "ThemeChangedInterfaceEvent" extends "InterfaceEvent" {
    static = {
        eventType = "interface_theme_changed";
    };
	newThemeName = false;
	oldThemeName = false;
}

--[[
	@constructor
	@desc Creates a theme changed event from the arguments
	@param newThemeName -- the theme that is now active
	@param oldThemeName -- the theme that was previously active
]]
function ThemeChangedInterfaceEvent:initialise( newThemeName, oldThemeName )
	self.newThemeName = newThemeName
	self.oldThemeName = oldThemeName
end

