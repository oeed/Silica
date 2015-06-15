
class "GraphicsObject" {
	x = 1; -- @property x [number] - The x position of the object
	y = 1; -- @property y [number] - The y position of the object
	width = 0; -- @property width [number] - The width of the object
	height = 0; -- @property height [number] - The height of the object
	hasChanged = false; -- @property hasChanged [boolean] - Whether or not the object's internals have hasChanged since it was last drawn
	parent = nil; -- @property parent [View] - The parent of the object, if it exists
}

--[[
	@constructor
	@desc Creates a graphics object
	@param [number] x -- the x coordinate of the graphics object
	@param [number] y -- the y coordinate of the graphics object
	@param [number] width -- the width of the graphics object
	@param [number] height -- the height of the graphics object
]]
function GraphicsObject:init( x, y, width, height )
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

--[[
	@instance
	@desc Sets the x coordinate of the graphics object
	@param [number] x -- the x coordinate of the graphics object
]]
function GraphicsObject:setX( x )
	if self.parent then
		self.parent.hasChanged = true
	end
	self.x = x
end

--[[
	@instance
	@desc Sets the y coordinate of the graphics object
	@param [number] y -- the y coordinate of the graphics object
]]
function GraphicsObject:setY( y )
	if self.parent then
		self.parent.hasChanged = true
	end
	self.y = y
end

--[[
	@instance
	@desc Sets the width of the graphics object
	@param [number] width -- the width of the graphics object
]]
function GraphicsObject:setWidth( width )
	self.hasChanged = true
	self.width = width
end

--[[
	@instance
	@desc Sets the height of the graphics object
	@param [number] height -- the height of the graphics object
]]
function GraphicsObject:setHeight( height )
	self.hasChanged = true
	self.height = height
end

--[[
	@instance
	@desc Sets the changed state of the graphics object, applying it to the parent too
	@param [boolean] hasChanged -- the changed state
]]
function GraphicsObject:setHasChanged( hasChanged )
	if hasChanged and self.parent then
		self.parent.hasChanged = true
	end
	self.hasChanged = hasChanged
end

--[[
	@instance
	@desc Sets the parent of the graphics object, removing the old one if it exists
	@param [boolean] hasChanged -- the parent
]]
function GraphicsObject:setParent( parent )
	if self.parent then
		self.parent:remove( self )
	end
	parent:insert( self )
end
