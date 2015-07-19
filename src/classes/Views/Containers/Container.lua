
class "Container" extends "View" {
	children = {};
	interfaceOutlets = {};
	interfaceName = false;
	offsetX = 0;
	offsetY = 0;
}

--[[
	@constructor
	@desc Initialises the container, linking up any InterfaceOutlets
	@param ...
]]
function Container:initialise( ... )
	self.super:initialise( ... )
	self:loadInterface()
	self:event( Event.INTERFACE_OUTLET_CHANGED, self.onInterfaceOutletChanged )
end

--[[
	@static
	@desc Creates a container from interface file
	@param [string] interfaceName -- the name of the interface file
	@param [class] _class -- the class that the container must extend (e.g. ApplicationContainer). If this is being called on a subclass you MUST pass in the class.
	@return [Container or _class] container -- the container
]]
function Container.fromInterface( interfaceName, _class )
	local interface = Interface( interfaceName, _class or Container )
	if interface then
		local container = interface.container
		container.interface = interface
		return container
	end
end

--[[
    @instance
    @desc Loads the children and properties of the interface specified by the self.interfaceName interface name. Called automatically during Container:init, do not call this yourself.
]]
function Container:loadInterface()
    local interfaceName = self.interfaceName
    if interfaceName then
        local interface = Interface( interfaceName, self.class )
        
        local containerInterfaceProperties = self.interfaceProperties
        for k, v in pairs( interface.properties ) do
        	if not containerInterfaceProperties or not containerInterfaceProperties[k] then -- if the interface defining THIS container specified this property then don't set it
        		self[k] = v
        	end
        end

        for i, childView in ipairs( interface.children ) do
        	self:insert( childView )
        end
    end
end

function Container:onInterfaceOutletChanged( event )
	local interfaceOutlet = event.interfaceOutlet
	local oldView = false
	local newView = false
	local interfaceOutletActions = false
	local BEFORE = EventManager.phase.BEFORE
	local ACTION = Event.ACTION

	for k, outlet in pairs( self.interfaceOutlets ) do
		if interfaceOutlet == outlet then
			oldView = oldView == false and event.oldView or oldView
			newView = newView == false and event.newView or newView
			if oldView ~= newView then
				interfaceOutletActions = interfaceOutletActions == false and self.interfaceOutletActions or interfaceOutletActions
				local func = interfaceOutletActions[k]
				if func then
					if oldView and #oldView == 0 then oldView.event:disconnect( ACTION, func, BEFORE, nil, self ) end
					if newView and #newView == 0 then newView:event( ACTION, func, BEFORE, nil, self ) end
				end
			end
		end
	end

end

--[[
	@instance
	@desc Called when a value is set. Connects InterfaceOutlets to the Container.
	@param [string] key -- the key of the set value
    @param value -- the value
]]
function Container:set( key, value )
	if value and type( value ) == "table" and value.typeOf and value:typeOf( InterfaceOutlet ) then
		value:connect( key, self )
	elseif self.interfaceOutlets[key] and not value then
		self.interfaceOutlets[key]:disconnect()
	end
end

--[[
	@instance
	@desc Initialises the custom container event manger
]]
function Container:initialiseEventManager()
	self.event = ContainerEventManager( self )
end

--[[
	@instance
	@desc Updates the view and it's children When overriding this self.super:update must be called AFTER the custom drawing code.
	@param [number] deltaTime -- the time since last update
]]
function Container:update( deltaTime )
	self.super:update( deltaTime )
	for i, childView in ipairs( self.children ) do
		childView:update( deltaTime )
	end
end

--[[
	@instance
	@desc Fired after
	@param [type] arg1 -- description
	@param [type] arg2 -- description
	@param [type] arg3 -- description
	@return [type] returnedValue -- description
]]
function Container:onParentResizedConstraintUpdateAfter( arg1, arg2, arg3 )
	return returnedValue
end

function Container:setWidth( width )
	self.super:setWidth( width )
    width = self.width
	local event = self.event
	if event then
		event:handleEvent( ParentResizeInterfaceEvent( true, false, self ) )
	end
