
class "ScaleableCanvas" extends "Canvas" {
    
    scaleX = Number( 1 );
    scaleY = Number( 1 );

}

function ScaleableCanvas:initialise( Number width, Number height, View.allowsNil owner )
    self.width = width
    self.height = height
    self.owner = owner
end

--[[
    @desc Creates a mask which covers the filled pixels of the canvas
]]
function ScaleableCanvas.contentMask:get()
    local scaleX, scaleY = self.scaleX, self.scaleY
    local width, height = self.width, self.height
    local scaledWidth, scaledHeight = math.floor( width * scaleX + 0.5 ), math.floor( height * scaleY + 0.5 )
    local widthRatio = width / scaledWidth
    local heightRatio = height / scaledHeight
    local xMin, yMin = math.floor( ( width - scaledWidth ) / 2 ) + 1, math.floor( ( height - scaledHeight ) / 2 )

    local pixels, maskPixels = self.pixels, {}
    local TRANSPARENT = Graphics.colours.TRANSPARENT
    for _x = 1, scaledWidth do
        for _y = 0, scaledHeight - 1 do
            local pixelX, pixelY = math.ceil( _x * widthRatio ), math.ceil( _y * heightRatio )
            local colour = pixels[pixelY * width + pixelX]
            if colour ~= TRANSPARENT then
                maskPixels[( y + yMin + _y ) * width + x + xMin + _x] = true
            end
        end
    end
    return Mask( 1, 1, width, height, maskPixels )
end

--[[
    @desc Clears all pixels from the canvas
]]
function ScaleableCanvas:clear()
    self.pixels = {}
end

--[[
    @desc Hit test the current contents of the canvas
    @return Boolean didHit
]]
function ScaleableCanvas:hitTest( Number x, Number y )
    local scaleX, scaleY = self.scaleX, self.scaleY
    local pixelX, pixelY = x, y
    local width = self.width
    if scaleX ~= 1 or scaleY ~= y then
        local height = self.height
        local scaledWidth, scaledHeight = math.floor( width * scaleX + 0.5 ), math.floor( height * scaleY + 0.5 )
        local widthRatio = width / scaledWidth
        local heightRatio = height / scaledHeight
        pixelX, pixelY = math.ceil( _x * widthRatio ), math.ceil( _y * heightRatio )
    end
    local colour = self.pixels[ ( pixelY - 1 ) * width + pixelX ]
    return colour and colour ~= Graphics.colours.TRANSPARENT
end

--[[
    @desc Draws the canvas to another canvas. If mask is provided the canvas content will be masked (mask pixels will be drawn, pixels not in the mask won't). Mask cordinates are relative to self, not the destination
]]
function ScaleableCanvas:drawTo( Canvas destinationCanvas, Number x, Number y, Mask.allowsNil mask )
    local scaleX, scaleY = self.scaleX, self.scaleY
    local pixels, width, height = self.pixels, self.width, self.height
    local scaledWidth, scaledHeight = math.floor( width * scaleX + 0.5 ), math.floor( height * scaleY + 0.5 )
    local widthRatio = width / scaledWidth
    local heightRatio = height / scaledHeight
    local xMin, yMin = math.floor( ( width - scaledWidth ) / 2 ) + 1, math.floor( ( height - scaledHeight ) / 2 )
    local destinationWidth, destinationHeight, destinationPixels = destinationCanvas.width, destinationCanvas.height, destinationCanvas.pixels
    local TRANSPARENT = Graphics.colours.TRANSPARENT
    local maskX, maskY, maskWidth, maskHeight, maskPixels = mask and mask.x, mask and mask.y, mask and mask.width, mask and mask.height, mask and mask.pixels

    for _x = 1, scaledWidth do
        for _y = 0, scaledHeight - 1 do
            local pixelX, pixelY = math.ceil( _x * widthRatio ), math.ceil( _y * heightRatio )
            local colour = pixels[pixelY * width + pixelX]
            if colour and colour ~= TRANSPARENT then
                local isOkay = true
                if mask then
                    local mx = pixelX - maskX + 1
                    local my = pixelY - maskY + 1
                    if mx >= 1 and mx <= maskWidth and my >= 1 and my <= maskHeight then
                        isOkay = maskPixels[ (my - 1) * maskWidth + mx ]
                    else
                        isOkay = false
                    end
                end
                if isOkay then
                    destinationPixels[( y + yMin + _y ) * destinationWidth + x + xMin + _x] = colour
                end
            end
        end
    end
end
