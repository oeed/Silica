
class "AlertWindow" extends "Window" {

	interfaceName = "alert";
	okayButton = InterfaceOutlet( "okayButton" );

}

function AlertWindow:initialise( ... )
	self:super( ... )

	self:event( LoadedInterfaceEvent, self.onInterfaceLoaded )
	self:event( ReadyInterfaceEvent, self.onReady )

	self.width = 100
	self.height = 40
end

function AlertWindow:onReady( Event event, Event.phases phase )
	self:centre()
	self:focus()
	self.okayButton:focus()
end
