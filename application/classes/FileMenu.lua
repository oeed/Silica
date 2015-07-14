
class "FileMenu" extends "Menu" {
	newMenuItem = InterfaceOutlet( "newMenuItem" );
	alertMenuItem = InterfaceOutlet( "alertMenuItem" );
	rebootMenuItem = InterfaceOutlet( "rebootMenuItem" );
}

function FileMenu:onAlertMenuItem( event )
	-- log( path:gsub( "[^/]+/%.%.", "" ):gsub( "/%.", "" ):gsub( "//+", "/" ) )
	-- local alert = AlertWindow()
	-- self.application.container:insert( alert )
	-- alert:center()
	-- alert:focus()
end

function FileMenu:onRebootMenuItem( event )
	os.reboot()
end
