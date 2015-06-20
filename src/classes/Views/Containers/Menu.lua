
class "Menu" extends "Container" {
	targetX = 1; -- the desired location of the menu. this is the originally set x value, the actual x value can change to prevent overflowing with the screen
	targetY = 1;

	isPressed = false;
    isEnabled = true;
	isVisible = true;

	topMargin = 3;
	bottomMargin = 5;
	shadowRightMargin = 1;
	shadowTopMargin = 2;

    cornerRadius = 4;

    backgroundColour = Graphics.colours.WHITE;
    outlineColour = Graphics.colours.LIGHT_GREY;

    pressedBackgroundColour = Graphics.colours.BLUE;
    pressedOutlineColour = nil;

    disabledBackgroundColour = Graphics.colours.WHITE;
    disabledOutlineColour = Graphics.colours.LIGHT_GREY;

    shadowColour = Graphics.colours.GREY;

    shadowObject = nil;
    backgroundObject = nil;

    width = 40;
    height = 40;
}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function Menu:init( ... )
	self.super:init( ... )

end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Menu:initCanvas()
    local cornerRadius = self.cornerRadius
    self.shadowObject = self.canvas:insert( RoundedRectangle( 1 + self.shadowRightMargin, 1 + self.shadowTopMargin, self.width - 1, self.height - 2, self.shadowColour, nil, cornerRadius ) )
    self.backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width - 1, self.height - 2, self.backgroundColour, self.outlineColour, cornerRadius ) )
end

function Menu:setHeight( height )
    self.super:setHeight( height )
    if self.canvas then
        self.backgroundObject.height = height - self.shadowTopMargin
        self.shadowObject.height = height - self.shadowTopMargin
    end
end

function Menu:setWidth( width )
    self.super:setWidth( width )
    if self.canvas then
        self.backgroundObject.width = width - self.shadowRightMargin
        self.shadowObject.width = width - self.shadowRightMargin
    end
end

--[[
	@instance
	@desc Updates the location and size of the menu as well as the location and size of the menu items
]]
function Menu:updateLayout()
	if self.isVisible then
		local width = 1
		local height = self.topMargin
		for i, childView in ipairs( self.children ) do
			width = math.max( width, childView.width )
		end
		width = width + (1 - width % 2) -- it must be an odd number (for the separators)
		-- TODO: target position
		for i, childView in ipairs( self.children ) do
			childView.x = 1
			childView.y = height + 1
			height = height + childView.height
			childView.width = width
		end
		self.width = width + self.shadowRightMargin
		self.height = height + self.bottomMargin
	end
end

function Menu:setIsVisible( isVisible )
	self.super:setIsVisible( isVisible )
	self:updateLayout()
end

function Menu:insert( ... )
	self.super:insert( ... )
	self:updateLayout()
end

function Menu:removeChild( ... )
	self.super:insert( ... )
	self:updateLayout()
end

function Menu:onGlobalClick( event )
	if self.isVisible then
		if self:hitTestEvent( event ) then
			self.event:handleEvent( event )
		else
			self.isOpen = false
		end
		return true
	end
end