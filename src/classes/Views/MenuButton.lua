
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
    local theme =self.theme
    menu.x = self.x + theme:value( "menuOffsetX" )
    menu.y = self.y + theme:value( "menuOffsetY" )
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

function MenuButton.width:set( width )
    self:super( width )
    local menu = self.menu
    if menu then
        menu.width = width
    end
end

function MenuButton.x:set( x )
    self.x = x
    local menu = self.menu
    if menu then
        menu.x = x + self.theme:value( "menuOffsetX" )
    end
end

function MenuButton.y:set( y )
    self.y = y
    local menu = self.menu
    if menu then
        menu.y = y + self.theme:value( "menuOffsetY" )
    end
end
 
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