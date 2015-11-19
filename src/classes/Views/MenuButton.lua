
class "MenuButton" extends "Button" {

    width = 45;

    menu = false;
    menuName = false;

    menuMargin = 5;

    isActive = Boolean; -- TODO: isReadOnly

    closeArrowObject = false;
    openArrowObject = false;
    needsArrowUpdate = false;
}

--[[
    @constructor
    @desc Creates a MenuButton object and connects the event handlers
]]
function MenuButton:initialise( ... )
    self:super( ... )
    local menuName = self.menuName
    if not menuName then error( "MenuButtons must specify the property menuName (the name of the interface file to use).", 0 ) end
    menu = Menu.fromInterface( menuName )
    menu.owner = self
    menu.isSingleShot = false
    menu.isVisible = false
    menu.hitTestOwner = true
    menu.topMargin = Menu.topMargin + 8
    self.menu = menu
    self:event( MenuChangedInterfaceEvent, self.onMenuChanged )
    self:event( ParentChangedInterfaceEvent, self.onParentChanged )
end

function MenuButton:onParentChanged( event )
    local menu = self.menu
    if menu then
        menu = self.menu
        if menu.parent then
            menu.parent:removeChild( menu )
        end
        menu.x = self.x - 5
        menu.y = self.y + 7
        self.parent:insert( menu )
    end
end

function MenuButton:updateX( x )
    local menu = self.menu
    if menu then
        menu.x = self.x - 5
    end
end

function MenuButton:updateY( y )
    local menu = self.menu
    if menu then
        menu.y = self.y + 5
    end
end

function MenuButton:updateHeight( height )
    self.needsArrowUpdate = true
end

function MenuButton:initialiseCanvas()
    self:super()
    local arrowX, arrowY = self.width - 12, math.ceil( ( self.height - 4 ) / 2 )

    local closeArrowObject = Path( 1, 1, 7, 4, 1, 4 )
    closeArrowObject:lineTo( 4, 1 )
    closeArrowObject:lineTo( 7, 4 )
    closeArrowObject:close( false )
    closeArrowObject.isVisible = false
    self.closeArrowObject = closeArrowObject
    self.canvas:insert( closeArrowObject )

    local openArrowObject = Path( 1, 1, 7, 4, 1, 1 )
    openArrowObject:lineTo( 4, 4 )
    openArrowObject:lineTo( 7, 1 )
    openArrowObject:close( false )
    self.openArrowObject = openArrowObject
    self.canvas:insert( openArrowObject )

    self.theme:connect( closeArrowObject, "outlineColour", "arrowColour" )
    self.theme:connect( openArrowObject, "outlineColour", "arrowColour" )
    self.needsArrowUpdate = true
end

--[[
    @instance
    @desc Whether the button is pressed or open
    @return [boolean] isActive -- whether the button is active
]]
function MenuButton.isActive:get()
    return self.isPressed or self.menu.isOpen
end

function MenuButton:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isActive and "pressed" or "default" ) or "disabled"
end

function MenuButton:update()
    self:super()
    if self.needsArrowUpdate then
        self:updateArrows()
    end
end

--[[
    @instance
    @desc Description
    @param [type] arg1 -- description
    @param [type] arg2 -- description
    @param [type] arg3 -- description
    @return [type] returnedValue -- description
]]
function MenuButton:updateArrows()
    local menu = self.menu
    local isOpen = menu and menu.isOpen
    local arrowX, arrowY = self.width - 12, math.ceil( ( self.height - 4 ) / 2 ) + 1
    local activeArrow = isOpen and self.closeArrowObject or self.openArrowObject
    local inactiveArrow = isOpen and self.openArrowObject or self.closeArrowObject
    activeArrow.isVisible = true
    inactiveArrow.isVisible = false
    activeArrow.x = arrowX + ( self.isPressed and 1 or 0 )
    activeArrow.y = arrowY + ( self.isPressed and 1 or 0 )
    self.needsArrowUpdate = false
end

function MenuButton.isPressed:set( isPressed )
    self.super:setIsPressed( isPressed )
    self.needsArrowUpdate = true
end

--[[
    @instance
    @desc Fired when the mouse is released while over the button. Toggles the menu if it hit tests.
    @param [Event] event -- the mouse up event
]]
function MenuButton:onGlobalMouseUp( event )
    if self.isEnabled and self.isPressed then
        self.isPressed = false
        if self:hitTestEvent( event ) then
            self.menu:toggle()
            return self.event:handleEvent( event )
        end
    end
end

--[[
    @instance
    @desc Fired when the owned menu opens or closes
    @param [Event] event -- the menu changed event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuButton:onMenuChanged( event )
    self:updateArrows()
    self:updateThemeStyle()

    if self.menu.isOpen then
        self.parent:sendToFront( self.menu )
        self.parent:sendToFront( self )
    end
    return true
end