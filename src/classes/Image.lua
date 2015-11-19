
local hexnums = { [10] = "a", [11] = "b", [12] = "c", [13] = "d", [14] = "e" , [15] = "f" }
local function getHexOf(colour)
    if colour == Graphics.colours.TRANSPARENT or not colour or not tonumber(colour) then
        return " "
    end
    local value = math.log(colour)/math.log(2)
    if value > 9 then
            value = hexnums[value]
    end
    return value
end

local function getColourOf(hex)
    if hex == ' ' then
        return Graphics.colours.TRANSPARENT
    end
    local value = tonumber(hex, 16)
    if not value then return nil end
    value = math.pow(2,value)
    return value
end

local function split(a,e)
    local t,e=e or":",{}
    local t=string.format("([^%s]+)",t)
    a:gsub(t,function(t)e[#e+1]=t end)
    return e
end

local IMAGE_MIMES = { "image/paint" }

class "Image" {
    
    width = false;
    height = false;
    pixels = false;
    -- resource = false;
    -- file = false;
    contents = false;
    scaledCache = {};

}

function Image.static:blank( width, height )
    local image = Image()
    image.width = width
    image.height = height
    local TRANSPARENT = Graphics.colours.TRANSPARENT
    local pixels = {}
    for x = 1, width do
        local pixelsX = {}
        for y = 1, height do
            pixelsX[y] = TRANSPARENT
        end
        pixels[x] = pixelsX
    end
    image.pixels = pixels
    return image
end

function Image.static:fromPath( path )
    local file = File( path )
    if file then
        local image = Image()
        image.contents = file.contents
        image:loadPaintFormat()
        return image
    end
end

function Image.static:fromName( name )
    log("name "..name)
    local resource = Resource( name, IMAGE_MIMES )
    if resource then
        return Image.fromResource( resource )
    end
end

function Image.static:fromResource( resource )
    local image = Image()
    image.contents = resource.contents
    image:loadPaintFormat()
    return image
end

function Image.static:fromPixels( pixels, width, height )
    local image = Image()
    image.width = width
    image.height = height
    image:loadPixels( pixels )
    return image
end

function Image:loadPixels( pixels )
    local newPixels = {}

    for x, column in ipairs( pixels ) do
        local pixelsX = {}
        for y, colour in ipairs( column ) do
            pixelsX[y] = colour
        end
        newPixels[x] = pixelsX
    end

    self.pixels = newPixels
end

function Image:loadPaintFormat()
    local lines = split( self.contents, "\n" )
    local pixels = {}

    for y, line in ipairs( lines ) do
        for x = 1, #line do
            if not pixels[x] then
                pixels[x] = {}
            end
            pixels[x][y] = getColourOf( line:sub( x, x ) )
        end
    end

    self.width = #pixels
    self.height = #lines
    self.pixels = pixels
end

function Image:toPaintFormat()
    local pixels = self.pixels
    local paintFormat = ""
    local width, height = self.width, self.height

    for y = 1, height do
        for x = 1, width do
            paintFormat = paintFormat .. getHexOf( pixels[x][y] )
        end
        paintFormat = paintFormat .. "\n"
    end

    return paintFormat
end

function Image.pixels:set( pixels )
    self.pixels = pixels
    self.scaledCache = {
        [self.width .. ":" .. self.height] = pixels;
    }
end

--[[
    @instance
    @desc Returns the image's pixels scaled to the desired dimensions. These are cached so performance should not be a huge concern.
    @param [number] scaledWidth
    @param [number] scaledHeight
    @return [table] pixels -- the scaled pixels
]]
function Image:getScaledPixels( scaledWidth, scaledHeight )
    scaledWidth = math.floor( scaledWidth + 0.5 )
    scaledHeight = math.floor( scaledHeight + 0.5 )

    local scaledCache = self.scaledCache

    if scaledCache[scaledWidth .. ":" .. scaledHeight] then
        return scaledCache[scaledWidth .. ":" .. scaledHeight]
    end

    local width, height, pixels = self.width, self.height, self.pixels

    local scaledPixels = {}
    local widthRatio = width / scaledWidth
    local heightRatio = height / scaledHeight
    local ceil = math.ceil

    for x = 1, scaledWidth do
        local pixelsX = pixels[ ceil( x * widthRatio ) ]
        if not pixelsX then break end
        local scaledX = {}
        for y = 1, scaledHeight do
            scaledX[y] = pixelsX[ ceil( y * heightRatio ) ]
        end
        scaledPixels[x] = scaledX
    end

    scaledCache[scaledWidth .. ":" .. scaledHeight] = scaledPixels

    return scaledPixels
end

--[[
    @instance
    @desc Renders the given image on top of the self image at the given position
    @param [Image] appendingImage -- description
    @param [number] x
    @param [number] y
]]
function Image:appendImage( appendingImage, x, y )
    local appendingPixels = appendingImage.pixels
    local pixels = self.pixels
    for _x, column in ipairs( appendingPixels ) do
        local pixelsX = pixels[x + _x - 1]
        if not pixelsX then break end
        for _y, colour in ipairs( column ) do
            if pixelsX[y + _y - 1] then
                pixelsX[y + _y - 1] = colour
            end
        end
    end
    self.pixels = pixels
end
