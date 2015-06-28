
class "RebootMenuItem" extends "MenuItem" {}

function RebootMenuItem:init( ... )
	self.super:init( ... )
    self.keyboardShortcut = KeyboardShortcut( keys.leftCtrl, keys.leftAlt, keys.x )
end

function RebootMenuItem:onActivated( event )
	os.reboot()
end