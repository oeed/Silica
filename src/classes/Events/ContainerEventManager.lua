class "ContainerEventManager" extends "EventManager" {}

function ContainerEventManager:init( parent )
end

function ContainerEventManager:handleEvent( Event[instance] event ) -- also passes event to children, but if child event handler returns true, it stops and also returns true
end