
class "SecondApplicationContainer" extends "ApplicationContainer" {
	secondButton = InterfaceOutlet( "secondButton" )
}

function SecondApplicationContainer:onSecondButton( event )
	self.application.interfaceName = "first"
end
