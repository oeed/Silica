
class "Canvas" {
    
    x = Number;
    y = Number;
    width = Number;
    height = Number;
    owner = View.allowsNil;
    mask = Mask.allowsNil; -- the canvas' rectangle
    contentMask = Mask.allowsNil; -- the canvas' content

    pixels = Table( {} );

}

function Canvas:initialise( Number x, Number y, Number width, Number height, View.allowsNil owner )
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.owner = owner
end

--[[
    @desc Creates a mask which covers the entire canvas
]]
function Canvas.mask:get()
    return RectangleMask( 1, 1, self.width, self.height )
end

--[[
    @desc Fills an area in the given mask with the given colour, defaulting to the entire canvas
]]
function Canvas:fill( Graphics.colours colour, Mask( self.mask ) mask )
    local pixels, width, height = self.pixels, self.width, self.height
    local maskX, maskY, maskWidth, maskHeight = mask.x, mask.y, mask.width, mask.height
    for index, isFilled in pairs( mask.pixels ) do
        if isFilled then
            local x = (index - 1) % maskWidth + maskX
            local y = math.floor( ( index - 1) / maskWidth ) + maskY
            if x >= 1 and x <= width and y >= 1 and y <= height then
                pixels[( y - 1 ) * width + x] = colour
            end
        end
    end
end

--[[
    @desc Draws an outline around the given mask, defaulting to the canvas' content mask
]]
function Canvas:outline( Graphics.colours colour, Number( 1 ) thickness, Mask( self.contentMask ) mask )

end

--[[
    @desc Draws the canvas to another canvas at the specified location
    @return Any returnedValue
]]

--[[
    @desc Draws the canvas to another canvas
]]
function Canvas:drawTo( Number x, Number y, Canvas destinationCanvas, Mask.allowsNil mask )
    local width, height = self.width, self.height
    local destinationWidth, destinationHeight, destinationPixels = destinationCanvas.width, destinationCanvas.height, destinationCanvas.pixels
    local TRANSPARENT = Graphics.colours.TRANSPARENT
    for index, colour in pairs( self.pixels ) do
        if colour and colour ~= TRANSPARENT then
            local _x = (index - 1) % width + x
            local _y = math.floor( ( index - 1) / width ) + y
            if _x >= 1 and _x <= destinationWidth and _y >= 1 and _y <= destinationHeight then
                destinationPixels[( _y - 1 ) * destinationWidth + _x] = colour
            end
        end
    end
end

--[[
    @desc Draws an image to the canvas, scaling the image if needed
]]
function Canvas:image( Number x, Number y, Image image, Number( image.width ) width, Number( image.height ) height )
end

--[[
    @desc Draws a shadow mask to the parent's canvas
]]
function Canvas:drawShadow( Number x, Number y, Number shadowSize, Graphics.colours shadowColour, Mask shadowMask )
end
