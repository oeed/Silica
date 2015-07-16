
-- This class allows you to connect a container's view to a property in the class definition and in code.
-- It keeps track of the child view and changes the reference when removed/added
-- Simply connect like so:
-- {
-- 	...
-- 	myButton = InterfaceOutlet( "ButtonUniqueIdentifier" );	
-- 	...
-- }

class "InterfaceOutlet" {
	viewIdentifier = false;
	key = false;
	container = false;
	views = false;
	trackAll = false; -- whether the outlet keeps track of all views with the given identifier, or just one
}

--[[
	@constructor
	@desc Initialises the interface outlet
	@param [string] viewIdentifier -- the identifier of the desire view
	@param [boolean] trackAll -- whether to track all view with the identifier, or just one
	@param [Container] owner -- the container that owns the outlet
]]
function InterfaceOutlet:initialise( viewIdentifier, trackAll, owner ) -- if you change this you need to change it in class.lua uniqueTable() too
	trackAll = trackAll or false
	self.viewIdentifier = viewIdentifier
	self.trackAll = trackAll
	self.owner = owner or false

	if trackAll then
		self.views = {}
	end
end

--[[
	@instance
	@desc Connects the interface outlet to the given Container with the given key
	@param [string] key -- the key in the container of this interface outlet
	@param [Container] container -- the container to connect to
]]
function InterfaceOutlet:connect( key, container )
	self:disconnect()

	self.key = key
	self.container = container
	self.container.interfaceOutlets[key] = self

	-- see if there is a view with our identifier already present and bind it
	if self.trackAll then
		self.views = container:findChildren( self.identifier )
	else
		self.views = container:findChild( self.identifier )
	end
	-- When you index the the outlet it will return tracked view( s )
	self.container["get" .. self.key:sub( 1, 1 ):upper() .. self.key:sub( 2, -1 )] = function( container )
		return self.views
	end
end

function InterfaceOutlet:setViews( views )
	local oldViews = self.views
	self.views = views
	local event = self.owner.event
	if event then event:handleEvent( InterfaceOutletChangedInterfaceEvent( self, views, oldViews ) ) end
end

--[[
	@instance
	@desc Disconnects the interface outlet from the Container
	@param [string] key -- the key in the container of this interface outlet
	@param [Container] container -- the container to connect to
]]
function InterfaceOutlet:disconnect()
	self.container = false
	local key = self.key
	if key and container then
		self.container["get" .. self.key:sub( 1, 1 ):upper() .. self.key:sub( 2, -1 )] = nil
		self.container.interfaceOutlets[self.key] = nil
	end
	self.key = nil
	self.views = nil
end

--[[
	@instance
	@desc Called when a child was added to the container. If it's our identifier, track it (if we don't already have a view or we're tracking all)
	@param [View] childView -- the view that was just added
	@param [boolean] lookInChildren -- whether the
	@return [boolean] wasFound -- whether the view was found, only true if trackAll is false
]]
function InterfaceOutlet:childAdded( childView, lookInChildren )
	local viewIdentifier = self.viewIdentifier
	local trackAll = self.trackAll
	local views = self.views
	local didAdd = false

	local function search( view )
		if view.identifier == viewIdentifier then
			if trackAll then
				didAdd = true
				table.insert( views, view )
			elseif not views then
				self.views = view
				self.owner.event:handleEvent( InterfaceOutletChangedInterfaceEvent( self, view, views ) )
				return true
			end
		end
		if lookInChildren and view:typeOf( Container ) then
			for i, v in ipairs( view.children ) do
				if search( v ) then return true end
			end
		end
	end

	local found = search( childView ) or false

	if trackAll and didAdd then
		self.owner.event:handleEvent( InterfaceOutletChangedInterfaceEvent( self, views, views ) )
	end

	return found
end

--[[
	@instance
	@desc Called when a child was removed from the container. If it's our identifier stop tracking it.
	@param [View] childView -- the view that was just added
]]
function InterfaceOutlet:childRemoved( childView )
	if childView.identifier == self.viewIdentifier then
		local views = self.views
		if self.trackAll then
			local didRemove = false
			for i, trackedView in ipairs( views ) do
				if trackedView == childView then
					views[i] = nil
					didRemove = true
				end
			end
			self.owner.event:handleEvent( InterfaceOutletChangedInterfaceEvent( self, views, views ) )
		elseif views then
			views = nil
			self.owner.event:handleEvent( InterfaceOutletChangedInterfaceEvent( self, nil, views ) )
		end
	end
end
