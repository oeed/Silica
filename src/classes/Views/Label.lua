
class "Label" extends "View" {

    text = nil;
    isAutosizing = true;
    font = nil;
    textObject = nil;
    needsAutosize = false;
	
}

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function Label:initCanvas()
    self.super:initCanvas()
    local width, height, theme = self.width, self.height, self.theme
    local textObject = self.canvas:insert( Text( 1, 1, self.width, self.height, self.text ) )

    theme:connect( textObject, "textColour" )
    theme:connect( self.canvas, "fillColour" )
    self.textObject = textObject

    if not self.font then
        self.font = Font.systemFont
    end
end

function Label:updateThemeStyle()
    self.theme.style = self.isEnabled and "default" or "disabled"
end

function Label:setFont( font )
    self.font = font
    local textObject = self.textObject
    if textObject then
        self.textObject.font = font
        self.needsAutosize = true
    end
end

function Label:setText( text )
    self.text = text
    self.textObject.text = text
    self.needsAutosize = true
end

function Label:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function Label:update()
    self.super:update()
    if self.needsAutosize then
        self:autosize()
    end
end

--[[
    @instance
    @desc Automatically resizes the button, regardless of isAutosizing value, to fit the text
]]
function Label:autosize()
    -- TODO: support self.isAutosizing
    local font, text, textObject = self.font, self.text, self.textObject

    if font and text then
        local fontWidth = font:getWidth( text )
        self.width = fontWidth
        self.height = font.height
    end
    self.needsAutosize = false
end
