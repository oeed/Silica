
class "Container" extends "View" {

	children = {};
	interfaceOutlets = {};
	interfaceName = false;
	offsetX = 0;
	offsetY = 0;
	interfaceOutletActions = {};

}

--[[
	@constructor
	@desc Initialises the container, linking up any InterfaceOutlets
	@param ...
]]
function Container:initialise( ... )
	self:super( ... )
	self:loadInterface()
	self:event( InterfaceOutletChangedInterfaceEvent, self.onInterfaceOutletChanged )
end

--[[
	@desc Creates a container from interface file
	@param [string] interfaceName -- the name of the interface file
	@param [class] _class -- the class that the container must extend (e.g. ApplicationContainer). If this is being called on a subclass you MUST pass in the class.
	@return [Container or _class] container -- the container
]]
function Container.static:fromInterface( interfaceName, _class )
	local interface = Interface( interfaceName, _class or Container )
	if interface then
		return interface.container
	end
end

--[[
    @desc Loads the children and properties of the interface specified by the self.interfaceName interface name. Called automatically during Container:init, do not call this yourself.
]]
function Container:loadInterface()
    local interfaceName = self.interfaceName
    if interfaceName then
        local interface = Interface( interfaceName, self.class )

        local containerInterfaceProperties = self.interfaceProperties
        for k, v in pairs( interface.containerProperties ) do
        	if not containerInterfaceProperties or not containerInterfaceProperties[k] then -- if the interface defining THIS container specified this property then don't set it
        		self[k] = v
        	end
        end

        for i, childView in ipairs( interface.children ) do
        	self:insert( childView )
        end
    end
end

function Container:onInterfaceOutletChanged( InterfaceOutletChangedInterfaceEvent event, Event.phases phase )
	local interfaceOutlet = event.interfaceOutlet
	local oldView = false
	local newView = false
	local interfaceOutletActions = self.interfaceOutletActions
	local BEFORE = Event.phases.BEFORE
	local ACTION = ActionInterfaceEvent

	for k, outlet in pairs( self.interfaceOutlets ) do
		if interfaceOutlet == outlet then
			oldView = oldView == false and event.oldView or oldView
			newView = newView == false and event.newView or newView
			if oldView ~= newView then
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
	@desc Called when a value is set. Connects InterfaceOutlets to the Container.
	@param [string] key -- the key of the set value
    @param value -- the value
]]
-- function Container:set( key, value )
-- 	if value and type( value ) == "table" and value.typeOf and value:typeOf( InterfaceOutlet ) then
-- 		value:connect( key, self )
-- 	elseif self.interfaceOutlets[key] and not value then
-- 		self.interfaceOutlets[key]:disconnect()
-- 	end
-- end

--[[
	@desc Initialises the custom container event manger
]]
function Container:initialiseEventManager()
	self.event = ContainerEventManager( self )
end

--[[
	@desc Updates the view and it's children When overriding this self.super:update must be called AFTER the custom drawing code.
	@param [number] deltaTime -- the time since last update
]]
function Container:update( deltaTime )
	self:super( deltaTime )
	for i, childView in ipairs( self.children ) do
		childView:update( deltaTime )
	end
end

function Container:onDraw()
    local canvas = self.canvas
    canvas:fill( self.theme:value( "fillColour" ) )
end

--[[
	@desc Draws the Container and its children to its Canvas
]]
function Container:draw()
	local canvas = self.canvas
	canvas:clear()
	
	-- first draw ourself
	local childMask = self:onDraw()

	-- then draw the children
	for i, childView in ipairs( self.children ) do
		-- only draw if something changed
		if childView.isVisible then
			local needsDraw = childView.needsDraw
			local x, y = childView.x, childView.y
			-- first draw the contents
			if needsDraw then
				childView:draw()
			end

			local shadowSize = childView.shadowSize
			if shadowSize > 0 then
				-- if there's a shadow draw it to the canvas
				local shadowMask = childView.shadowMask
				shadowColour = childView.theme:value( "shadowColour" )
				canvas:drawShadow( shadowColour, x, y, shadowSize, shadowMask )
			end

			-- draw the childView to the canvas
			childView.canvas:drawTo( canvas, x, y, childMask )
			if needsDraw then
				childView.needsDraw = false
			end
		end
	end
	self.needsDraw = false
end

--[[
	@desc Fired after
	@param [type] arg1 -- description
	@param [type] arg2 -- description
	@param [type] arg3 -- description
	@return [type] returnedValue -- description
]]
function Container:onParentResizedConstraintUpdateAfter( arg1, arg2, arg3 )
	return returnedValue
end

function Container.width:set( width )
	self:super( width )
    width = self.width
	local event = self.event
	if event then
		event:handleEvent( ParentResizedInterfaceEvent( true, false, self ) )
	end
end

function Container.height:set( height )
	self:super( height )
    height = self.height
	local event = self.event
	if event then
		event:handleEvent( ParentResizedInterfaceEvent( false, true, self ) )
	end
end

function Container.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    for i, childView in ipairs( self.children ) do
    	-- we need to update the isEnabled value for all children, the best way is just to send the current value
    	childView.isEnabled = childView.raw.isEnabled
    end
end

--[[
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
	
	-- TODO: screen order changed events?
	-- for i, childView in ipairs( self.children ) do
	-- 	local onSiblingsChanged = childView.onSiblingsChanged
	-- 	if onSiblingsChanged then onSiblingsChanged( childView ) end
	-- end

	self.needsDraw = true
end

--[[
	@desc Moves the view to be the bottom of it's siblings
	@param [View] childView -- the view to make botom most
]]
function Container:sendToBack( childView )
	self:sendToFront( childView, 1 )
end

--[[
	@desc Adds a child view to the container (on the top by default)
	@param [View] childView -- the view to add to the container
	@param [number] position -- the z-position of the child (top by default). higher number means further back
	@return [View] childView -- the sent child view
]]
function Container:insert( childView, position )
	if not childView:typeOf( View ) then
		error( "Attempted to insert non-View to Container", 3 )
	end

	local children = self.children
	if position then
		table.insert( children, position, childView )
	else
		children[#children + 1] = childView
	end

	local oldParent = childView.parent 
	childView.parent = self
	-- self.canvas:insert( childView.canvas )
	-- we need to update the isEnabled value
	childView.isEnabled = childView.raw.isEnabled

	for i, _childView in ipairs( children ) do
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

	self.event:handleEvent( ChildAddedInterfaceEvent( childView ) )

	self.needsDraw = true

	return childView
end

--[[
	@desc Removes the first instance of the child view from the container
	@param [View] childView -- the view to add to the container
	@return [boolean] didRemove -- whether a child was removed
]]
function Container:remove( removingView )
	local didRemove = false

	local children, canvas = self.children, self.canvas
	for i, childView in ipairs( children ) do
		if childView == removingView then
			-- canvas:remove( removingView.canvas )
			table.remove( children, i )
			didRemove = true
			break
		end
	end

	removingView.parent = false

	if didRemove then
		local view = self
		while view do
			for key, interfaceOutlet in pairs( view.interfaceOutlets ) do
				interfaceOutlet:childRemoved( removingView )
			end
			view = view.parent
		end
	end

	self.event:handleEvent( ChildRemovedInterfaceEvent( removingView ) )

	return didRemove
end

--[[
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
	self:super()
	for i, childView in ipairs( self.children ) do
		childView:dispose()
	end
end
