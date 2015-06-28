
class "TasksMenu" extends "Menu" {
	greenItem = InterfaceOutlet( "greenItem" );
}

function TasksMenu:init( ... )
	self.super:init( ... )
    self:event( Event.INTERFACE_LOADED, self.onInterfaceLoaded )
end

function TasksMenu:onInterfaceLoaded( event )
	if event.owner == self then
		self.greenItem.backgroundObject.fillColour = Graphics.colours.GREEN
	end
end
