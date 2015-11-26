

class "MenuItem" extends "View" {

	height = Number( 12 );
	width = Number( 40 );

    isPressed = Boolean( false );
    isEnabled = Boolean( true );
	isCanvasHitTested = Boolean( false );

    shortcut = false;
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
	self:super( ... )

    self:event( MouseDownEvent, self.onMouseDown )
    self:event( KeyboardShortcutEvent, self.onKeyboardShortcut )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
    self:event( ThemeChangedInterfaceEvent, self.updateSize )
    self:updateSize()
end

function MenuItem:onDraw()
    local width, height, theme, canvas, font = self.width, self.height, self.theme, self.canvas, self.font

    canvas:fill( theme:value( "fillColour" ) )

    local leftMargin, rightMargin, topMargin, bottomMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" )
    canvas:fill( theme:value( "shortcutColour" ),  TextMask( leftMargin + 1, topMargin + 1, width - leftMargin - rightMargin, height - topMargin - bottomMargin, self.text, font, Font.alignments.RIGHT ) )
    canvas:fill( theme:value( "textColour" ),  TextMask( leftMargin + 1, topMargin + 1, width - leftMargin - rightMargin, height - topMargin - bottomMargin, self.text, font ) )
end

function MenuItem:updateSize( ThemeChangedInterfaceEvent.allowsNil event, Event.phases.allowsNil phase )
    local theme = self.theme
    self.height = 8 + theme:value( "topMargin") + theme:value( "bottomMargin") -- TODO: loading of fonts from theme
end

-- function MenuItem.shortcut:set( shortcut )
--     if shortcut and #shortcut > 0 then
--         self.keyboardShortcut = KeyboardShortcut.fromString( shortcut ) or false
--     else
--         self.keyboardShortcut = false
--     end
-- end

function MenuItem.font:set( font )
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
    local shortcut = self.shortcut
    local symbols = shortcut and shortcut:symbols()
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

function MenuItem.text:set( text )
    self.text = text
    self:updateText()
end

function MenuItem.shortcut:set( shortcut )
    if type( shortcut ) == "string" and #shortcut > 0 then
        self.shortcut = KeyboardShortcut.static:fromString( shortcut ) or false
    elseif not shortcut then
        self.shortcut = false
    end
    self.shortcut = shortcut
    self:updateText()
end

function MenuItem:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function MenuItem.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function MenuItem.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

--[[
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuItem:onGlobalMouseUp( Event event, Event.phases phase )
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
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuItem:onMouseDown( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end

--[[
    @desc Fired when the a keyboard shortcut is fired
    @param [Event] event -- the keyboard shortcut
    @return [boolean] preventPropagation -- prevent anyone else using the event
]]
function MenuItem:onKeyboardShortcut( Event event, Event.phases phase )
    if self.isEnabled then
        local shortcut = self.shortcut
        if shortcut and shortcut:matchesEvent( event ) then
            local parent = self.parent
            local owner = parent.owner
            if owner:typeOf( MenuBarItem ) then owner:flash() end
            if self.event:handleEvent( ActionInterfaceEvent( self ) ) then return true end
            parent:close()
            return true
        end
    end
end
