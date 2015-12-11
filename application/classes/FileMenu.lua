
class "FileMenu" extends "Menu" {

	newMenuItem = InterfaceOutlet( "newMenuItem" );
	alertMenuItem = InterfaceOutlet( "alertMenuItem" );
	rebootMenuItem = InterfaceOutlet( "rebootMenuItem" );

}

function FileMenu:onAlertMenuItem( Event event, Event.phases phase )
	-- log( path:gsub( "[^/]+/%.%.", "" ):gsub( "/%.", "" ):gsub( "//+", "/" ) )
	-- local alert = AlertWindow()
	-- self.application.container:insert( alert )
	-- alert:center()
	-- alert:focus()
end

function FileMenu:onRebootMenuItem( Event event, Event.phases phase )
	os.reboot()
end
