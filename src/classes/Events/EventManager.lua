class "EventManager" {}


--[[
	@instance
	@desc Creates an EventManager for the provided owner
	@param [class] onwer -- the owner of the EventManger (i.e. what self will be on function calls)
]]
function EventManager:init( onwer )
	
end

function EventManager:connect( Event[enum] eventName, function handler )
end

function EventManager:disconnect( Event[enum] eventName, function handler )
end

function EventManager:connectGlobal( Event[enum] eventName, function handler )
end

function EventManager:disconnectGlobal( Event[enum] eventName, function handler )
end

function EventManager:handleGlobalEvent( Event[instance] event )
	for i, v in ipairs( self.globalHandlers[event.name] ) do
		v( self.parent, event )
	end
end

function EventManager:handleEvent( Event[instance] event )
	for i, v in ipairs( self.handlers[event.name] ) do
		v( self.parent, event )
	end
end
--@static

function EventManager.handleGlobals( Event[instance] event )