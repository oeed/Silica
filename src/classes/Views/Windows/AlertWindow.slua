
class AlertWindow extends Window {

	interfaceName = "alert";
	okayButton = View( "okayButton" );

}

function AlertWindow:initialise( ... )
	self:super( ... )

	self:event( LoadedInterfaceEvent, self.onInterfaceLoaded )
	self:event( ReadyInterfaceEvent, self.onReady )

	self.width = 100
	self.height = 40
end

function AlertWindow:onReady( ReadyInterfaceEvent event, Event.phases phase )
	self:centre()
	self:focus()
	self.okayButton:focus()
end
