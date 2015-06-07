class "ApplicationEventManager" extends "EventManager" {
	handlesGlobal = nil;
}

--[[
	@instance
	@desc Perfoms the appropriate handles for the given event and then trickles them down through the owner's children
	@param [Event] event -- the event to handle
	@return [boolean] cancelPropagation -- whether no further handles should recieve this event
]]
function ApplicationEventManager:handleEvent( event )
	-- run the before phase handles first
	if self:handleEventPhase( event, self.phase.BEFORE ) then
		return true
	end

	-- TODO: figure out this relative coordinates buisness
	-- start trickling the event down
	event:makeRelative( childView )
	if self.owner.container.event:handleEvent( event ) then
		return true
	end

	-- if nothing has killed the flow yet run the after phases
	return self:handleEventPhase( event, self.phase.AFTER )
end

function EventManager:connectGlobal()
	error( "Cannot connect global handle on ApplicationEventManager as it is the global handler. Use the handler's own manager.")
end

function EventManager:disconnectGlobal()
	error( "Cannot disconnect global handle on ApplicationEventManager as it is the global handler. Use the handler's own manager.")
end