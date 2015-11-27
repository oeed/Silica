
class "MenuButton" extends "Button" {

    width = Number( 45 );

    menu = Menu;
    menuName = String;

    menuMargin = 5;

    isActive = Boolean.allowsNil; -- TODO: isReadOnly

}

--[[
    @desc Creates a MenuButton object and connects the event handlers
]]
function MenuButton:initialise( ... )
    self:super( ... )

    self:event( MenuChangedInterfaceEvent, self.onMenuChanged )
    self:event( ParentChangedInterfaceEvent, self.onParentChanged )
    self:event( ReadyInterfaceEvent, self.onReady )

end

function MenuButton:onReady( ReadyInterfaceEvent event, Event.phases phase  )
    local menuName = self.menuName
    if not menuName then
        MenuNotSpecifiedException( "A MenuButton did not specifiy the property 'menuName'. MenuButtons must specify this property as it indicates what inteface file to load the menu from.", 0 )
    end
    menu = Menu.static:fromInterface( menuName )
    menu.owner = self
    menu.isSingleShot = false
    menu.isVisible = false
    menu.hitTestOwner = true
    menu.topMargin = Menu.topMargin + 8
    self.menu = menu
    self.parent:insert( menu )
end

function MenuButton:onParentChanged( Event event, Event.phases phase )
    local menu = self.menu
    if menu then
        if menu.parent then
            menu.parent:removeChild( menu )
        end
        menu.x = self.x - 5
        menu.y = self.y + 7
        self.parent:insert( menu )
    end
end

-- TODO: update menu location
-- function MenuButton:updateX( x )
--     local menu = self.menu
--     if menu then
--         menu.x = self.x - 5
--     end
-- end

-- function MenuButton:updateY( y )
--     local menu = self.menu
--     if menu then
--         menu.y = self.y + 5
--     end
-- end

-- function MenuButton:updateHeight( height )
--     self.needsArrowUpdate = true
-- end

-- function MenuButton:initialiseCanvas()
--     self:super()
--     local arrowX, arrowY = self.width - 12, math.ceil( ( self.height - 4 ) / 2 )

--     local closeArrowObject = Path( 1, 1, 7, 4, 1, 4 )
--     closeArrowObject:lineTo( 4, 1 )
--     closeArrowObject:lineTo( 7, 4 )
--     closeArrowObject:close( false )
--     closeArrowObject.isVisible = false
--     self.closeArrowObject = closeArrowObject
--     self.canvas:insert( closeArrowObject )

--     local openArrowObject = Path( 1, 1, 7, 4, 1, 1 )
--     openArrowObject:lineTo( 4, 4 )
--     openArrowObject:lineTo( 7, 1 )
--     openArrowObject:close( false )
--     self.openArrowObject = openArrowObject
--     self.canvas:insert( openArrowObject )

--     self.theme:connect( closeArrowObject, "outlineColour", "arrowColour" )
--     self.theme:connect( openArrowObject, "outlineColour", "arrowColour" )
--     self.needsArrowUpdate = true
-- end

--[[
    @desc Whether the button is pressed or open
    @return [boolean] isActive -- whether the button is active
]]
function MenuButton.isActive:get()
    if self.isPressed then
        return true
    end
    local menu = self.menu
    return menu and menu.isOpen or false
end

function MenuButton:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or ( self.isActive and "active" or "default" ) ) or "disabled"
end

--[[
    @desc Description
    @param [type] arg1 -- description
    @param [type] arg2 -- description
    @param [type] arg3 -- description
    @return [type] returnedValue -- description
]]
-- function MenuButton:updateArrows()
--     local menu = self.menu
--     local isOpen = menu and menu.isOpen
--     local arrowX, arrowY = self.width - 12, math.ceil( ( self.height - 4 ) / 2 ) + 1
--     local activeArrow = isOpen and self.closeArrowObject or self.openArrowObject
--     local inactiveArrow = isOpen and self.openArrowObject or self.closeArrowObject
--     activeArrow.isVisible = true
--     inactiveArrow.isVisible = false
--     activeArrow.x = arrowX + ( self.isPressed and 1 or 0 )
--     activeArrow.y = arrowY + ( self.isPressed and 1 or 0 )
--     self.needsArrowUpdate = false
-- end

--[[
    @desc Fired when the mouse is released while over the button. Toggles the menu if it hit tests.
    @param [Event] event -- the mouse up event
]]
function MenuButton:onGlobalMouseUp( Event event, Event.phases phase )
    if self.isEnabled and self.isPressed then
        self.isPressed = false
        if self:hitTestEvent( event ) then
            self.menu:toggle()
            return self.event:handleEvent( event )
        end
    end
end

--[[
    @desc Fired when the menu opens or closes
    @param [Event] event -- the menu changed event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuButton:onMenuChanged( Event event, Event.phases phase )
    self:updateThemeStyle()

    if self.menu.isOpen then
        local parent = self.parent
        parent:sendToFront( self.menu )
        parent:sendToFront( self )
    end
    return true
end