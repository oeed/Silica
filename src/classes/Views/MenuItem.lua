
local TEXT_MARGIN = 12

class "MenuItem" extends "View" {

	height = 10;
	width = 40;

    isPressed = false;
    isEnabled = true;
	isCanvasHitTested = false;

    keyboardShortcut = nil;
    text = nil;

    font = nil;
    backgroundObject = nil;
}

--[[
	@constructor
	@desc Initialise a menu item instance
	@param [table] properties -- the properties for the view
]]
function MenuItem:init( ... )
	self.super:init( ... )

    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self:event( Event.KEYBOARD_SHORTCUT, self.onKeyboardShortcut )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
    if self.onActivated then self:event( Event.MOUSE_UP, self.onActivated ) end
end

function MenuItem:initCanvas()
    self.super:initCanvas()
    local backgroundObject = self.canvas:insert( Rectangle( 1, 1, self.width, self.height, self.fillColour ) )
    local textObject = self.canvas:insert( Text( 7, 2, self.height, self.width - TEXT_MARGIN, self.text ) )

    self.theme:connect( backgroundObject, 'fillColour' )
    self.theme:connect( textObject, 'textColour' )

    self.backgroundObject = backgroundObject
    self.textObject = textObject

    if not self.font then
        self.font = Font.systemFont
    end
end

function MenuItem:setFont( font )
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

function MenuItem:setText( text )
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

function MenuItem:setWidth( width )
    self.super:setWidth( width )
    if self.hasInit then
        self.backgroundObject.width = width
        self.textObject.width = width - TEXT_MARGIN
    end
end

function MenuItem:setHeight( height )
    self.super:setHeight( height )
    if self.hasInit then
        self.backgroundObject.height = height
    end
end

function MenuItem:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function MenuItem:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    if self.hasInit then
        self:updateThemeStyle()
    end
end

function MenuItem:setIsPressed( isPressed )
    self.isPressed = isPressed
    if self.hasInit then
        self:updateThemeStyle()
    end
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function MenuItem:onGlobalMouseUp( event )
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = false
        if self.isEnabled and self:hitTestEvent( event ) then
            self.parent:close()
            return self.event:handleEvent( event )
        end
        return true
    end
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
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
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function MenuItem:onKeyboardShortcut( event )
    if self.isEnabled then
        local keyboardShortcut = self.keyboardShortcut
        if keyboardShortcut and keyboardShortcut:matchesEvent( event ) then
            self.parent:close()
            if self.onActivated then
                self:onActivated( event )
            end    
            return true
        end
    end
end
