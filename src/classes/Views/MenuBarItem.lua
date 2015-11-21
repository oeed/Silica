
local TEXT_MARGIN = 12

class "MenuBarItem" extends "View" {

	height = 12;
    isPressed = false;
    isEnabled = true;
	isCanvasHitTested = false;
    text = false;
    font = false;
    backgroundObject = false;
    menu = false;
    menuName = false;
    isFlashing = false;
    isActive = Boolean; -- TODO: readonly

}

--[[
	@constructor
	@desc Initialise a menu item instance
	@param [table] properties -- the properties for the view
]]
function MenuBarItem:initialise( ... )
	self:super( ... )

    local menuName = self.menuName
    if not menuName then error( "MenuBarItems must specify the property menuName (the name of the interface file to use).", 0 ) end
    menu = Menu.fromInterface( menuName, Menu )
    menu.owner = self
    menu.isSingleShot = false
    menu.isVisible = false
    menu.hitTestOwner = true
    menu.topMargin = Menu.topMargin + 4
    self.menu = menu
    self:event( MenuChangedInterfaceEvent, self.onMenuChanged )
    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
    self:event( ReadyInterfaceEvent, self.onInterfaceReady )
end

function MenuBarItem:onInterfaceReady( Event event, Event.phases phase )
    local menu = self.menu
    if menu then
        menu = self.menu
        if menu.parent then
            menu.parent:removeChild( menu )
        end
        local parent = self.parent
        if parent then
            menu.x = self.x + parent.x - 6
            menu.y = self.y + parent.y + 7
            local parentParent = parent.parent
            if parentParent then
                parentParent:insert( menu )
            end
        end
    end
end

function MenuBarItem:initialiseCanvas()
    self:super()
    local backgroundObject = self.canvas:insert( Rectangle( 1, 1, self.width, self.height, self.fillColour ) )
    local textObject = self.canvas:insert( Text( TEXT_MARGIN / 2 + 1, 3, self.height, self.width - TEXT_MARGIN, self.text ) )

    self.theme:connect( backgroundObject, "fillColour" )
    self.theme:connect( textObject, "textColour" )

    self.backgroundObject = backgroundObject
    self.textObject = textObject

    if not self.font then
        self.font = Font.systemFont
    end
end

function MenuBarItem.font:set( font )
    self.font = font
    local textObject = self.textObject
    if textObject then
        local fontWidth = self.font:getWidth( text )
        self.width = fontWidth + TEXT_MARGIN
        self.textObject.font = font
        local parent = self.parent
        if parent then
            parent.needsLayoutUpdate = true
        end
    end
end

function MenuBarItem.text:set( text )
    self.text = text
    local textObject = self.textObject
    if textObject then
        local fontWidth = self.font:getWidth( text )
        self.width = fontWidth + TEXT_MARGIN
        self.textObject.text = text
        local parent = self.parent
        if parent then
            parent.needsLayoutUpdate = true
        end
    end
end

function MenuBarItem:updateX( x )
    local menu = self.menu
    if menu then
        menu.x = self.x + ( parent and parent.x or 0 ) -- 4
    end
end

function MenuBarItem:updateY( y )
    local menu = self.menu
    if menu then
        menu.y = self.y + ( parent and parent.y or 0 ) + 7
    end
end

function MenuBarItem:updateWidth( width )
    self.backgroundObject.width = width
    self.textObject.width = width - TEXT_MARGIN
end

function MenuBarItem:updateHeight( height )
    self.backgroundObject.height = height
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
    @instance
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
    @instance
    @desc Whether the button is pressed or open
    @return [boolean] isActive -- whether the button is active
]]
function MenuBarItem.isActive:get()
    return self.isPressed or self.isFlashing or self.menu.isOpen
end

function MenuBarItem:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isActive and "pressed" or "default" ) or "disabled"
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
    @instance
    @desc Fired when the mouse is released anywhere on screen. Toggles the menu if it hit tests.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuBarItem:onGlobalMouseUp( Event event, Event.phases phase )
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
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuBarItem:onMouseDown( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end

--[[
    @instance
    @desc Fired when the owned menu opens or closes
    @param [Event] event -- the menu changed event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuBarItem:onMenuChanged( Event event, Event.phases phase )
    self:updateThemeStyle()
    
    local menu = self.menu
    if menu.isOpen then
        menu.parent:sendToFront( menu )
        menu.parent:sendToFront( self.parent )
    end
    return true
end