end

function Container:setHeight( height )
	self.super:setHeight( height )
    height = self.height
	local event = self.event
	if event then
		event:handleEvent( ParentResizeInterfaceEvent( false, true, self ) )
	end
end

function Container:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    for i, childView in ipairs( self.children ) do
    	-- we need to update the isEnabled value for all children, the best way is just to send the current value
    	childView.isEnabled = childView.raw.isEnabled
    end
end

--[[
	@instance
	@desc Moves the view to be the top of it's siblings
	@param [View] childView -- the view to make front most
]]
function Container:sendToFront( frontView, position )
	local children = self.children
	for i, childView in ipairs( children ) do
		if childView == frontView then
			table.remove( children, i )
			if position then table.insert( children, position, childView )
			else table.insert( children, childView ) end
		end
	end
	local frontCanvas = frontView.canvas
	local canvasChildren = self.canvas.children
	for i, childCanvas in ipairs( canvasChildren ) do
		if childCanvas == frontCanvas then
			table.remove( canvasChildren, i )
			if position then table.insert( canvasChildren, position, childCanvas )
			else table.insert( canvasChildren, childCanvas ) end
		end
	end
	
	-- TODO: screen order changed events?
	-- for i, childView in ipairs( self.children ) do
	-- 	local onSiblingsChanged = childView.onSiblingsChanged
	-- 	if onSiblingsChanged then onSiblingsChanged( childView ) end
	-- end

	self.canvas.hasChanged = true
	frontView.canvas.hasChanged = true
end

--[[
	@instance
	@desc Moves the view to be the bottom of it's siblings
	@param [View] childView -- the view to make botom most
]]
function Container:sendToBack( childView )
	self:sendToFront( childView, 1 )
end

--[[
	@instance
	@desc Adds a child view to the container (on the top by default)
	@param [View] childView -- the view to add to the container
	@param [number] position -- the z-position of the child (top by default). higher number means further back
	@return [View] childView -- the sent child view
]]
function Container:insert( childView, position )
	if position then
		table.insert( self.children, position, childView )
	else
		self.children[#self.children + 1] = childView
	end

	local oldParent = childView.parent 
	childView.parent = self
	self.canvas:insert( childView.canvas )
	-- we need to update the isEnabled value
	childView.isEnabled = childView.raw.isEnabled

	for i, _childView in ipairs( self.children ) do
		if _childView == childView then
			_childView.event:handleEvent( ParentChangedInterfaceEvent( self, oldParent ) )
		else
			_childView.event:handleEvent( SiblingAddedInterfaceEvent( childView ) )
		end
	end

	local view = self
	while view do
		for key, interfaceOutlet in pairs( view.interfaceOutlets ) do
			if interfaceOutlet:childAdded( childView, view == self ) then
				view = false
				break
			end
		end
		view = view and view.parent
	end
	return childView
end

--[[
	@instance
	@desc Removes the first instance of the child view from the container
	@param [View] childView -- the view to add to the container
	@return [boolean] didRemove -- whether a child was removed
]]
function Container:remove( removingView )
	local didRemove = false

	for i, childView in ipairs( self.children ) do
		if childView == removingView then
			self.canvas:remove( removingView.canvas )
			table.remove( self.children, i )
			didRemove = true
			break
		end
	end

	for i, childView in ipairs( self.children ) do
		local onSiblingsChanged = childView.onSiblingsChanged
		if onSiblingsChanged then onSiblingsChanged( childView ) end
	end

	removingView.parent = nil

	if didRemove then
		local view = self
		while view do
			for key, interfaceOutlet in pairs( view.interfaceOutlets ) do
				interfaceOutlet:childRemoved( removingView )
			end
			view = view.parent
		end
	end

	return didRemove
end

--[[
	@instance
	@desc Returns the ( first ) child with the given identifier
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

function Container:dispose()
	self.super:dispose()
	for i, childView in ipairs( self.children ) do
		childView:dispose()
	end
end
