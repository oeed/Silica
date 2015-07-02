
class "MenuButton" extends "Button" {

    width = 45;

    menu = nil;

    menuMargin = 5;

    closeArrowObject = nil;
    openArrowObject = nil;
}

--[[
    @constructor
    @desc Creates a MenuButton object and connects the event handlers
]]
function MenuButton:init( ... )
    self.super:init( ... )
    menu = Menu.fromInterface( 'menu' )
    menu.owner = self
    menu.isSingleShot = false
    menu.isVisible = false
    menu.hitTestOwner = true
    menu.topMargin = Menu.topMargin + 6
    self.menu = menu
    self:event( Event.MENU_CHANGED, self.onMenuChanged )
end

function MenuButton:setParent( parent )
    self.parent = parent
    local menu = self.menu
    if menu then
        menu = self.menu
        if menu.parent then
            menu.parent:removeChild( menu )
        end
        menu.x = self.x - 5
        menu.y = self.y + 5
        parent:insert( menu )
    end
end

function MenuButton:setX( x )
    self.super:setX( x )
    local menu = self.menu
    if menu then
        menu.x = self.x - 5
    end
end

function MenuButton:setY( y )
    self.super:setY( y )
    local menu = self.menu
    if menu then
        menu.y = self.y + 5
    end
end

function MenuButton:setHeight( height )
    self.super:setHeight( height )
    if self.hasInit then
        self.closeArrowObject.y = math.ceil( ( self.height - 4 ) / 2 ) + 1
        self.openArrowObject.y = math.ceil( ( self.height - 4 ) / 2 ) + 1
    end
end

function MenuButton:initCanvas()
    self.super:initCanvas()
    local arrowX, arrowY = self.width - 10, math.ceil( ( self.height - 4 ) / 2 ) + 1

    local closeArrowObject = Path( arrowX, arrowY, 5, 3, 1, 3 )
    closeArrowObject:lineTo( 3, 1 )
    closeArrowObject:lineTo( 5, 3 )
    closeArrowObject:close( false )
    closeArrowObject.isVisible = false
    self.closeArrowObject = closeArrowObject
    self.canvas:insert( closeArrowObject )

    local openArrowObject = Path( arrowX, arrowY, 5, 3, 1, 1 )
    openArrowObject:lineTo( 3, 3 )
    openArrowObject:lineTo( 5, 1 )
    openArrowObject:close( false )
    openArrowObject.outlineWidth = 2
    self.openArrowObject = openArrowObject
    self.canvas:insert( openArrowObject )

    self.theme:connect( closeArrowObject, 'outlineColour', 'arrowColour' )
    self.theme:connect( openArrowObject, 'outlineColour', 'arrowColour' )
end

--[[
    @instance
    @desc Whether the button is pressed xor open
    @return [boolean] isActive -- whether the button is active
]]
function MenuButton:getIsActive()
    local isPressed, isOpen = self.isPressed, self.menu.isOpen
    return ( isPressed and not isOpen ) or ( not isPressed and isOpen )
end

function MenuButton:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isActive and "pressed" or "default" ) or "disabled"
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
    local isOpen = self.menu.isOpen
    local arrowX, arrowY = self.width - 10, math.ceil( ( self.height - 4 ) / 2 ) + 1
    local activeArrow = isOpen and self.closeArrowObject or self.openArrowObject
    local inactiveArrow = isOpen and self.openArrowObject or self.closeArrowObject
    activeArrow.isVisible = true
    inactiveArrow.isVisible = false
    activeArrow.x = arrowX + ( self.isPressed and 1 or 0 )
    activeArrow.y = arrowY + ( self.isPressed and 1 or 0 )
end

function MenuButton:setIsPressed( isPressed )
    self.super:setIsPressed( isPressed )
    if self.hasInit then
        self:updateArrows()
    end
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
        self.isPressed = false
    end
end

--[[
    @instance
    @desc Fired when the owned menu opens or closes
    @param [Event] event -- the menu changed event
    @return [bool] preventPropagation -- prevent anyone else using the event
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