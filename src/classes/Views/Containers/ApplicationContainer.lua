
class "ApplicationContainer" extends "Container" {

	-- TODO: make this use a Constraint
	width = Number( 320 );
	height = Number( 200 );
	themeName = String( "default" );

}

--[[
	@constructo
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function ApplicationContainer:initialise( ... )
	self:super( ... )
    self:event( MouseDownEvent, self.onMouseDownAfter, Event.phases.AFTER )
end

function ApplicationContainer:initialiseCanvas()
	self.canvas = ScreenCanvas( self.width, self.height, self )
end

function ApplicationContainer.theme:set( theme )
	if type( theme ) == "string" then error( "To the set the theme of an ApplicationContainer using a string, use the property 'themeName', rather than 'theme'. Most likely cause: you have use theme=\"" .. theme .. "\" in an interface file, rather than themeName=\"" .. theme .. "\"", 0 ) end
	self.theme = theme
end

--[[
	@desc Sets the container's theme based upon it's name
	@return [string] themeName -- the name of the theme
]]
function ApplicationContainer.themeName:set( themeName )
	local oldThemeName = self.themeName
	self.themeName = themeName
	Theme.static.active = Theme.static:named( themeName )
	if oldThemeName then
		self.application.event:handleEvent( ThemeChangedInterfaceEvent( themeName, oldThemeName ) )
	end
end


--[[
	@desc Redraws the container and draws it to the screen if neccesary
]]
function ApplicationContainer:draw()
	if self.isVisible and self.needsDraw then
		self:super()
		self.canvas:drawToScreen( term )
	end
end

--[[
	@desc Update the container than draw the changes (if any) to the screen
]]
function ApplicationContainer:update( ... )
	self:super( ... )
	self:draw()
end

--[[
    @desc Fired when the mouse is released and doesn't hit anything else. Unfocuses the focused view, if any.
    @param [MouseDownEvent] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function ApplicationContainer:onMouseDownAfter( MouseDownEvent event, Event.phases phase )
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
	self:super()
	self.application:clearFocus()
end

function ApplicationContainer.isVisible:get()
	return self.isVisible -- View requires having a parent to be visible, but we never have a parent
end

function ApplicationContainer.needsDraw:set( needsDraw )
	self.needsDraw = needsDraw -- View passed needsDraw to parent, but we never have a aprent
end