
class "FirstApplicationContainer" extends "ApplicationContainer" {
	firstButton = InterfaceOutlet( "firstButton" )
}

function FirstApplicationContainer:onFirstButton( event )
	self.application.interfaceName = "second"
end
