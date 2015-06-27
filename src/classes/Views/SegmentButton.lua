
class "SegmentButton" extends "Button" {
	
	separatorObject = nil;

}


--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function SegmentButton:initCanvas()
	self.super:initCanvas()
    local separatorBackgroundObject = self.canvas:insert( Rectangle( self.width, 1, 1, self.height -1 ) )
    self.separatorObject = self.canvas:insert( Separator( self.width, 3, 1, self.height - 4 ) )
    separatorBackgroundObject.leftOutlineWidth = 0
    separatorBackgroundObject.rightOutlineWidth = 0
    self.theme:connect( separatorBackgroundObject, 'fillColour' )
    self.theme:connect( separatorBackgroundObject, 'outlineColour' )
    self.separatorBackgroundObject = separatorBackgroundObject
    self.theme:disconnect( self.backgroundObject, 'radius', 'cornerRadius' )
    self.theme:disconnect( self.shadowObject, 'radius', 'cornerRadius' )
end

function SegmentButton:setWidth( width )
    self.super.super:setWidth( width )
    local isFirst = self.index == 1
    local isLast = self.parent and (self.index == #self.parent.children) or false
    self.backgroundObject.width = isLast and width - 2 or width - 2
    self.shadowObject.width = (isLast or isFirst) and width - 1 or width
end

function SegmentButton:setIsPressed( isPressed )
    self.super:setIsPressed( isPressed )

    local isFirst = self.index == 1
    local isLast = self.parent and (self.index == #self.parent.children) or false
    if not isFirst and isPressed then
        self.backgroundObject.x = 1
    end

    if isLast then
        local width = self.width
        self.backgroundObject.width = isPressed and width or width - 1
    end
end

--[[
    @instance
    @desc Fired when it's siblings changed or it is added/removed from it's parent
]]
function SegmentButton:onSiblingsChanged()
    local backgroundObject = self.backgroundObject
    local shadowObject = self.shadowObject
    local index = self.index
    local isFirst = index == 1
    local isLast = self.parent and (index == #self.parent.children) or false

    shadowObject.x = (isLast or isFirst) and 2 or 1
    backgroundObject.leftOutlineWidth = isFirst and 1 or 0
    backgroundObject.rightOutlineWidth = isLast and 1 or 0
    self.separatorObject.isVisible = not isLast
    self.separatorBackgroundObject.isVisible = not isLast


    if isFirst then
        self.theme:connect( backgroundObject, 'leftRadius', 'cornerRadius' )
        self.theme:connect( shadowObject, 'leftRadius', 'cornerRadius' )
    else
        self.theme:disconnect( backgroundObject, 'leftRadius', 'cornerRadius' )
        self.theme:disconnect( shadowObject, 'leftRadius', 'cornerRadius' )
    end

    if isLast then
        self.theme:connect( backgroundObject, 'rightRadius', 'cornerRadius' )
        self.theme:connect( shadowObject, 'rightRadius', 'cornerRadius' )
    else
        self.theme:disconnect( backgroundObject, 'rightRadius', 'cornerRadius' )
        self.theme:disconnect( shadowObject, 'rightRadius', 'cornerRadius' )
    end


    local width = self.width
    local isPressed = self.isPressed
    backgroundObject.width = (isLast and isPressed) and width or width - 1
    shadowObject.width = ((isLast and not isPressed) or isFirst) and width - 1 or width
end