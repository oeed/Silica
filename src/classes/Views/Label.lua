
class "Label" extends "View" {

    text = false;
    isAutosizing = Boolean( true );
    font = false;
    textObject = false;
    needsAutosize = false;
	
}

--[[
    @desc Sets up the canvas and it's graphics objects
]]
function Label:initialiseCanvas()
    self:super()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas
    local textObject = canvas:insert( Text( 1, 1, width, height, self.text ) )

    theme:connect( textObject, "textColour" )
    theme:connect( canvas, "fillColour" )
    self.textObject = textObject

    if not self.font then
        self.font = Font.systemFont
    end
end

function Label:updateThemeStyle()
    self.theme.style = self.isEnabled and "default" or "disabled"
end

function Label.font:set( font )
    self.font = font
    local textObject = self.textObject
    if textObject then
        self.textObject.font = font
        self.needsAutosize = true
    end
end

function Label:updateWidth( width )
    self.textObject.width = width
end

function Label.text:set( text )
    self.text = text
    self.textObject.text = text
    self.needsAutosize = true
end

function Label.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self:updateThemeStyle()
end

function Label:update( deltaTime )
    self:super( deltaTime )
    if self.needsAutosize then
        self:autosize()
    end
end

--[[
    @desc Automatically resizes the button, regardless of isAutosizing value, to fit the text
]]
function Label:autosize()
    -- TODO: support self.isAutosizing
    local font, text = self.font, self.text

    if font and text then
        local fontWidth = font:getWidth( text )
        self.width = fontWidth
        self.height = font.height
    end
    self.needsAutosize = false
end
