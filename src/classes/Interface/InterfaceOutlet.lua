
-- This class allows you to connect a container's view to a property in the class definition and in code.
-- It keeps track of the child view and changes the reference when removed/added
-- Simply connect like so:
-- {
-- 	...
-- 	myButton = InterfaceOutlet( "ButtonUniqueIdentifier" );	
-- 	...
-- }

class "InterfaceOutlet" {
	viewIdentifier = nil;
	key = nil;
	container = nil;
	views = nil;
	trackAll = false; -- whether the outlet keeps track of all views with the given identifier, or just one
}

--[[
	@constructor
	@desc Initialises the interface outlet
	@param [string] viewIdentifier -- the identifier of the desire view
	@param [boolean] trackAll -- whether to track all view with the identifier, or just one
]]
function InterfaceOutlet:init( viewIdentifier, trackAll ) -- if you change this you need to change it in class.lua uniqueTable() too
	trackAll = trackAll or false
	self.viewIdentifier = viewIdentifier
	self.trackAll = trackAll

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

	-- When you index the the outlet it will return tracked view(s)
	self.container['get' .. self.key:sub( 1, 1 ):upper() .. self.key:sub( 2, -1 )] = function( container )
		return self.views
	end
end

--[[
	@instance
	@desc Disconnects the interface outlet from the Container
	@param [string] key -- the key in the container of this interface outlet
	@param [Container] container -- the container to connect to
]]
function InterfaceOutlet:disconnect()
	self.container = nil
	local key = self.key
	if key and container then
		self.container['get' .. self.key:sub( 1, 1 ):upper() .. self.key:sub( 2, -1 )] = nil
		self.container.interfaceOutlets[self.key] = nil
	end
	self.key = nil
	self.views = nil
end

--[[
	@instance
	@desc Called when a child was added to the container. If it's our identifier, track it (if we don't already have a view or we're tracking all)
	@param [View] childView -- the view that was just added
]]
function InterfaceOutlet:childAdded( childView )
	if childView.identifier == self.viewIdentifier then
		if self.trackAll then
			table.insert( self.views, childView )
		elseif not self.views then
			self.views = childView
		end
	end
end

--[[
	@instance
	@desc Called when a child was removed from the container. If it's our identifier stop tracking it.
	@param [View] childView -- the view that was just added
]]
function InterfaceOutlet:childRemoved( childView )
	if childView.identifier == self.viewIdentifier then
		if self.trackAll then
			for i, trackedView in ipairs( self.views ) do
				if trackedView == childView then
					self.views[i] = nil
				end
			end
		elseif self.views then
			self.views = nil
		end
	end
end
