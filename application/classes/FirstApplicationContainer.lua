
class "FirstApplicationContainer" extends "ApplicationContainer" {
	firstButton = InterfaceOutlet( "firstButton" )
}

function FirstApplicationContainer:initialise( ... )
	self:super( ... )
	self:event( ReadyInterfaceEvent, self.onReady)
end

function FirstApplicationContainer:onReady( event )
	-- self.firstButton:focus()


	-- Document.open()

	-- local document = self.application.document--Document( "test.txt" )
	-- log(document.contents)
	-- document.contents = "Hello!"
	-- document:save()
end

function FirstApplicationContainer:onFirstButton( event )
	self.application.interfaceName = "second"
end
