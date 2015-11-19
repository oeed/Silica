
local LABEL_MARGIN = 9

class "CharacterPreviewView" extends "View" {
    
    scale = 8;
    character = false;
    characterByte = false; -- the number of the ascii byte of the character
    scaledCharacterObject = false;
    labelObject = false;
    isActive = false;

}

function CharacterPreviewView:initialiseCanvas()
    self:super()
    local width, height, theme, canvas, character, characterByte = self.width, self.height, self.theme, self.canvas, self.character, self.characterByte
    local scaledCharacterObject = canvas:insert( ScaledCharacterObject( 1, 1, character, self.scale ) )
    local labelObject = canvas:insert( Text( 1, 1 + (character and (#character + LABEL_MARGIN) or LABEL_MARGIN), width, Font.systemFont.height, characterByte and string.char( character ) or " ", Font.alignments.CENTER ) )

    theme:connect( scaledCharacterObject, "fillColour", "pixelColour" )
    theme:connect( labelObject, "textColour", "labelColour" )

    self.scaledCharacterObject = scaledCharacterObject
    self.labelObject = labelObject
end

function CharacterPreviewView:updateThemeStyle()
    self.theme.style = self.isActive and "active" or "default"
end

function CharacterPreviewView.characterByte:set( characterByte )
    self.labelObject.text = string.char( characterByte )
    self.character = self.application.document.contents.characters[characterByte]
end

function CharacterPreviewView.isActive:set( isActive )
    self.isActive = isActive
    self:updateThemeStyle()
end

function CharacterPreviewView.scale:set( scale )
    self.scale = scale
    local scaledCharacterObject = self.scaledCharacterObject
    scaledCharacterObject.scale = scale
    self.width = scaledCharacterObject.width
    self.height = scaledCharacterObject.height
end

function CharacterPreviewView.character:set( character )
    self.character = character
    local scaledCharacterObject = self.scaledCharacterObject
    scaledCharacterObject.character = character
    self.width = scaledCharacterObject.width
    self.height = scaledCharacterObject.height + LABEL_MARGIN + self.labelObject.height
end

function CharacterPreviewView:updateHeight( height )
    self.labelObject.y = 1 + self.scaledCharacterObject.height + LABEL_MARGIN
end

function CharacterPreviewView:updateWidth( width )
    self.labelObject.width = width
    log('is: '..width)
end
