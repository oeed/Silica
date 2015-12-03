
local alignments = Font.alignments

local ceil, floor = math.ceil, math.floor

local NO_CHAR_MAP = {
    width = 5;
    { true,  true,  true,  true, true };
    { true, false, false, false, true };
    { true, false, false, false, true };
    { true, false, false, false, true };
    { true, false, false, false, true };
    { true,  true,  true,  true, true };
}

class "TextMask" extends "Mask" {

    

}

function TextMask:initialise( Number x, Number y, Number.allowsNil width, Number.allowsNil height, String text, Font( Font.static.systemFont ) font, Font.alignments( Font.alignments.LEFT ) alignment )
    local fontWidth = font:getWidth( text )
    local width = width or fontWidth
    local fontHeight = font.height
    local height = height or fontHeight
    local pixels = {}
    local scale, characters, desiredHeight, spacing = font.scale, font.characters, font.desiredHeight, font.spacing

    while fontWidth > width and #text > 1 do
        text = text:sub( 1, #text - 1 )
        fontWidth = font:getWidth( text .. "..." )
        hasEllipsis = true
    end

    if hasEllipsis then
        text = text .. "..."
    end

    local xShift = 0
    if alignment == alignments.LEFT then
    elseif alignment == alignments.CENTRE then
        xShift = math.floor( (width - fontWidth ) / 2 )
    elseif alignment == alignments.RIGHT then
        xShift = width - fontWidth
    end

    for i = 1, #text do
        local char = text:byte( i )
        local bitmap
        if characters[char] then
            bitmap = characters[char]
        else
            bitmap = NO_CHAR_MAP
            scale = desiredHeight / 6
        end

        local bitmapWidth = bitmap.width
        local characterWidth = floor( bitmapWidth * scale + 0.5 )
        if scale < 1 then
            -- a scaled down character
            for _x = 1, bitmapWidth do
                for _y = 1, fontHeight do
                    if character[_y] and character[_y][_x] then
                        pixels[ ( ceil( _y * scale - 0.5 ) - 1 ) * width + ceil( ( _x + xShift ) * scale - 0.5 ) ] = true
                    end
                end
            end
        else
            -- TODO: why is ceil used not rounding for font scaling?
            for _y = 1, desiredHeight do
                local bitmapRow = bitmap[ceil( _y / scale )]
                if bitmapRow then
                    for _x = 1, characterWidth do
                        if bitmapRow[ceil( _x / scale )] then
                            pixels[ ( _y - 1 ) * width + ( _x + xShift ) ] = true
                        end
                    end
                end
            end
        end
        xShift = xShift + characterWidth + spacing * scale
    end
   
    self:super( x, y, width, height, pixels )
end