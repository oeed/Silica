
class "AlertWindow" extends "Window" {
	interface = "alert";
	okayButton = InterfaceOutlet( "okayButton" );
}

function AlertWindow:init( ... )
	self.super:init( ... )

	self:event( Event.INTERFACE_LOADED, self.onInterfaceLoaded )
	self:event( Event.INTERFACE_READY, self.onReady )

	self.width = 100
	self.height = 40
end

function AlertWindow:onReady( event )
	self:centre()
	self:focus()
	self.okayButton:focus()
end
