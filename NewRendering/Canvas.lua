
class "Canvas" extends "GenericRenderer" {
	
}

function Canvas:initialise( x, y, width, height )
	self.super:initialise( x, y, width, height )
	self.children = {}
end

function Canvas:insert( object )
	local children = self.children
	children[#children + 1] = object
	object.parent = self
	self.hasChanged = true
end

function Canvas:remove( object )
	local children = self.children
	for i = #children, 1, -1 do
		if children[i] == object then
			table.remove( children, i )
		end
	end
	object.parent = nil
	self.hasChanged = true
end

function Canvas:drawChildren()
	local children = self.children
	local draw = self.draw
	for i = 1, #children do
		draw( self, children[i] )
	end
end

function Canvas:draw( object, x, y )
	object:drawTo( self, x or object.x, y or object.y )
end

function Canvas:drawTo( canvas, x, y )
	if self.hasChanged then
		self:clear()
		self:drawChildren()
	end
	return self:drawBufferTo( canvas, x, y )
end
