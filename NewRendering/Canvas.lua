
class "Canvas" extends "GenericRenderer" {
	
}

function Canvas:init( width, height )
	self.super:init( width, height )
	self.buffer = {}
end
