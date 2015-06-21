
class "SegmentContainer" extends "Container" {
	
}

--[[
	@instance
	@desc Updates the location and size of the menu as well as the location and size of the menu items
]]
function SegmentContainer:updateLayout()
	if self.isVisible then
		local width = 0
		local height = 0
		for i, childView in ipairs( self.children ) do
			height = math.max( height, childView.height )
		end

		for i, childView in ipairs( self.children ) do
			childView.x = width + 1
			childView.y = 1
			width = width + childView.width
			childView:updateCanvas()
		end
		self.width = width
		self.height = height
	end
end

function SegmentContainer:insert( ... )
	self.super:insert( ... )
	self:updateLayout()
end

function SegmentContainer:removeChild( ... )
	self.super:removeChild( ... )
	self:updateLayout()
end