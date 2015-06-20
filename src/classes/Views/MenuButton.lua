
class "MenuButton" extends "Button" {

    width = 45;

    menu = nil;

    textColour = Graphics.colours.BLACK;
    backgroundColour = Graphics.colours.WHITE;
    outlineColour = Graphics.colours.LIGHT_GREY;

    arrowColour = Graphics.colours.GREY;

    pressedArrowColour = Graphics.colours.LIGHT_BLUE;

    disabledArrowColour = Graphics.colours.LIGHT_GREY;

    closeArrowObject = nil;
    openArrowObject = nil;
}

--[[
    @constructor
    @desc Creates a MenuButton object and connects the event handlers
]]
function MenuButton:init( ... )
    self.super:init( ... )
    self.menu = {isOpen = false}--Menu()
    
    -- self:event( Event.MOUSE_UP, self.onMouseUp )
end

function MenuButton:setHeight( height )
    self.super:setHeight( height )
    if self.canvas then
        self.closeArrowObject.y = math.ceil( ( self.height - 4 ) / 2 ) + 1
        self.openArrowObject.y = math.ceil( ( self.height - 4 ) / 2 ) + 1
    end
end

function MenuButton:initCanvas()
    self.super:initCanvas()
    local arrowX, arrowY = self.width - 10, math.ceil( ( self.height - 4 ) / 2 ) + 1
    self.arrowX = arrowX
    self.arrowY = arrowY

    local closeArrowObject = Path( arrowX, arrowY, 5, 3, Graphics.colours.TRANSPARENT, 1, 3 )
    closeArrowObject:lineTo( 3, 1 )
    closeArrowObject:lineTo( 5, 3 )
    closeArrowObject:lineTo( 3, 1 )
    closeArrowObject:close()
    closeArrowObject.outlineColour = self.pressedArrowColour
    closeArrowObject.isVisible = false
    self.closeArrowObject = closeArrowObject
    self.canvas:insert( closeArrowObject )

    local openArrowObject = Path( arrowX, arrowY, 5, 3, Graphics.colours.TRANSPARENT, 1, 1 )
    openArrowObject:lineTo( 3, 3 )
    openArrowObject:lineTo( 5, 1 )
    openArrowObject:lineTo( 3, 3 )
    openArrowObject:close()
    openArrowObject.outlineColour = self.arrowColour
    self.openArrowObject = openArrowObject
    self.canvas:insert( openArrowObject )
end

--[[
    @instance
    @desc Update the canvas appearance.
]]
function MenuButton:updateCanvas()
    local backgroundObject = self.backgroundObject
    if self.canvas and backgroundObject then
        local isPressed, isOpen = self.isPressed, self.menu.isOpen
        local isActive = ( isPressed and not isOpen ) or ( not isPressed and isOpen ) -- whether the colouring is that of being
        backgroundObject.fillColour = self.isEnabled and ( isActive and self.pressedBackgroundColour or self.backgroundColour ) or self.disabledBackgroundColour
        backgroundObject.outlineColour = self.isEnabled and ( isActive and Graphics.colours.TRANSPARENT or self.outlineColour ) or self.disabledOutlineColour
        backgroundObject.x = isPressed and 2 or 1
        backgroundObject.y = isPressed and 2 or 1

        local activeArrow = isOpen and self.closeArrowObject or self.openArrowObject
        local inactiveArrow = isOpen and self.openArrowObject or self.closeArrowObject
        activeArrow.isVisible = true
        inactiveArrow.isVisible = false
        activeArrow.x = self.arrowX + ( isPressed and 1 or 0 )
        activeArrow.y = self.arrowY + ( isPressed and 1 or 0 )
        activeArrow.outlineColour = ( isActive and self.pressedArrowColour or self.arrowColour )
    end
end

--[[
    @instance
    @desc Fired when the mouse is released while over the button. Toggles the menu if it hit tests.
    @param [Event] event -- the mouse up event
]]
function MenuButton:onGlobalMouseUp( event )
    if self.isEnabled then
        self.isPressed = false
        if self:hitTestEvent( event ) then
            -- self.menu:toggle()
            self.menu.isOpen = not self.menu.isOpen
            self:updateCanvas()
            return self.event:handleEvent( event )
        else
        end
    end
end