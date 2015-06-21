
class "SegmentButton" extends "Button" {
	
	separatorObject = nil;

}


--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function SegmentButton:initCanvas()
	self.super:initCanvas()
    self.separatorObject = self.canvas:insert( Separator( self.width, 3, 1, self.width - 4 ) )
end

--[[
    @instance
    @desc Update the canvas appearance.
]]
function SegmentButton:updateCanvas()
	self.super:updateCanvas()
    local backgroundObject = self.backgroundObject
    if self.canvas and backgroundObject then
    	local shadowObject = self.shadowObject
    	local isFirst = self.index == 1
    	local isLast = self.index == #self.parent.children

    	backgroundObject.width = isLast and self.width - 1 or self.width
    	shadowObject.width = (isLast or isFirst) and self.width - 1 or self.width
    	shadowObject.x = (isLast or isFirst) and 2 or 1

    	self.separatorObject.isVisible = not isLast and not self.isPressed

        if not (isLast or isFirst) and self.isPressed then
            backgroundObject.x = 1
        end

    	backgroundObject.leftOutlineWidth = isFirst and 1 or 0
    	backgroundObject.rightOutlineWidth = isLast and 1 or 0

        local leftRadius = isFirst and self.cornerRadius or 0
        local rightRadius = isLast and self.cornerRadius or 0
        backgroundObject.topLeftRadius = leftRadius
        backgroundObject.bottomLeftRadius = leftRadius
        backgroundObject.topRightRadius = rightRadius
        backgroundObject.bottomRightRadius = rightRadius
        shadowObject.topLeftRadius = leftRadius
        shadowObject.bottomLeftRadius = leftRadius
        shadowObject.topRightRadius = rightRadius
        shadowObject.bottomRightRadius = rightRadius
    end
end
