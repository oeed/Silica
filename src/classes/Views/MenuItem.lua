

class "MenuItem" extends "View" {

	height = Number( 12 );
	width = Number( 40 );

    isPressed = Boolean( false );
    isEnabled = Boolean( true );
	isCanvasHitTested = Boolean( false );

    shortcut = Any.allowsNil;
    text = String;

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
    self:event( ThemeChangedInterfaceEvent, self.updateHeight )
    self:updateHeight()
end

function MenuItem:onDraw()
    local width, height, theme, canvas, font = self.width, self.height, self.theme, self.canvas

    canvas:fill( theme:value( "fillColour" ) )

    local leftMargin, rightMargin, topMargin, bottomMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" )
    local shortcut = self.shortcut
    if shortcut then
        canvas:fill( theme:value( "shortcutColour" ),  TextMask( leftMargin + 1, topMargin + 1, width - leftMargin - rightMargin, height - topMargin - bottomMargin, shortcut:symbols(), theme:value( "shortcutFont" ), Font.alignments.RIGHT ) )
    end
    canvas:fill( theme:value( "textColour" ),  TextMask( leftMargin + 1, topMargin + 1, width - leftMargin - rightMargin, height - topMargin - bottomMargin, self.text, theme:value( "font" ) ) )
end

function MenuItem:updateHeight( ThemeChangedInterfaceEvent.allowsNil event, Event.phases.allowsNil phase )
    local theme = self.theme
    self.height = 8 + theme:value( "topMargin") + theme:value( "bottomMargin") -- TODO: loading of fonts from theme
end

function MenuItem:updateText()
    local text = self.text
    local shortcut = self.shortcut
    local symbols = shortcut and shortcut:symbols()
    local theme = self.theme
    local textWidth = theme:value( "font" ):getWidth( text )
    local shortcutWidth = symbols and theme:value( "shortcutFont" ):getWidth( symbols ) or 0
    local width = textWidth + theme:value( "leftMargin" ) + theme:value( "rightMargin" ) + ( shortcutWidth ~= 0 and shortcutWidth + theme:value( "shortcutMargin") or 0 )
    self.width = width
    local parent = self.parent
    if parent then
        parent.needsLayoutUpdate = true
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
function MenuItem:onGlobalMouseUp( MouseUpEvent event, Event.phases phase )
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
function MenuItem:onMouseDown( MouseDownEvent event, Event.phases phase )
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
