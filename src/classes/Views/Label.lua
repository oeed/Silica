
class "Label" extends "View" {

    text = String( "" );
    font = Font( Font.static.systemFont );

    isAutosized = Boolean( true );

    needsAutosize = Boolean( true );
	
}

function Label:onDraw()
    self.canvas:fill( self.theme:value( "textColour" ), TextMask( 1, 1, self.width, self.height, self.text, self.font ) )
end

function Label:updateThemeStyle()
    self.theme.style = self.isEnabled and "default" or "disabled"
end

function Label.font:set( font )
    self.font = font
    self.needsAutosize = true
end

function Label.text:set( text )
    self.text = text
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

function Label:autosize()
    if self.isAutosized then
        local font, text = self.font, self.text
        local fontWidth = font:getWidth( text )
        self.width = fontWidth
        self.height = font.height
    end
    self.needsAutosize = false
end
