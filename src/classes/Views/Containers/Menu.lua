
local MENU_OWNER_LEFT_OFFSET = 5
local MENU_OWNER_TOP_OFFSET = 9
local MENU_CONTEXT_OFFSET = 5

class "Menu" extends "Container" {
-- TODO: prevent menu going out of the screen
	targetX = 1; -- the desired location of the menu. this is the originally set x value, the actual x value can change to prevent overflowing with the screen
	targetY = 1;

	isPressed = Boolean( false );
    isEnabled = Boolean( true );
    -- isVisible acts as the boolans of whether the menu is open or closed.

	isSingleShot = Boolean( false ); -- true if the menu should be removed and unlinked when closed (as opposed to simply hiding for reuse only)
	hitTestOwner = false; -- true if clicks should first be sent to the owner if they hit test (and it has one)

	topMargin = 3;
	bottomMargin = 5;
	shadowRightMargin = 1;
	shadowTopMargin = 2;

    cornerRadius = 4;
    isOpen = Boolean;

    shadowObject = false;
    backgroundObject = false;

    width = Number( 40 );
    height = Number( 40 );

	needsLayoutUpdate = false;	
}

--[[
	@constructor
	@desc Initialise a application container instance
	@param [table] properties -- the properties for the view
]]
function Menu:initialise( ... )
	self:super( ... )

    self.event:connectGlobal( MouseDownEvent, self.onGlobalMouseDown, Event.phases.BEFORE )
end

--[[
    @desc Sets up the canvas and it's graphics objects
]]
function Menu:initialiseCanvas()
	self:super()
    local cornerRadius = self.cornerRadius
    local shadowObject = self.canvas:insert( RoundedRectangle( 1 + self.shadowRightMargin, 1 + self.shadowTopMargin, self.width - 1, self.height - 2 ) )
    local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width - 1, self.height - 2 ) )

    self.theme:connect( backgroundObject, "fillColour" )
    self.theme:connect( backgroundObject, "outlineColour" )
    self.theme:connect( backgroundObject, "radius", "cornerRadius" )
    self.theme:connect( shadowObject, "fillColour", "shadowColour" )
    self.theme:connect( shadowObject, "radius", "cornerRadius" )

	self.shadowObject = shadowObject
	self.backgroundObject = backgroundObject
end

--[[
	@desc Show the menu as a context menu (sets it as a single shot)
	@param [View] owner -- the object that invoked the context menu (usually the thing right clicked)
	@param [number] x -- the x coordinate of the click (from event.x)
	@param [number] y -- the y coordinate of the click (from event.y)
]]
function Menu:showContext( owner, x, y )
	self.owner = owner
	self.isSingleShot = true
	self.x = x + owner.x - 1 - MENU_CONTEXT_OFFSET
	self.y = y + owner.y - 1 - MENU_CONTEXT_OFFSET
	if self.parent then
        self.parent:removeChild( self )
    end
	owner.parent:insert( self )
	self.isVisible = true
end

function Menu:updateHeight( height )
    self.backgroundObject.height = height - self.shadowTopMargin
    self.shadowObject.height = height - self.shadowTopMargin
end

function Menu:updateWidth( width )
	local _width = width - self.shadowRightMargin
    self.backgroundObject.width = _width
    self.shadowObject.width = _width

	local height = self.topMargin
	for i, childView in ipairs( self.children ) do
		childView.width = _width
	end
end

--[[
	@desc Updates the location and size of the menu as well as the location and size of the menu items
]]
function Menu:updateLayout()
	local width = self.owner and ( self.owner.menuMargin and self.owner.width + 2 * self.owner.menuMargin or 1 ) or 1
	local height = self.topMargin
	for i, childView in ipairs( self.children ) do
		width = math.max( width, childView.width )
	end
	width = width + (1 - width % 2) -- it must be an odd number (for the separators)
	-- TODO: target position
	
	local height = self.topMargin
	for i, childView in ipairs( self.children ) do
		childView.x = 1
		childView.y = height + 1
		height = height + childView.height
	end
	self.width = width + self.shadowRightMargin
	self.height = height + self.bottomMargin
	self.needsLayoutUpdate = false
end

function Menu:update( deltaTime )
    self:super( deltaTime )
    if self.needsLayoutUpdate then
        self:updateLayout()
    end
end

function Menu.isVisible:set( isVisible )
	self:super( isVisible )
	if isVisible then
		self.needsLayoutUpdate = true
	end
end

function Menu:insert( ... )
	self:super( ... )
	self.needsLayoutUpdate = true
end

function Menu:removeChild( ... )
	self:super( ... )
	self.needsLayoutUpdate = true
end

--[[
	@param [Event] -- the mouse down event
	@desc Closes the menu when somewhere other than the menu is clicked, otherwise handles the event
]]
function Menu:onGlobalMouseDown( Event event, Event.phases phase )
	if self.isVisible then
		if self.hitTestOwner and self.owner and self.owner:hitTestEvent( event ) then
			self.owner.event:handleEvent( event )
			return true
		elseif self:hitTestEvent( event ) then
			self.event:handleEvent( event )
			return true
		else
			self:close()
		end
	end
end

--[[
	@desc Sets the open state of the menu
	@param [boolean] isOpen -- whether the menu should be open
]]
function Menu.isOpen:set( isOpen )
	if isOpen then
		self:open()
	else
		self:close()
	end
end

--[[
	@desc The open state of the menu
]]
function Menu.isOpen:get()
	return self.isVisible
end

--[[
	@desc Opens the menu if closed, or closes the menu if open
]]
function Menu:toggle()
	self.isOpen = not self.isOpen
end

--[[
	@desc Open the menu, hiding it from the screen
]]
function Menu:open()
	self.isVisible = true
	if self.owner then
		self.owner.event:handleEvent( MenuChangedInterfaceEvent( self ) )
	end
end

--[[
	@desc Closes the menu, hiding it from the screen
]]
function Menu:close()
	self.isVisible = false
	if self.owner then
		self.owner.event:handleEvent( MenuChangedInterfaceEvent( self ) )
	end
	if self.isSingleShot then
		self:dispose()
	end
end
