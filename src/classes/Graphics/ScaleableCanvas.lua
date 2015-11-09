
class "ScaleableCanvas" extends "Canvas" {
    
    scaleX = 1;
    scaleY = 1;

}

function ScaleableCanvas:setScaleX( scaleX )
    if self.scaleX ~= scaleX then
        self.hasChanged = true
        self.scaleX = scaleX
    end
end

function ScaleableCanvas:setScaleY( scaleY )
    if self.scaleY ~= scaleY then
        self.hasChanged = true
        self.scaleY = scaleY
    end
end

function ScaleableCanvas:drawTo( canvas, isShadow )
    local drawsShadow = self.drawsShadow
    if self.isVisible then
        if isShadow or self.hasChanged then
            -- local drawdt = os.clock()
            self:draw( isShadow )
        end
        
        local width = self.width
        local height = self.height
        local fillColour = self.fillColour
        local buffer = self.buffer
        local scaleX = self.scaleX
        local scaleY = self.scaleY
        local _x = self.x - 1
        local _y = self.y
        

        local setPixel
        local TRANSPARENT = Graphics.colours.TRANSPARENT

        local canvasWidth = canvas.width
        local canvasHeight = canvas.height
        local canvasBuffer = canvas.buffer
        if isShadow then
            local shadowColour
            local owner = self.owner
            if owner then
                shadowColour = owner.theme.shadowColour
            else
                shadowColour = Graphics.colours.GREEN
            end
            setPixel = function( x, y, colour )
                if colour ~= TRANSPARENT and x >= 1 and y >= 1 and x <= canvasWidth and y <= canvasHeight then
                    canvasBuffer[ ( y - 1 ) * canvasWidth + x ] = shadowColour
                end
            end
        else
            setPixel = function( x, y, colour )
                if colour ~= TRANSPARENT and x >= 1 and y >= 1 and x <= canvasWidth and y <= canvasHeight then
                    canvasBuffer[ ( y - 1 ) * canvasWidth + x ] = colour
                end
            end
        end

        -- for x = 1, width do
        --     for y = 0, height - 1 do -- just so there's no need for y-1 below
        --         local colour = buffer[y * width + x] or fillColour
        --         local nx, ny = x + _x, y + _y
        --         setPixel( nx, ny, colour )
        --         -- if colour ~= TRANSPARENT and nx >= 1 and ny >= 1 and nx <= canvasWidth and ny <= canvasHeight then
        --         --     canvasBuffer[( ny - 1 ) * canvasWidth + nx] = colour
        --         -- end
        --     end
        -- end

        if scaleX == 1 and scaleY == 1 then
            for x = 1, width do
                for y = 0, height - 1 do -- just so there's no need for y-1 below
                    local colour = buffer[y * width + x] or fillColour
                    local nx, ny = x + _x, y + _y
                    setPixel( nx, ny, colour )
                end
            end
        else
            local scaledWidth, scaledHeight = math.floor( width * scaleX + 0.5 ), math.floor( height * scaleY + 0.5 )
            local ceil = math.ceil
            local widthRatio = width / scaledWidth
            local heightRatio = height / scaledHeight
            local xMin, yMin = math.floor( ( width - scaledWidth ) / 2 ) + 1, math.floor( ( height - scaledHeight ) / 2 )

            for x = 1, scaledWidth do
                for y = 0, scaledHeight - 1 do -- just so there's no need for y-1 below
                    local colour = buffer[ceil( y * heightRatio ) * width + ceil( x * widthRatio )] or TRANSPARENT
                    local nx, ny = x + xMin + _x, y + yMin + _y
                    setPixel( nx, ny, colour )
                end
            end
        end


    end
    return self
end