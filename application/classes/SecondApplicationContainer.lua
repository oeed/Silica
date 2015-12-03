
class "SecondApplicationContainer" extends "ApplicationContainer" {

	secondButton = InterfaceOutlet( "secondButton" )

}

function SecondApplicationContainer:onSecondButton( Event event, Event.phases phase )
	self.application.interfaceName = "first"
end
