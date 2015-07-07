
class "Button" extends "View" {

    height = 16; -- the default height
    width = 36;
    text = nil;

    isPressed = false;
    isAutosizing = true;
    font = nil;

    shadowObject = nil;
    backgroundObject = nil;
    textObject = nil;

    needsAutosize = false;

    leftMargin = 0;
    rightMargin = 0;
}

--[[
    @constructor
    @desc Creates a button object and connects the event handlers
]]
function Button:init( ... )
    self.super:init( ... )

    self:event( Event.MOUSE_DOWN, self.onMouseDown )
    self.event:connectGlobal( Event.MOUSE_UP, self.onGlobalMouseUp, EventManager.phase.BEFORE )
    if self.onMouseUp then self:event( Event.MOUSE_UP, self.onMouseUp ) end
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Button:initCanvas()
    self.super:initCanvas()
    local width, height, theme = self.width, self.height, self.theme
    local shadowObject = self.canvas:insert( RoundedRectangle( 2, 2, width - 1, height - 1, theme.shadowColour ) )
    local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, width - 1, height - 1, theme.fillColour, theme.outlineColour, cornerRadius ) )
    local textObject = self.canvas:insert( Text( 1, 5, self.width, 10, self.text ) )

    theme:connect( backgroundObject, "fillColour" )
    theme:connect( backgroundObject, "outlineColour" )
    theme:connect( backgroundObject, "radius", "cornerRadius" )
    theme:connect( shadowObject, "shadowColour" )
    theme:connect( shadowObject, "radius", "cornerRadius" )
    theme:connect( textObject, "textColour" )
    theme:connect( self, "leftMargin" )
    theme:connect( self, "rightMargin" )

    self.backgroundObject = backgroundObject
    self.shadowObject = shadowObject
    self.textObject = textObject

    if not self.font then
        self.font = Font.systemFont
    end
end

function Button:setHeight( height )
    self.super:setHeight( height )
    if self.hasInit then
        self.backgroundObject.height = height - 1
        self.shadowObject.height = height - 1
        self.needsAutosize = true
    end
end

function Button:setWidth( width )
    self.super:setWidth( width )
    if self.hasInit then
        self.backgroundObject.width = width - 1
        self.shadowObject.width = width - 1
        local textObject = self.textObject
        local leftMargin, rightMargin = self.leftMargin, self.rightMargin
        textObject.x = self.isPressed and leftMargin + 2 or leftMargin + 1
        textObject.width = width - leftMargin - rightMargin
    end
end

function Button:setText( text )
    self.text = text
    if self.hasInit then
        self.textObject.text = text
        self.needsAutosize = true
    end
end

--[[
    @instance
    @desc Set the margin on either side of the text
    @param [number] margin -- the space around the text
]]
function Button:setMargin( margin )
    self.leftMargin = margin
    self.rightMargin = margin
end

--[[
    @instance
    @desc Set the margin on the left side of the text
    @param [number] margin -- the space around the left side of the text
]]
function Button:setLeftMargin( leftMargin )
    self.leftMargin = leftMargin
    self.needsAutosize = true
end

--[[
    @instance
    @desc Set the margin on the left side of the text
    @param [number] margin -- the space around the left side of the text
]]
function Button:setRightMargin( rightMargin )
    self.rightMargin = rightMargin
    self.needsAutosize = true
end

function Button:update()
    self.super:update()
    if self.needsAutosize then
        self:autosize()
    end
end

function Button:setFont( font )
    self.font = font
    local textObject = self.textObject
    if textObject then
        self.textObject.font = font
        self.needsAutosize = true
    end
end

function Button:setNeedsAutosize( needsAutosize )
    self.needsAutosize = needsAutosize
end

--[[
    @instance
    @desc Automatically resizes the button, regardless of isAutosizing value, to fit the text
]]
function Button:autosize()
    -- TODO: support self.isAutosizing
    local font, text, textObject = self.font, self.text, self.textObject

    if font and text then
        local fontWidth = font:getWidth( text )
        self.width = fontWidth + self.leftMargin + self.rightMargin

        local fontHeight = font.height
        self.height = fontHeight + 8
    end
    self.needsAutosize = false
end

function Button:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isPressed and "pressed" or "default" ) or "disabled"
end

function Button:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    if self.hasInit then
        self:updateThemeStyle()
    end
end

function Button:setIsPressed( isPressed )
    self.isPressed = isPressed
    if self.hasInit then
        self:updateThemeStyle()
        local backgroundObject = self.backgroundObject
        backgroundObject.x = isPressed and 2 or 1
        backgroundObject.y = isPressed and 2 or 1
        local textObject = self.textObject
        -- textObject.x = isPressed and self.leftMargin + 2 or self.leftMargin + 1
        textObject.y = isPressed and 6 or 5
    end
end

--[[
    @instance
    @desc Fired when the mouse is released anywhere on screen. Removes the pressed appearance.
    @param [Event] event -- the mouse up event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Button:onGlobalMouseUp( event )
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = false
        if self.isEnabled and self:hitTestEvent( event ) then
            -- TODO: remove!
            self.x = math.floor( math.random(1,200 ) )
            return self.event:handleEvent( event )
        end
    end
end

--[[
    @instance
    @desc Fired when the mouse is pushed anywhere on screen. Adds the pressed appearance.
    @param [MouseDownEvent] event -- the mouse down event
    @return [bool] preventPropagation -- prevent anyone else using the event
]]
function Button:onMouseDown( event )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
    end
    return true
end
