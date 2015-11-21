
local eventClasses = {}

class "Event" {
	
	eventType = false;

	static = {
		eventType = false;
	};

	relativeView = false; -- the view that the event is relative of
    sender = false;

	isSentToChildren = true; -- whether the event will be passed to children
	isSentToSender = true; -- whether the event will be handled by the sender

	-- functions can be called either before or after tickle down
	phases = Enum( Number, {
		BEFORE = 1;
		AFTER = 2;
	} );
}

--[[
	@static
	@desc Registers an Event subclass to a event type name (e.g. MouseDownEvent links with "mouse_down")
	@param [class] _class -- the class that was constructed
]]
function Event.static:register( eventType, subclass )
	eventClasses[eventType] = subclass
end

--[[
	@static
	@desc Registers an Event subclass after it has just been constructed
]]
function Event.static:initialise()
	local eventType = self.eventType
	if eventType then
		Event.static:register( self.eventType, self.class )
	end
end

--[[
	@static
	@desc Creates an event with the arguments in a table from os.pullEvent or similar function
	@param [Event.eventTypes] eventType -- the event type
	@param ... -- the event arguments
	@return [Event] event
]]
function Event.static:create( eventType, ... )
	if not eventType then error( "No event type given to Event.create!", 0 ) end

	local eventClass = eventClasses[eventType]
	local event
	if eventClass then
		event = eventClass( ... )
	else
		event = Event()
	end
	event.eventType = eventType
	return event
end

--[[
	@instance
	@desc Make the event relative to the supplied view
	@param [View] view -- the view to be relative to
]]
function Event:makeRelative( view )
	self.relativeView = view
end
