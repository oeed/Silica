
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

    isOpen = Boolean;
    owner = View.allowsNil;

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

function Menu:onDraw()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas

    -- background shape
    local roundedRectangle = RoundedRectangleMask( 1, 1, width, height, theme:value( "cornerRadius" ) )
    canvas:fill( theme:value( "fillColour" ), roundedRectangle )
    canvas:outline( theme:value( "outlineColour" ), roundedRectangle, theme:value( "outlineThickness" ) )

    self.shadowSize = theme:value( "shadowSize" )
end

--[[
	@desc Show the menu as a context menu (sets it as a single shot)
	@param [View] owner -- the object that invoked the context menu (usually the thing right clicked)
	@param [number] x -- the x coordinate of the click (from event.x)
	@param [number] y -- the y coordinate of the click (from event.y)
]]
function Menu:showContext( View owner, Number x, Number y )
	self.owner = owner
	self.isSingleShot = true
	self.x = x + owner.x - 1 - MENU_CONTEXT_OFFSET
	self.y = y + owner.y - 1 - MENU_CONTEXT_OFFSET
    local parent = self.parent
	if parent then
        parent:removeChild( self )
    end
	owner.parent:insert( self )
	self.isVisible = true
end

--[[
	@desc Updates the location and size of the menu as well as the location and size of the menu items
]]
function Menu:updateLayout()
    local owner = self.owner
    local ownerTheme = owner and owner.theme
	local width = owner and ( owner.width - 2 * ( ownerTheme:value( "menuOffsetX" ) or 0 ) ) or 1
	local height = self.theme:value( "topMargin" ) + ( ownerTheme and ownerTheme:value( "menuTopPadding" ) or 0 )
	for i, childView in ipairs( self.children ) do
		width = math.max( width, childView.width )
		childView.x = 1
		childView.y = height + 1
		height = height + childView.height
	end
    self.width = width
	self.height = height + self.theme:value( "bottomMargin" )
	self.needsLayoutUpdate = false
end

function Menu.width:set( width )
    self:super( width + (1 - width % 2) )-- it must be an odd number (for the separators)
    for i, childView in ipairs( self.children ) do
        childView.width = width
    end
end

function Menu:update( deltaTime )
    self:super( deltaTime )
    if self.needsLayoutUpdate then
        self:updateLayout()
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
        local owner = self.owner
		if self.hitTestOwner and owner and owner:hitTestEvent( event ) then
			owner.event:handleEvent( event )
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
    local owner = self.owner
	if owner then
		owner.event:handleEvent( MenuChangedInterfaceEvent( self ) )
	end
end

--[[
	@desc Closes the menu, hiding it from the screen
]]
function Menu:close()
	self.isVisible = false
    local owner = self.owner
	if owner then
		owner.event:handleEvent( MenuChangedInterfaceEvent( self ) )
	end
	if self.isSingleShot then
		self:dispose()
	end
end
