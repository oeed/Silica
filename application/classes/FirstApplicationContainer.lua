
class "FirstApplicationContainer" extends "ApplicationContainer" {
	firstButton = InterfaceOutlet( "firstButton" )
}

function FirstApplicationContainer:init( ... )
	self.super:init( ... )
	self:event( Event.INTERFACE_READY, self.onReady)
end

function FirstApplicationContainer:onReady( event )
	-- self.firstButton:focus()
end

function FirstApplicationContainer:onFirstButton( event )
	self.application.interfaceName = "second"
end