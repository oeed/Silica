
class "Menu" extends "Container" {
	targetX = 1; -- the desired location of the menu. this is the originally set x value, the actual x value can change to prevent overflowing with the screen
	targetY = 1;

	isPressed = false;
    isEnabled = true;
    -- isVisible acts as the boolans of whether the menu is open or closed.

	isSingleShot = false; -- true if the menu should be removed and unlinked when cloesd (as opposed to simply hiding for reuse only)

	topMargin = 3;
	bottomMargin = 5;
	shadowRightMargin = 1;
	shadowTopMargin = 2;

    cornerRadius = 4;

    fillColour = Graphics.colours.WHITE;
    outlineColour = Graphics.colours.LIGHT_GREY;

    pressedFillColour = Graphics.colours.BLUE;
    pressedOutlineColour = nil;

    disabledFillColour = Graphics.colours.WHITE;
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

    self.event:connectGlobal( Event.MOUSE_DOWN, self.onGlobalMouseDown, EventManager.phase.BEFORE )
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Menu:initCanvas()
    local cornerRadius = self.cornerRadius
    self.shadowObject = self.canvas:insert( RoundedRectangle( 1 + self.shadowRightMargin, 1 + self.shadowTopMargin, self.width - 1, self.height - 2, self.shadowColour, nil, cornerRadius ) )
    self.backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width - 1, self.height - 2, self.fillColour, self.outlineColour, cornerRadius ) )
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
	if isVisible then
		self:updateLayout()
	end
end

function Menu:insert( ... )
	self.super:insert( ... )
	self:updateLayout()
end

function Menu:removeChild( ... )
	self.super:removeChild( ... )
	self:updateLayout()
end

--[[
	@instance
	@param [Event] -- the mouse down event
	@desc Closes the menu when somewhere other than the menu is clicked, otherwise handles the event
]]
function Menu:onGlobalMouseDown( event )
	if self.isVisible then
		if self:hitTestEvent( event ) then
			self.event:handleEvent( event )
		else
			self:close()
		end
		return true
	end
end

--[[
	@instance
	@desc Sets the open state of the menu
	@param [boolean] isOpen -- whether the menu should be open
]]
function Menu:setIsOpen( isOpen )
	if isOpen then
		self:open()
	else
		self:close()
	end
end

--[[
	@instance
	@desc The open state of the menu
	@return [boolean] isOpen -- whether the menu is open
]]
function Menu:getIsOpen( isOpen )
	return self.isVisible
end

--[[
	@instance
	@desc Opens the menu if closed, or closes the menu if open
]]
function Menu:toggle()
	self.isOpen = not self.isOpen
end

--[[
	@instance
	@desc Open the menu, hiding it from the screen
]]
function Menu:open()
	self.isVisible = true
end

--[[
	@instance
	@desc Closes the menu, hiding it from the screen
]]
function Menu:close()
	self.isVisible = false
	if self.isSingleShot then

	end
end
