
local TEXT_MARGIN = 12

class "MenuBarItem" extends "View" {

    isPressed = Boolean( false );
    isEnabled = Boolean( true );
	isCanvasHitTested = Boolean( false );
    isFlashing = Boolean( false );
    isActive = Boolean; -- TODO: readonly

    text = String;

    menu = Menu.allowsNil; -- TODO: readonly
    menuName = String;

}

--[[
	@constructor
	@desc Initialise a menu item instance
	@param [table] properties -- the properties for the view
]]
function MenuBarItem:initialise( ... )
	self:super( ... )

    -- local menuName = self.menuName
    -- if not menuName then error( "MenuBarItems must specify the property menuName (the name of the interface file to use).", 0 ) end
    -- menu = Menu.fromInterface( menuName, Menu )
    -- menu.owner = self
    -- menu.isSingleShot = false
    -- menu.isVisible = false
    -- menu.hitTestOwner = true
    -- menu.topMargin = Menu.topMargin + 4
    -- self.menu = menu
    self:event( MenuChangedInterfaceEvent, self.onMenuChanged )
    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
    self:event( ReadyInterfaceEvent, self.onReady )
    self:updateHeight()
end

function MenuBarItem:onReady( ReadyInterfaceEvent event, Event.phases phase  )
    local menuName = self.menuName
    if not menuName then
        MenuNotSpecifiedException( "A MenuBarItem did not specifiy the property 'menuName'. MenuButtons must specify this property as it indicates what inteface file to load the menu from.", 0 )
    end
    local parent = self.parent
    menu = Menu.static:fromInterface( menuName )
    menu.owner = self
    menu.isSingleShot = false
    menu.isVisible = false
    menu.hitTestOwner = true
    local theme = self.theme
    menu.x = self.x + parent.x + theme:value( "menuOffsetX" )
    menu.y = self.y + parent.y + self.height + theme:value( "menuOffsetY" )
    self.menu = menu
    parent.parent:insert( menu )
end

function MenuBarItem:onDraw()
    local width, height, theme, canvas, font = self.width, self.height, self.theme, self.canvas

    canvas:fill( theme:value( "fillColour" ) )
    local leftMargin, rightMargin, topMargin, bottomMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" )
    canvas:fill( theme:value( "textColour" ),  TextMask( leftMargin + 1, topMargin + 1, width - leftMargin - rightMargin, height - topMargin - bottomMargin, self.text, theme:value( "font" ) ) )
end

function MenuBarItem:updateHeight( ThemeChangedInterfaceEvent.allowsNil event, Event.phases.allowsNil phase )
    local theme = self.theme
    self.height = theme:value( "font").height + theme:value( "topMargin") + theme:value( "bottomMargin")
end

function MenuBarItem:updateWidth( ThemeChangedInterfaceEvent.allowsNil event, Event.phases.allowsNil phase )
    local theme = self.theme
    local textWidth = theme:value( "font" ):getWidth( self.text )
    local width = textWidth + theme:value( "leftMargin" ) + theme:value( "rightMargin" )
    self.width = width
    local parent = self.parent
    if parent then
        parent.needsLayoutUpdate = true
    end
end

function MenuBarItem.text:set( text )
    self.text = text
    self:updateWidth()
end

function MenuBarItem.x:set( x )
    self:super( x )
    local menu = self.menu
    if menu then
        menu.x = self.x + self.parent.x + - 1 + self.theme:value( "menuOffsetX" )
    end
end

function MenuBarItem:update( deltaTime )
    self:super( deltaTime )
    local isFlashing = self.isFlashing
    if isFlashing then
        if isFlashing <= 0 then
            self.isFlashing = false
        else
            self.isFlashing = isFlashing - deltaTime
        end
    end
end

--[[
    @desc Make the menu bar item flash for a brief period of time
]]
function MenuBarItem:flash()
    self.isFlashing = 0.2
end

function MenuBarItem.isFlashing:set( isFlashing )
    self.isFlashing = isFlashing
    self:updateThemeStyle()
end

--[[
    @desc Whether the button is pressed or open
    @return [boolean] isActive -- whether the button is active
]]
function MenuBarItem.isActive:get()
    if self.isPressed then
        return true
    end
    local menu = self.menu
    return menu and menu.isOpen or false
end

function MenuBarItem:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or ( self.isActive and "active" or "default" ) ) or "disabled"
end

function MenuBarItem.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function MenuBarItem.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

--[[
    @desc Fired when the mouse is released anywhere on screen. Toggles the menu if it hit tests.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuBarItem:onGlobalMouseUp( MouseUpEvent event, Event.phases phase )
    if self.isEnabled and self.isPressed then
        self.isPressed = false
        if self:hitTestEvent( event ) then
            self.menu:toggle()
            return self.event:handleEvent( event )
        end
    end
end
--[[
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuBarItem:onMouseDown( MouseDownEvent event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end

--[[
    @desc Fired when the owned menu opens or closes
    @param [Event] event -- the menu changed event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuBarItem:onMenuChanged( MenuChangedInterfaceEvent event, Event.phases phase )
    self:updateThemeStyle()
    
    local menu = self.menu
    if menu.isOpen then
        menu.parent:sendToFront( menu )
        menu.parent:sendToFront( self.parent )
    end
    return true
end