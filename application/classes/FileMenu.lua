
class "FileMenu" extends "Menu" {
	newMenuItem = InterfaceOutlet( "newMenuItem" );
	alertMenuItem = InterfaceOutlet( "alertMenuItem" );
	rebootMenuItem = InterfaceOutlet( "rebootMenuItem" );
}

function FileMenu:onAlertMenuItem( event )
	local path = "src/afgds/../a"
	log( path:gsub( "[^/]+/%.%.", "" ):gsub( "/%.", "" ):gsub( "//+", "/" ) )
end

function FileMenu:onRebootMenuItem( event )
	os.reboot()
end
