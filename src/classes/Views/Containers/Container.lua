
class "Container" extends "View" {
	children = {};
	interfaceOutlets = {};

	offsetX = 0;
	offsetY = 0;
}

--[[
	@constructor
	@desc Initialises the container, linking up any InterfaceOutlets
	@param ...
]]
-- function Container:init( ... )
-- 	self.super:init( ... )
-- end

--[[
	@instance
	@desc Called when a value is set. Connects InterfaceOutlets to the Container.
	@param [string] key -- the key of the set value
    @param value -- the value
]]
function Container:set( key, value )
	-- TODO: probably not needed, interface outlet connecting
	-- self.super:set( key, value )
	if value and type( value ) == 'table' and value.typeOf and value:typeOf( InterfaceOutlet ) then
		value:connect( key, self )
	elseif self.interfaceOutlets[key] and not value then
		self.interfaceOutlets[key]:disconnect()
	end
end

--[[
	@instance
	@desc Initialises the custom container event manger
]]
function Container:initEventManager()
	self.event = ContainerEventManager( self )
end

--[[
	@instance
	@desc Adds a child view to the container (on the top by default)
	@param [View] childView -- the view to add to the container
	@param [number] position -- the z-position of the child (top by default). higher number means further back
]]
function Container:insert( childView, position )
	if position then
		table.insert( self.children, position, childView )
	else
		self.children[#self.children + 1] = childView
	end

	childView.parent = self
	self.canvas:insert( childView.canvas )

	for key, interfaceOutlet in pairs( self.interfaceOutlets ) do
		interfaceOutlet:childAdded( childView )
	end
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
-- function Container:draw( canvas, x, y )
-- 	for i, childView in ipairs( self.children ) do
-- 		childView:draw( self.canvas, childView.x + self.offsetX, childView.y + self.offsetY )
-- 	end
-- 	if x ~= self.canvas.x or y ~= self.canvas.y then
-- 		self.canvas.x = x
-- 		self.canvas.y = y
-- 	end
-- 	self.canvas:drawTo( target )
-- end

--[[
	@instance
	@desc Removes the first instance of the child view from the container
	@param [View] childView -- the view to add to the container
	@return [boolean] didRemove -- whether a child was removed
]]
function Container:removeChild( removingView, position )
	local didRemove = false

	for i, childView in ipairs( self.children ) do
		if childView == removingView then
			self.canvas:remove( removingView.canvas )
			table.remove( self.children, i )
			didRemove = true
			break
		end
	end

	removingView.parent = nil

	if didRemove then
		for key, interfaceOutlet in pairs( self.interfaceOutlets ) do
			interfaceOutlet:childRemoved( removingView )
		end
	end

	return didRemove
end

--[[
	@instance
	@desc Returns the (first) child with the given identifier
	@param [string] identifier -- the identifier of the child view
	@param [boolean] descendTree -- true by default. whether child Containers should be looked through
	@return [View] childView -- the found child view
]]
function Container:findChild( identifier, descendTree )
	descendTree = (descendTree == nil and true or descendTree)
	for i, childView in ipairs( self.children ) do
		if childView.identifier == identifier then
			return childView
		end

		-- look in child Containers 
		if descendTree and childView:typeOf( Container ) then
			local child = childView:findChild( identifier )
			if child then
				return child
			end
		end
	end
end

--[[
	@instance
	@desc Returns all children with the given identifier
	@param [string] identifier -- the identifier of the child view
	@param [boolean] descendTree -- true by default. whether child Containers should be looked through
	@return [table] childrenViews -- the table of the found found children views
]]
function Container:findChildren( identifier, descendTree )
	descendTree = (descendTree == nil and true or descendTree)
	
	local children = {}
	for i, childView in ipairs( self.children ) do
		if childView.identifier == identifier then
			table.insert( children, childView )
		end

		-- look in child Containers 
		if descendTree and childView:typeOf( Container ) then
			local childChildren = childView:findChildren( identifier )
			for i2, childChild in ipairs( childChildren ) do
				table.insert( children, childChild )
			end
		end
	end
	return children
end
