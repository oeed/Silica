
class "AlertWindow" extends "Window" {
	interface = "alert";
}

function AlertWindow:init( ... )
	self.super:init( ... )
	self:event( Event.PARENT_CHANGED, self.onParentChanged )
end

function AlertWindow:onParentChanged( event )
	if self.parent then
		self:centre()
		self:focus()
	end
end