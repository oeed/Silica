
class "EventManager" {
	owner = false;
	handles = {};
	handlesGlobal = {};
}


--[[
	@constructor
	@desc Creates an EventManager for the provided owner, with owner reverting to the EventManager instance
	@param [class] owner -- the owner of the EventManger (i.e. what self will be on function calls)
]]
function EventManager:initialise( owner )
	self.owner = owner or self
	self.owner = self.owner
	-- allow the class to be called as a shorthand for :connect
	self.metatable.__call = function(self, _, ...) return self:connect( ... ) end
	-- setmetatable( self, self.mt )
end

--[[
	@desc Subscribes a function to the given event
	@param [Event.eventType] eventType -- the name of the event type
	@param [EventManager] eventManager -- the handle manager 
	@param [function] func -- the function called when the event occurs
	@param [class] sender -- the value passed as self. defaults to eventManager.owner
]]
function EventManager:connect( Event eventType, Function func, Event.phases( Event.phases.BEFORE ) phase, EventManager.allowsNil eventManager, sender )
	eventManager = eventManager or self -- TODO: allow self in default values
	self:disconnect( eventType, func, phase, eventManager, sender ) -- ensure duplicates won't be made

	if not self.handles[eventType] then
		self.handles[eventType] = {}
	end

	table.insert( self.handles[eventType], { func, phase, eventManager, sender or eventManager.owner } )
end

--[[
	@desc Unsubscribes a function to the given event
	@param [Event] eventType -- the name of the event type
	@param [function] func -- the function called when the event occurs
	@param [class] sender -- the value passed as self. defaults to eventManager.owner
]]
function EventManager:disconnect( eventType, func, phase, eventManager, sender )
	phase = phase or Event.phases.BEFORE
	eventManager = eventManager or self
	sender = sender or eventManager.owner

	if self.handles[eventType] then
		for i, handle in pairs( self.handles[eventType] ) do
			if handle[1] == func and handle[2] == phase and handle[3] == eventManager and handle[4] == sender then
				self.handles[eventType][i] = nil
			end
		end
	end
end

--[[
	@desc Subscribes a function globally to the given event
	@param [Event.eventType] eventType -- the name of the event type
	@param [function] func -- the function called when the event occurs
]]
function EventManager:connectGlobal( eventType, func, phase, sender )
	if func and type( func ) == "function" then
		phase = phase or Event.phases.BEFORE
		sender = sender or self.owner
		self:disconnectGlobal( eventType, func, phase, sender ) -- ensure duplicates won't be made

		if not self.handlesGlobal[eventType] then
			self.handlesGlobal[eventType] = {}
		end

		table.insert( self.handlesGlobal[eventType], { func, phase, sender } )
		self.application.event:connect( eventType, func, phase, self, sender )
	else
		error( "Attempted to connect non-function to global event: " .. eventType .. ' for class: ' .. tostring( self.owner or nil ), 0 )
	end
end

--[[
	@desc Unsubscribes a function to globally the given event
	@param [Event.eventType] eventType -- the name of the event type
	@param [function] func -- the function called when the event occurs
]]
function EventManager:disconnectGlobal( eventType, func, phase, sender, eventManager )
	phase = phase or Event.phases.BEFORE
	sender = sender or self.owner
	self.application.event:disconnect( eventType, func, phase, self, sender )

	if self.handlesGlobal[eventType] then
		for i, handle in pairs( self.handlesGlobal[eventType] ) do
			if handle[1] == func and handle[2] == phase and handle[3] == eventManager and handle[4] == sender then
				self.handlesGlobal[eventType][i] = nil
			end
		end
	end
end

--[[
	@desc Unsubscribes all global events
]]
function EventManager:disconnectAllGlobals()
	for eventType, v in pairs( self.handlesGlobal ) do
		for i, handle in pairs( v ) do
			self.application.event:disconnect( eventType, handle[1], handle[2], handle[3], self)
			v[i] = nil
		end
	end
end

--[[
	@desc Returns true if the EventManager has any handles for the given type
	@param Event.class eventType -- the name of the even type
	@return [boolean] hasConnections
]]
function EventManager:hasConnections( class )
	for handleClass, handles in pairs( self.handles ) do
		if #handles >= 1 and class:typeOf( handleClass ) then
			return true
		end
	end
end

--[[
	@desc Returns true if the EventManager has any global handles for the given type
	@param [Event.eventType] eventType -- the name of the even type
	@return [boolean] hasConnections
]]
function EventManager:hasConnectionsGlobal( class )
	for handleClass, handles in pairs( self.handlesGlobal ) do
		if #handles >= 1 and class:typeOf( handleClass ) then
			return true
		end
	end
end

--[[
	@desc Perfoms the appropriate handles for the given event
	@param [Event] event -- the event to handle
	@return [boolean] stopPropagation -- whether no further handles should recieve this event
]]
function EventManager:handleEvent( event )
	if self:handleEventPhase( event, Event.phases.BEFORE ) then
		return true
	end

	if self:handleEventPhase( event, Event.phases.AFTER ) then
		return true
	end
end

--[[
	@desc Performs the handles for a specific phase
	@param [Event] event -- the event to handle
	@param [EventManager.phase] phase -- the phase desired
	@return [boolean] stopPropagation -- whether no further handles should recieve this event
]]
function EventManager:handleEventPhase( event, phase )
	local class = event.class
	for handleClass, handles in pairs( self.handles ) do
		if class:typeOf( handleClass ) then
			for i, handle in pairs( handles ) do
				if handle and phase == handle[2] then
					-- handle[1] is the handle function
					-- handle[2] is the phase
					-- handle[3] is the event manager
					-- handle[4] is the sender
					local response = handle[1]( handle[4], event, handle[2] ) -- if response is true stop propagation, if false continue
					-- TODO: maybe enforce returning boolean for event handler functions
					-- if response ~= true and response ~= false then
					-- 	error( "Error handler for event '" .. eventType .. "' of instance '" .. tostring( handle[4] ) .. "' did not return boolean. If the event should not be sent to anything else (i.e. stop propagation) return true, otherwise, if it can continue being passed around, return false.", 0 )
					-- end

					if response then
						return true
					end
				end
			end
		end
	end
end

function EventManager:dispose()
	self:disconnectAllGlobals()
end
