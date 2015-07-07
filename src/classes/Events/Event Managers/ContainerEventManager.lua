
class "ContainerEventManager" extends "EventManager" {}

--[[
	@instance
	@desc Perfoms the appropriate handles for the given event and then trickles them down through the owner's children
	@param [Event] event -- the event to handle
	@return [boolean] stopPropagation -- whether no further handles should recieve this event
]]
function ContainerEventManager:handleEvent( event )
	if self:handleEventPhase( event, self.phase.BEFORE ) then
		return true
	end

	if event.isSentToChildren then
		local owner = self.owner
		local children = owner.children
		for i = #children, 1, -1 do
			childView = children[i]
			if childView:typeOf( Container ) or childView.event:hasConnections( event.eventType ) then
				if childView:hitTestEvent( event, owner ) then
					event:makeRelative( childView )
					if childView.event:handleEvent( event ) then
						return true
					end
					event:makeRelative( owner )
				end
			end
		end
	end
		
	if self:handleEventPhase( event, self.phase.AFTER ) then
		return true
	end
end
