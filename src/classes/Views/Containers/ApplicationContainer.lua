
class "ApplicationContainer" extends "Container" {
	-- TODO: make this use a Constraint
	x = 1;
	y = 1;
	width = 320;
	height = 200;
	themeName = false;
}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function ApplicationContainer:initialise( ... )
	if not self.themeName then
		self.themeName = "default"
	end

	self.super:initialise( ... )

    self:event( MouseDownEvent, self.onMouseDownAfter, EventManager.phase.AFTER )
end

function ApplicationContainer:initialiseCanvas()
	local canvas = ScreenCanvas( self.x, self.y, self.width, self.height )
    self.canvas = canvas
    self.theme:connect( self.canvas, "fillColour" )
end

function ApplicationContainer:setTheme( theme )
	if type( theme ) == "string" then error( "To the set the theme of an ApplicationContainer using a string, use the property 'themeName', rather than 'theme'. Most likely cause: you have use theme=\"" .. theme .. "\" in an interface file, rather than themeName=\"" .. theme .. "\"", 0 ) end
	self.theme = theme
end

--[[
	@instance
	@desc Sets the container's theme based upon it's name
	@return [string] themeName -- the name of the theme
]]
function ApplicationContainer:setThemeName( themeName )
	local oldThemeName = self.themeName
	self.themeName = themeName
	Theme.active = Theme.named( themeName )
	self.application.event:handleEvent( ThemeChangedInterfaceEvent( themeName, oldThemeName ) )
end

function ApplicationContainer:draw()
	self.canvas:drawToTerminal()
end

--[[
    @instance
    @desc Fired when the mouse is released and doesn't hit anything else. Unfocuses the focused view, if any.
    @param [MouseDownEvent] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function ApplicationContainer:onMouseDownAfter( event )
	local application = self.application
	
	if application:hasFocus() then
		for focus, v in pairs( application.focuses ) do
			 if focus.isFocusDismissable then
			 	application:unfocus( focus )
			 end
		end
	end
end

function ApplicationContainer:dispose()
	self.super:dispose()
	self.application:clearFocus()
end