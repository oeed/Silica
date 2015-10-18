
-- TODO: this needs some fixes to make the last button have a gap on it's left when pushed

class "SegmentButton" extends "Button" {
	
	separatorObject = false;

}

function SegmentButton:initialise( ... )
    self.super:initialise( ... )
    self:event( Event.PARENT_CHANGED, self.onSiblingOrParentChanged )
    self:event( Event.SIBLING_ADDED, self.onSiblingOrParentChanged )
    self:event( Event.SIBLING_ADDED, self.onSiblingOrParentChanged )
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function SegmentButton:initialiseCanvas()
	self.super:initialiseCanvas()
    local separatorBackgroundObject = self.canvas:insert( Rectangle( self.width, 1, 1, self.height -1 ) )
    self.separatorObject = self.canvas:insert( Separator( self.width, 3, 1, self.height - 4 ) )
    separatorBackgroundObject.leftOutlineWidth = 0
    separatorBackgroundObject.rightOutlineWidth = 0
    local theme = self.theme
    theme:connect( separatorBackgroundObject, "fillColour", "separatorFillColour" )
    theme:connect( separatorBackgroundObject, "dotColour", "separatorDotColour" )
    theme:connect( separatorBackgroundObject, "outlineColour", "separatorOutlineColour" )
    theme:connect( self, "centerMargin" )
    self.separatorBackgroundObject = separatorBackgroundObject
    theme:disconnect( self.backgroundObject, "radius", "cornerRadius" )
    theme:disconnect( self.shadowObject, "radius", "cornerRadius" )
end

function SegmentButton:setWidth( width )
    self.super.super:setWidth( width )
    local isFirst = self.isFirst
    local isLast = self.isLast
    self.backgroundObject.width = isLast and width - 1 or width - 1
    self.shadowObject.width = (isLast or isFirst) and width - 1 or width
    self.separatorObject.x = width
    self.separatorBackgroundObject.x = width
    
    local textObject = self.textObject
    local leftMargin, rightMargin = self.leftMargin, self.rightMargin
    textObject.x = self.isPressed and leftMargin + 2 or leftMargin + 1
    textObject.width = width - leftMargin - rightMargin
    self.parent.needsLayoutUpdate = true
end

function SegmentButton:getRightMargin()
    return self.isLast and self.rightMargin or self.centerMargin
end

function SegmentButton:getLeftMargin()
    return self.isFirst and self.leftMargin or self.centerMargin
end

function SegmentButton:setIsPressed( isPressed )
    self.super:setIsPressed( isPressed )
    local isFirst = self.isFirst
    local isLast = self.isLast
    if isLast then
        local width = self.width
        self.backgroundObject.x = isPressed and 2 or 1
        self.backgroundObject.width = isPressed and width - 2 or width - 1
    end
end

--[[
    @instance
    @desc Fired when it's siblings changed or it is added/removed from it's parent
    @param [Event] event -- the event
]]
function SegmentButton:onSiblingOrParentChanged( event )
    local backgroundObject = self.backgroundObject
    local shadowObject = self.shadowObject
    local isFirst = self.isFirst
    local isLast = self.isLast
    local theme = self.theme

    shadowObject.x = (isLast or isFirst) and 2 or 1
    backgroundObject.leftOutlineWidth = isFirst and 1 or 0
    backgroundObject.rightOutlineWidth = isLast and 1 or 0
    self.separatorObject.isVisible = not isLast
    self.separatorBackgroundObject.isVisible = not isLast


    if isFirst then
        theme:connect( backgroundObject, "leftRadius", "cornerRadius" )
        theme:connect( shadowObject, "leftRadius", "cornerRadius" )
    else
        theme:disconnect( backgroundObject, "leftRadius", "cornerRadius" )
        theme:disconnect( shadowObject, "leftRadius", "cornerRadius" )
    end

    if isLast then
        theme:connect( backgroundObject, "rightRadius", "cornerRadius" )
        theme:connect( shadowObject, "rightRadius", "cornerRadius" )
    else
        theme:disconnect( backgroundObject, "rightRadius", "cornerRadius" )
        theme:disconnect( shadowObject, "rightRadius", "cornerRadius" )
    end


    local width = self.width
    local isPressed = self.isPressed
    -- backgroundObject.width = (isLast and isPressed) and width or width - 1
    shadowObject.width = ((isLast and not isPressed) or isFirst) and width - 1 or width
end