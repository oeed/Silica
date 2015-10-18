
local TEXT_MARGIN = 12

class "MenuItem" extends "View" {

	height = 12;
	width = 40;

    isPressed = false;
    isEnabled = true;
	isCanvasHitTested = false;

    keyboardShortcut = false;
    text = false;

    font = false;
    backgroundObject = false;
}

--[[
	@constructor
	@desc Initialise a menu item instance
	@param [table] properties -- the properties for the view
]]
function MenuItem:initialise( ... )
	self.super:initialise( ... )

    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self:event( Event.KEYBOARD_SHORTCUT, self.onKeyboardShortcut )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
end

function MenuItem:initialiseCanvas()
    self.super:initialiseCanvas()
    local width, height, canvas = self.width, self.height, self.canvas
    local backgroundObject = canvas:insert( Rectangle( 1, 1, width, height, self.fillColour ) )
    local textObject = canvas:insert( Text( 7, 3, height, width - TEXT_MARGIN, self.text ) )
    local keyboardShortcut = self.keyboardShortcut
    local shortcutObject = canvas:insert( Text( 1, 3, height, width - TEXT_MARGIN, keyboardShortcut and keyboardShortcut:symbols() or "" ) )
    shortcutObject.alignment = Font.alignments.RIGHT
    self.theme:connect( backgroundObject, "fillColour" )
    self.theme:connect( textObject, "textColour" )
    self.theme:connect( shortcutObject, "textColour", "shortcutColour" )

    self.backgroundObject = backgroundObject
    self.textObject = textObject
    self.shortcutObject = shortcutObject

    if not self.font then
        self.font = Font.systemFont
    end
end

function MenuItem:setShortcut( shortcut )
    if shortcut and #shortcut > 0 then
        self.keyboardShortcut = KeyboardShortcut.fromString( shortcut ) or false
    else
        self.keyboardShortcut = false
    end
end

function MenuItem:setFont( font )
    self.font = font
    local textObject = self.textObject
    local shortcutObject = self.shortcutObject
    if textObject then
        textObject.font = font
        shortcutObject.font = font
        self:updateText()
    end
end

function MenuItem:updateText()
    local text = self.text
    local keyboardShortcut = self.keyboardShortcut
    local symbols = keyboardShortcut and keyboardShortcut:symbols()
    local textObject = self.textObject
    local shortcutObject = self.shortcutObject

    if textObject then
        local textWidth = self.font:getWidth( text )
        local shortcutWidth = symbols and self.font:getWidth( symbols ) or 0
        local width = textWidth + TEXT_MARGIN + ( shortcutWidth ~= 0 and shortcutWidth + 8 or 0 )
        self.width = width
        textObject.text = text
        shortcutObject.text = symbols
        local parent = self.parent
        if parent then
            parent.needsLayoutUpdate = true
        end
    end
end

function MenuItem:setText( text )
    self.text = text
    self:updateText()
end

function MenuItem:setKeyboardShortcut( keyboardShortcut )
    self.keyboardShortcut = keyboardShortcut
    self:updateText()
end

function MenuItem:updateWidth( width )
    self.backgroundObject.width = width
    self.textObject.width = width - TEXT_MARGIN
    local shortcutObject = self.shortcutObject
    shortcutObject.width = width - 5
end

function MenuItem:updateHeight( height )
    self.backgroundObject.height = height
end

function MenuItem:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function MenuItem:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function MenuItem:setIsPressed( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuItem:onGlobalMouseUp( event )
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = false
        if self.isEnabled and self:hitTestEvent( event ) then
            if self.event:handleEvent( ActionInterfaceEvent( self ) ) then return true end
            self.parent:close()
            local result = self.event:handleEvent( event )
            return ( result ~= nil and result or true )
        end
        return true
    end
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuItem:onMouseDown( event )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end

--[[
    @instance
    @desc Fired when the a keyboard shortcut is fired
    @param [Event] event -- the keyboard shortcut
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuItem:onKeyboardShortcut( event )
    if self.isEnabled then
        local keyboardShortcut = self.keyboardShortcut
        if keyboardShortcut and keyboardShortcut:matchesEvent( event ) then
            local parent = self.parent
            local owner = parent.owner
            if owner:typeOf( MenuBarItem ) then owner:flash() end
            if self.event:handleEvent( ActionInterfaceEvent( self ) ) then return true end
            parent:close()
            return true
        end
    end
end
