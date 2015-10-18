
class "ApplicationEventManager" extends "EventManager" {
	handlesGlobal = false;
}

--[[
	@instance
	@desc Perfoms the appropriate handles for the given event and then trickles them down through the owner's children
	@param [Event] event -- the event to handle
	@return [boolean] stopPropagation -- whether no further handles should recieve this event
]]
function ApplicationEventManager:handleEvent( event )
	-- run the before phase handles first
	if self:handleEventPhase( event, self.phase.BEFORE ) then
		return true
	end

	-- start trickling the event down
	local container = self.owner.container
	if container and container.event:handleEvent( event ) then
		return true
	end

	-- if nothing has killed the flow yet run the after phases
	return self:handleEventPhase( event, self.phase.AFTER )
end

function ApplicationEventManager:connectGlobal()
	error( "Cannot connect global handle on ApplicationEventManager as it is the global handler. Use the class' own manager.", 0 )
end

function ApplicationEventManager:disconnectGlobal()
	error( "Cannot disconnect global handle on ApplicationEventManager as it is the global handler. Use the handler's own manager.", 0 )
end
