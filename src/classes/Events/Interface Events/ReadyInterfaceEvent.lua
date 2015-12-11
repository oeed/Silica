
class "ReadyInterfaceEvent" extends "InterfaceEvent" {

    static = {
        eventType = "interface_ready";
    };

    isSentToChildren = Boolean( false );

}

--[[
	@constructor
	@desc Creates a ready event from the arguments
]]
function ReadyInterfaceEvent:initialise()
end

