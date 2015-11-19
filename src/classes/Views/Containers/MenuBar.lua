
class "MenuBar" extends "Container" {
	needsLayoutUpdate = false;	
    separatorObject = false;
}

function MenuBar:initialiseCanvas()
    self:super()
    local separatorObject = self.canvas:insert( Rectangle( 1, self.height, self.width, 1 ) )
    self.theme:connect( separatorObject, "fillColour", "separatorColour" )
    self.theme:connect( self.canvas, "fillColour" )
    self.separatorObject = separatorObject
end

function MenuBar:updateThemeStyle()
    self.theme.style = self.isEnabled and "default" or "disabled"
end

--[[
	@instance
	@desc Updates the location of the menu bar items
]]
function MenuBar:updateLayout()
	local x = 6
	local height = 1
	for i, childView in ipairs( self.children ) do
		childView.x = x
		x = x + childView.width
		height = math.max( height, childView.height )
	end
	self.height = height
	self.needsLayoutUpdate = false
end

function MenuBar:update( deltaTime )
    self:super( deltaTime )
    if self.needsLayoutUpdate then
        self:updateLayout()
    end
end

function MenuBar:updateWidth( width )
	self.separatorObject.width = width
end

function MenuBar:updateHeight( Height )
	self.separatorObject.y = Height
end

function MenuBar.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function MenuBar.isVisible:set( isVisible )
	self.super:setIsVisible( isVisible )
	if isVisible then
		self.needsLayoutUpdate = true
	end
end

function MenuBar:insert( ... )
	self:super( ... )
	self.needsLayoutUpdate = true
end

function MenuBar:removeChild( ... )
	self:super( ... )
	self.needsLayoutUpdate = true
end
