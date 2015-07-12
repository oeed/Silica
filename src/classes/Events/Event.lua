
class "Event" {
	
	relativeView = false; -- the view that the event is relative of
	eventType = false;

	isSentToChildren = true; -- whether the event will be passed to children
	isSentToSender = true; -- whether the event will be handled by the sender

	MOUSE_UP = "mouse_up";
	MOUSE_DOWN = "mouse_click";
	MOUSE_DRAG = "mouse_drag";
	MOUSE_SCROLL = "mouse_scroll";
	KEY_DOWN = "key";
	KEY_UP = "key_up";
	CHARACTER = "char";
	TIMER = "timer";
	TERMINATE = "terminate";
	MENU_CHANGED = "interface_menu_changed";
	INTERFACE_LOADED = "interface_loaded";
	KEYBOARD_SHORTCUT = "interface_keyboard_shortcut";
	FOCUS_CHANGED = "interface_focus";
	TEXT_CHANGED = "interface_text";
	SIBLING_ADDED = "interface_sibling_added";
	SIBLING_REMOVED = "interface_sibling_removed";
	PARENT_CHANGED = "interface_parent_changed";
	PARENT_RESIZED = "interface_parent_resized";
	INTERFACE_READY = "interface_ready";
	INTERFACE_OUTLET_CHANGED = "interface_outlet_changed";
	ACTION = "interface_action";

}

local eventClasses = {}

--[[
	@static
	@desc Registers an Event subclass to a event type name (e.g. MouseDownEvent links with "mouse_down")
	@param [class] _class -- the class that was constructed
]]
function Event.register( eventType, subclass )
	eventClasses[eventType] = subclass
end

--[[
	@static
	@desc Registers an Event subclass after it has just been constructed
	@param [class] _class -- the class that was constructed
]]
function Event.constructed( _class )
	if _class.eventType then
		Event.register( _class.eventType, _class )
	end
end

--[[
	@static
	@desc Creates an event with the arguments in a table from os.pullEvent or similar function
	@param [Event.eventTypes] eventType -- the event type
	@param ... -- the event arguments
	@return [Event] event
]]
function Event.create( eventType, ... )
	if not eventType then error( "No event type given to Event.create!", 0 ) end

	local eventClass = eventClasses[eventType]
	if eventClass then
		return eventClass( ... )
	else
		return Event()
	end
end

--[[
	@instance
	@desc Make the event relative to the supplied view
	@param [View] view -- the view to be relative to
]]
function Event:makeRelative( view )
	self.relativeView = view
end
