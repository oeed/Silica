
class "Canvas" extends "GraphicsObject" {
    fillColour = Graphics.colours.TRANSPARENT; -- The colour of the Canvas when it clears
    buffer = {};
    children = {};
}

--[[
    @constructor
    @desc Creates a canvas
    @param [number] width -- the width of the canvas
    @param [number] height -- the height of the canvas
]]
-- function Canvas:initialise( width, height )
--     self.buffer = {}
--     self.children = {}
--     self.width = width
--     self.height = height
-- end

--[[
    @instance
    @desc Sets the pixel colour and the given coordinates
    @param [number] x -- the x coordinate of the pixel
    @param [number] y -- the y coordinate of the pixel
    @param [colour] colour -- the colour coordinate of the pixel
]]
function Canvas:setPixel( x, y, colour )
    if colour ~= Graphics.colours.TRANSPARENT and x >= 1 and y >= 1 and x <= self.width and y <= self.height then
        self.buffer[ ( y - 1 ) * self.width + x ] = colour
    end
    return self
end

--[[
    @instance
    @desc Gets the pixel colour and the given coordinates
    @param [number] x -- the x coordinate of the pixel
    @param [number] y -- the y coordinate of the pixel
    @return [colour] colour -- the colour of the pixel
]]
function Canvas:getPixel( x, y )
    return self.buffer[ ( y - 1 ) * self.width + x ] or self.fillColour
end

--[[
    @instance
    @desc Clears the buffer
    @return self
]]
function Canvas:clear()
    self.buffer = {}
    return self
end

--[[
    @instance
    @desc Adds a shader to screen area
    @param [Canvas.shader] shader -- the shader to use
    @param [number] x -- default 1, the x coordinate of the area
    @param [number] y -- default 1, the y coordinate of the area
    @param [number] width -- default canvas width, the width of the area
    @param [number] height -- default canvas height, the height of the area
    @return self
]]
function Canvas:map( shader, x, y, width, height )
    local changes = {}
    for _x = x or 1, ( x or 1 ) + ( width or self.width ) - 1 do
        for _y = y or 1, ( x or 1 ) + ( height or self.height ) - 1 do
            local colour = shader( _x, _y, self:getPixel( _x, _y ) )
            if colour and colour ~= 0 then
                changes[#changes + 1] = { _x, _y, colour }
            end
        end
    end
    local buffer = self.buffer
    local width, height = self.width, self.height
    local TRANSPARENT = Graphics.colours.TRANSPARENT
    local function setPixel( x, y, colour )
        if colour ~= TRANSPARENT and x >= 1 and y >= 1 and x <= width and y <= height then
            buffer[ ( y - 1 ) * width + x ] = colour
        end
        return self
    end
    for i = 1, #changes do
        setPixel( unpack( changes[i] ) )
    end
    return self
end

--[[
    @instance
    @desc Adds a graphics object to the canvas
    @param [GraphicsObject] graphicsObject -- the graphics object to add
    @return self
]]
function Canvas:insert( graphicsObject )
    graphicsObject = graphicsObject
    self.hasChanged = true
    if not graphicsObject then
        logtraceback()
    end
    if graphicsObject.parent then
        graphicsObject.parent:remove( graphicsObject )
    end
    graphicsObject.raw.parent = self
    self.children[#self.children + 1] = graphicsObject
    return graphicsObject
end

--[[
    @instance
    @desc Removes a graphics object from the canvas
    @param [GraphicsObject] graphicsObject -- the graphics object to remove
    @return self
]]
function Canvas:remove( graphicsObject )
    local c = false
    for i = #self.children, 1, -1 do
        if self.children[i] == graphicsObject then
            table.remove( self.children, i )
            graphicsObject.raw.parent = false
            c = true
        end
    end
    if c then
        self.hasChanged = true
    end
    return graphicsObject
end

--[[
    @instance
    @desc Clears the buffer then draws the objects of the canvas
    @return self
]]
function Canvas:draw()
    if self.isVisible then
        self.buffer = {}
        local children = self.children
        for i = 1, #children do
            children[i]:drawTo( self )
        end
        self.hasChanged = false
    end
    return self
end

--[[
    @instance
    @desc Draws the canvas to another canvas
    @param [Canvas] canvas -- the canvas to draw to
    @return self
]]
function Canvas:drawTo( canvas )
    if self.isVisible then
        if self.hasChanged then
            -- local drawdt = os.clock()
            self:draw()
            -- log( tostring( self ) .. 'is rerendering dt ' .. os.clock() - drawdt )
        end
        
        local width = self.width
        local height = self.height
        local fillColour = self.fillColour
        local buffer = self.buffer
        local _x = self.x - 1
        local _y = self.y
        

        local start = os.clock()
        -- log( tostring( self ) .. 'is drawing to parent at ' .. os.clock() )

        local canvasWidth = canvas.width
        local canvasHeight = canvas.height
        local canvasBuffer = canvas.buffer
        local TRANSPARENT = Graphics.colours.TRANSPARENT
        for x = 1, width do
            for y = 0, height - 1 do -- just so there's no need for y-1 below
                local colour = buffer[y * width + x] or fillColour
                local nx, ny = x + _x, y + _y
                if colour ~= TRANSPARENT and nx >= 1 and ny >= 1 and nx <= canvasWidth and ny <= canvasHeight then
                    canvasBuffer[( ny - 1 ) * canvasWidth + nx] = colour
                end
            end
        end

        -- log( tostring( self ) .. 'is done drawing to parent dt ' .. os.clock() - start )

    end
    return self
end

--[[
    @instance
    @desc Hit tests the canvas' buffer to see if the colour is set (return false if transparent)
    @param [number] x -- the x coordinate to hit test
    @param [number] y -- the y coordinate to hit test
    @return [boolean] didHit -- whether the colour was set/not transparent
]]
function Canvas:hitTest( x, y )
    return self:getPixel( x, y ) ~= 0
end
