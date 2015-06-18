
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
-- function Canvas:init( width, height )
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
    if colour == Graphics.colours.TRANSPARENT then return self end
    self.buffer[ ( y - 1 ) * self.width + x ] = colour
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
            local colour = shader( _x, _y, self:getPixel( x, y ) )
            if colour and colour ~= 0 then
                changes[#changes + 1] = { _x, _y, colour }
            end
        end
    end
    for i = 1, #changes do
        self:setPixel( unpack( changes[i] ) )
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
    graphicsObject = graphicsObject.instance or graphicsObject
    self.hasChanged = true
    if graphicsObject.parent then
        graphicsObject.parent:remove( graphicsObject )
    end
    graphicsObject.parent = self
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
    graphicsObject = graphicsObject.instance or graphicsObject
    local c = false
    for i = #self.children, 1, -1 do
        if self.children[i] == graphicsObject then
            graphicsObject.parent = nil
            table.remove( self.children, i )
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
    self.buffer = {}
    for i = 1, #self.children do
        self.children[i]:drawTo( self )
    end
    self.hasChanged = false
    return self
end

--[[
    @instance
    @desc Draws the canvas to another canvas
    @param [Canvas] canvas -- the canvas to draw to
    @return self
]]
function Canvas:drawTo( canvas )
    if self.hasChanged then
        self:draw()
    end
    for x = 1, self.width do
        for y = 1, self.height do
            canvas:setPixel( self.x + x - 1, self.y + y - 1, self:getPixel( x, y ) )
        end
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
