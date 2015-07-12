
class "EventManager" {
	owner = nil;
	handles = {};
	handlesGlobal = {};

	-- functions can be called either before or after tickle down
	phase = {
		BEFORE = 1;
		AFTER = 2;
	};
}


--[[
	@constructor
	@desc Creates an EventManager for the provided owner, with owner reverting to the EventManager instance
	@param [class] owner -- the owner of the EventManger (i.e. what self will be on function calls)
]]
function EventManager:init( owner )
	self.owner = owner or self
	self.owner = self.owner

	-- allow the class to be called as a shorthand for :connect
	self.mt.__call = function(self, _, ...) return self:connect( ... ) end
	setmetatable( self, self.mt )
end

--[[
	@instance
	@desc Subscribes a function to the given event
	@param [Event.eventType] eventType -- the name of the event type
	@param [EventManager] eventManager -- the handle manager 
	@param [function] func -- the function called when the event occurs
	@param [class] sender -- the value passed as self. defaults to eventManager.owner
]]
function EventManager:connect( eventType, func, phase, eventManager, sender )
	if not eventType then error( "No event type given to EventManager:connect!", 2 ) end
	
	if func and type( func ) == "function" then
		phase = phase or EventManager.phase.BEFORE
		eventManager = eventManager or self
		self:disconnect( eventType, func, phase, eventManager, sender ) -- ensure duplicates won't be made

		if not self.handles[eventType] then
			self.handles[eventType] = {}
		end

		table.insert( self.handles[eventType], { func, phase, eventManager, sender or eventManager.owner } )
	else
		error( "Attempted to connect non-function to event: " .. eventType .. ' for class: ' .. tostring( self.owner or nil ), 0 )
	end
end

--[[
	@instance
	@desc Unsubscribes a function to the given event
	@param [Event.eventType] eventType -- the name of the event type
	@param [function] func -- the function called when the event occurs
	@param [class] sender -- the value passed as self. defaults to eventManager.owner
]]
function EventManager:disconnect( eventType, func, phase, eventManager, sender )
	phase = phase or EventManager.phase.BEFORE
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
	@instance
	@desc Subscribes a function globally to the given event
	@param [Event.eventType] eventType -- the name of the event type
	@param [function] func -- the function called when the event occurs
]]
function EventManager:connectGlobal( eventType, func, phase )
	if func and type( func ) == "function" then
		phase = phase or EventManager.phase.BEFORE
		self:disconnectGlobal( eventType, func ) -- ensure duplicates won't be made

		if not self.handlesGlobal[eventType] then
			self.handlesGlobal[eventType] = {}
		end

		table.insert( self.handlesGlobal[eventType], { func, phase } )

		self.application.event:connect( eventType, func, phase, self )
	else
		error( "Attempted to connect non-function to global event: " .. eventType .. ' for class: ' .. tostring( self.owner or nil ), 0 )
	end
end

--[[
	@instance
	@desc Unsubscribes a function to globally the given event
	@param [Event.eventType] eventType -- the name of the event type
	@param [function] func -- the function called when the event occurs
]]
function EventManager:disconnectGlobal( eventType, func, phase )
	phase = phase or EventManager.phase.AFTER
	self.application.event:disconnect( eventType, func, phase, self )

	if self.handlesGlobal[eventType] then
		for i, handle in pairs( self.handlesGlobal[eventType] ) do
			if handle[1] == func and handle[2] == phase then
				self.handlesGlobal[eventType][i] = nil
			end
		end
	end
end

--[[
	@instance
	@desc Unsubscribes all global events
]]
function EventManager:disconnectAllGlobals()
	for eventType, v in pairs( self.handlesGlobal ) do
		for i, handle in pairs( v ) do
			self.application.event:disconnect( eventType, handle[1], handle[2], self )
			v[i] = nil
		end
	end
end

--[[
	@instance
	@desc Returns true if the EventManager has any handles for the given type
	@param [Event.eventType] eventType -- the name of the even type
	@return [boolean] hasConnections
]]
function EventManager:hasConnections( eventType )
	return self.handles[eventType] and #self.handles[eventType] >= 1
end

--[[
	@instance
	@desc Returns true if the EventManager has any global handles for the given type
	@param [Event.eventType] eventType -- the name of the even type
	@return [boolean] hasConnections
]]
function EventManager:hasConnectionsGlobal( eventType )
	return self.handlesGlobal[eventType] and #self.handlesGlobal[eventType] >= 1
end

--[[
	@instance
	@desc Perfoms the appropriate handles for the given event
	@param [Event] event -- the event to handle
	@return [boolean] stopPropagation -- whether no further handles should recieve this event
]]
function EventManager:handleEvent( event )
	if self:handleEventPhase( event, self.phase.BEFORE ) then
		return true
	end

	if self:handleEventPhase( event, self.phase.AFTER ) then
		return true
	end
end

--[[
	@instance
	@desc Performs the handles for a specific phase
	@param [Event] event -- the event to handle
	@param [EventManager.phase] phase -- the phase desired
	@return [boolean] stopPropagation -- whether no further handles should recieve this event
]]
function EventManager:handleEventPhase( event, phase )
	if self.handles[event.eventType] then
		for i, handle in pairs( self.handles[event.eventType] ) do
			if handle and phase == handle[2] then
				-- handle[1] is the handle function
				-- handle[2] is the phase
				-- handle[3] is the event manager
				if handle[1]( handle[4], event, handle[2] ) then
					return true
				end
			end
		end
	end
end

function EventManager:dispose()
	self:disconnectAllGlobals()
end
