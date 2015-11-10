
class "ImageObject" extends "GraphicsObject" {

    image = false;

}

function ImageObject:initialise( x, y, width, height, image )
    self.super:initialise( x, y, width, height )

    if image then
        self.image = image
    end
end

function ImageObject:setImage( image )
    self.hasChanged = true
    if type( image ) == "string" then
        self.image = Image.fromName( image ) or false
    else
        self.image = image
    end
end

function ImageObject:getFill()
    if self.fill then return self.fill end

    local fill, image = {}, self.image
    if image then
        local pixels, TRANSPARENT = image:getScaledPixels( self.width, self.height ), Graphics.colours.TRANSPARENT

        for x, column in ipairs( pixels ) do
            local fillX = {}
            for y, pixel in ipairs( column ) do
                fillX[y] = pixel ~= TRANSPARENT
            end
            fill[x] = fillX
        end
    end

    return fill
end

function ImageObject:drawTo( canvas, isShadow )
	if self.isVisible and ( not isShadow or ( isShadow and self.drawsShadow ) ) then
        local image = self.image
        if not image then return end

        local fillColour = self.fillColour
        local outlineColour = self.outlineColour
        local _x = self.x - 1
        local _y = self.y - 1

        local buffer = canvas.buffer
        local width, height = canvas.width, canvas.height
        local TRANSPARENT = Graphics.colours.TRANSPARENT
        local function setPixel( x, y, colour )
            if colour ~= TRANSPARENT and x >= 1 and y >= 1 and x <= width and y <= height then
                buffer[ ( y - 1 ) * width + x ] = colour
            end
            return canvas
        end

        local fill = {}
        local pixels = image:getScaledPixels( self.width, self.height )
        for x, column in ipairs( pixels ) do
            local fillX = {}
            for y, pixel in ipairs( column ) do
                fillX[y] = pixel ~= TRANSPARENT
            end
            fill[x] = fillX
        end

        local outline
        if self.outlineColour ~= Graphics.colours.TRANSPARENT then
            outline = self:getOutline( fill )
        end

        for x, column in ipairs( pixels ) do
            for y, pixel in ipairs( column ) do
                if (not outline or not outlineX or not outlineX[y]) then
                    setPixel( _x + x, _y + y, pixel )
                end
            end
        end

        if outline then
            for x, row in pairs( outline ) do
                for y, _ in pairs( row ) do
                    setPixel( _x + x, _y + y, outlineColour )
                end
            end
        end
    end
    
    return self
end
