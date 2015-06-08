
class "Container" extends "View" {
	children = {};
}

--[[
	@instance
	@desc Initialises the custom container event manger
]]
function Container:initEventManager( arg1, arg2, arg3 )
	self.event = ContainerEventManager( self )
end

--[[
	@instance
	@desc Adds a child view to the container (on the top by default)
	@param [View] childView -- the view to add to the container
	@param [number] position -- the z-position of the child (top by default). higher number means further back
]]
function Container:addChild( childView, position )
	if position then
		table.insert( self.children, position, childView )
	else
		table.insert( self.children, childView )
	end

	childView.parent = self
end

--[[
	@instance
	@desc Updates the view and it's children When overriding this self.super:update must be called AFTER the custom drawing code.
	@param [number] deltaTime -- the time since last update
]]
function Container:update( deltaTime )
	for i, childView in ipairs( self.children ) do
		childView:update( deltaTime )
	end
end

--[[
	@instance
	@desc Draws the contents of the container and it's children. When overriding this self.super:draw must be called AFTER the custom drawing code.
	@param [number] x -- the x cordinate to draw from
	@param [number] y -- the y cordinate to draw from
]]
function Container:draw( x, y )
	for i, childView in ipairs( self.children ) do
		childView:draw( childView.x, childView.y )

		-- draw the child's buffer on to the container
		-- TODO: not sure whether these coordinates are correct
		-- self:drawCanvas( childView.x, childView.y, childView)
	end
end

--[[
	@instance
	@desc Removes the first instance of the child view from the container
	@param [View] childView -- the view to add to the container
	@return [boolean] didRemove -- whether a child was removed
]]
function Container:removeChild( childView, position )
	-- TODO: remove child
	-- only remove one, return if one was removed
	-- this means that you can repeatedly all instances easily if you want to
	return didRemove
end
