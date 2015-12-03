
class "ParentResizedInterfaceEvent" extends "InterfaceEvent" {

    static = {
        eventType = "interface_parent_resized";
    };
	isHorizontal = Boolean( false );
	isVertical = Boolean( false );
	isSentToSender = Boolean( false );
	isSentToChildren = Boolean( true );

}

--[[
	@constructor
	@desc Creates a parent resized event from the arguments
	@param [boolean] isHorizontal -- whether the change effected the width
	@param [boolean] isVertical -- whether the change effected the height
	@param [Container] sender -- the parent that resized
]]
function ParentResizedInterfaceEvent:initialise( isHorizontal, isVertical, sender )
	self.isHorizontal = isHorizontal
	self.isVertical = isVertical
	self.sender = sender
end

