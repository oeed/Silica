
-- This class allows you to connect a container's view to a property in the class definition and in code.
-- It keeps track of the child view and changes the reference when removed/added
-- Simply connect like so:
-- {
-- 	...
-- 	myButton = InterfaceOutlet( "ButtonUniqueIdentifier" );	
-- 	...
-- }

-- TODO: update interface outlets when the .identifer of a view is changed

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
	@param [Container] container -- the container that owns the outlet
]]
 -- if you change this you need to change it in class.lua uniqueTable() too
function InterfaceOutlet:initialise( viewIdentifier, trackAll, key, container )
	trackAll = trackAll or false
	self.viewIdentifier = viewIdentifier or false
	self.trackAll = trackAll or false
	self.key = key or false
	self.container = container or false
	
	if trackAll then
		self.views = container and container:findChildren( self.viewIdentifier ) or false
	else
		self.views = container and container:findChild( self.viewIdentifier ) or false
	end
end

--[[
	@instance
	@desc Sets the current views the outlet points to
	@param [table/View] views -- the view or views
]]
function InterfaceOutlet.views:set( views )
	local oldViews = self.views
	self.views = views

	local container = self.container
	if container then
		local event = container.event
		container[self.key] = views
		if event then event:handleEvent( InterfaceOutletChangedInterfaceEvent( self, views, oldViews ) ) end
	end
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
	local didAdd = false
	local container, views = self.container, self.views

	local function search( view )
		if view.identifier == viewIdentifier then
			if trackAll then
				didAdd = true
				table.insert( views, view )
			elseif not views then
				self.views = view
				container.event:handleEvent( InterfaceOutletChangedInterfaceEvent( self, view, views ) )
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
		container.event:handleEvent( InterfaceOutletChangedInterfaceEvent( self, views, views ) )
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
			self.container.event:handleEvent( InterfaceOutletChangedInterfaceEvent( self, views, views ) )
		elseif views then
			views = nil
			self.container.event:handleEvent( InterfaceOutletChangedInterfaceEvent( self, nil, views ) )
		end
	end
end
