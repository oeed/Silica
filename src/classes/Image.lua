
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
    for i = 1, width * height do
        pixels[i] = TRANSPARENT
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

    for i, pixel in pairs( pixels ) do
        newPixels[i] = pixel
    end

    self.pixels = newPixels
end

function Image:loadPaintFormat()
    local lines = split( self.contents, "\n" )
    local pixels = {}
    local width = 0
    for y, line in ipairs( lines ) do
        width = math.max( width, #line )
    end

    for y, line in ipairs( lines ) do
        for x = 1, #line do
            pixels[(y - 1) * width + x] = getColourOf( line:sub( x, x ) )
        end
    end

    self.width = width
    self.height = #lines
    self.pixels = pixels
end

function Image:toPaintFormat()
    local pixels = self.pixels
    local paintFormat = ""
    local width, height = self.width, self.height

    for y = 1, height do
        for x = 1, width do
            paintFormat = paintFormat .. getHexOf( pixels[(y - 1) * width + x] )
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
        for y = 1, scaledHeight do
            scaledPixels[(y - 1) * scaledWidth + x] = pixels[ ceil( y * heightRatio - 1 ) * width + ceil( x * widthRatio ) ]
        end
    end

    scaledCache[scaledWidth .. ":" .. scaledHeight] = scaledPixels

    return scaledPixels
end

--[[
    @desc Renders the given image on top of the self image at the given position
    @param [Image] appendingImage -- description
    @param [number] x
    @param [number] y
]]
function Image:appendImage( appendingImage, x, y )
    local appendingWidth, appendingHeight, appendingPixels = appendingImage.width, appendingImage.height, appendingImage.pixels
    local selfWidth, selfHeight, selfPixels = self.width, self.height, self.pixels
    local TRANSPARENT = Graphics.colours.TRANSPARENT
    local xLimit, yLimit = math.min( selfWidth, appendingWidth + x - 1 ), math.min( selfHeight, appendingHeight + y - 1 )
    for _x = x, xLimit do
        for _y = y, yLimit do
            local appendingPixel = appendingPixels[(_y - y) * appendingHeight + (_x - x + 1)]
            if appendingPixel and appendingPixel ~= TRANSPARENT then
                selfPixels[(_y - 1) * selfWidth + _x] = appendingPixel
            end
        end
    end
    self.pixels = pixels
end
