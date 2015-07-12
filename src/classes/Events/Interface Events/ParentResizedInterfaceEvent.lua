
class "ParentResizeInterfaceEvent" extends "InterfaceEvent" {
	eventType = Event.PARENT_RESIZED;
	isHorizontal = false;
	isVertical = false;
	isSentToSender = false;
	isSentToChildren = true;
}

--[[
	@constructor
	@desc Creates a parent resized event from the arguments
	@param [boolean] isHorizontal -- whether the change effected the width
	@param [boolean] isVertical -- whether the change effected the height
	@param [Container] sender -- the parent that resized
]]
function ParentResizeInterfaceEvent:init( isHorizontal, isVertical, sender )
	self.isHorizontal = isHorizontal
	self.isVertical = isVertical
	self.sender = sender
end

