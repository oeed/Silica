
class "FileMenu" extends "Menu" {
	newMenuItem = InterfaceOutlet( "newMenuItem" );
	alertMenuItem = InterfaceOutlet( "alertMenuItem" );
	rebootMenuItem = InterfaceOutlet( "rebootMenuItem" );
}

function FileMenu:onAlertMenuItem( event )
end

function FileMenu:onRebootMenuItem( event )
	os.reboot()
end
