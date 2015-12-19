
local TRANSPARENT = Graphics.colours.TRANSPARENT

local hexnums = { [10] = "a", [11] = "b", [12] = "c", [13] = "d", [14] = "e" , [15] = "f" }
local function getHexOf(colour)
    if colour == TRANSPARENT or not colour or not tonumber(colour) then
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
        return TRANSPARENT
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

local mimes = Metadata.mimes
local UCG_SIGNATURE = 0xFF2137
local UCG_VERSION = 1

local IMAGE_MIMES = { mimes.IMAGE, mimes.UCG }

class "Image" {
    
    width = Number;
    height = Number;
    pixels = Table;
    -- resource = false;
    -- file = false;
    contents = false;
    scaledCache = {};

}

function Image:initialise( Table pixels, Number width, Number height )
    local newPixels = {}
    local maxLength = width * height
    for i, pixel in pairs( pixels ) do
        if i > maxLength then
            error( "Image pixels must fit the given size" )
        end
        newPixels[i] = pixel
    end
    self.width = width
    self.height = height
    self.pixels = newPixels
end

function Image.static:blank( width, height )
    local TRANSPARENT = TRANSPARENT
    local pixels = {}
    for i = 1, width * height do
        pixels[i] = TRANSPARENT
    end
    return Image( pixels, width, height )
end

function Image.static:fromPath( path )
    local file = File( path )
    if file.metadata.mime == mimes.UCG then
        return Image.static:fromUniversalCompressedGraphics( file.binaryContents )
    elseif file.metadata.mime == mimes.IMAGE then
        return Image.static:fromPaintFormat( file.contents )
    end
end

function Image.static:fromName( name )
    local resource = Resource( name, IMAGE_MIMES )
    if resource then
        return Image.static:fromResource( resource )
    end
end

function Image.static:fromResource( resource )
    local mime = resource.mime
    if mime == mimes.IMAGE then
        return Image.static:fromPaintFormat( resource.contents )
    elseif mime == mimes.UCG then
        return Image.static:fromUniversalCompressedGraphics( resource.binaryContents )
    end
end

function Image.static:fromPixels( pixels, width, height )
    return Image( pixels, width, height )
end

function Image.static:fromPaintFormat( contents )
    local lines = split( contents, "\n" )
    local pixels = {}
    local width = 0
    for y, line in ipairs( lines ) do
        width = math.max( width, #line )
    end

    for y, line in pairs( lines ) do
        for x = 1, #line do
            pixels[(y - 1) * width + x] = getColourOf( line:sub( x, x ) )
        end
    end

    return Image( pixels, width, #lines )
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

            -- Thanks to ardera for this format! --
-- Format specification: http://puu.sh/lZNtW/270899ae19.pdf --
function Image.static:fromUniversalCompressedGraphics( Table bytes )
    local pointer = 1 -- the index of the byte to read next
    local bitpointer = 1 -- the index of the bit to read next
    
    local bitcache = {}
    local function readByteRaw()
        local b = bytes[pointer]
        pointer = pointer +1
        if b == nil then
            error("unexpected end-of-stream "..pointer, 2)
        end
        return b
    end
    local function readBit()
        if bitcache[1] == nil then
            bitcache = {}
            local byte = readByteRaw()
            bitcache[1] = byte >= 128
            bitcache[2] = (byte % 128) >= 64
            bitcache[3] = (byte % 64) >= 32
            bitcache[4] = (byte % 32) >= 16
            bitcache[5] = (byte % 16) >= 8
            bitcache[6] = (byte % 8) >= 4
            bitcache[7] = (byte % 4) >= 2
            bitcache[8] = (byte % 2) >= 1
            bitpointer = 1
        end
        local b = bitcache[bitpointer]
        bitpointer = bitpointer +1
        if bitpointer > 8 then
            bitcache = {}
            bitpointer = 1
        end
        if b == false then
            return 0
        elseif b == true then
            return 1
        end
        return b
    end
    local function readBits( nbits )
        local t = {}
        for a = 1, nbits do
            t[a] = readBit()
        end
        return t
    end
    local function readNumber( nbits )
        nbits = math.floor( nbits )
        if nbits <= 0 then
            return
        elseif nbits == 1 then
            return readBit()
        else
            local n = 0
            for a = nbits - 1, 0, -1 do
                n = n + readBit() * 2^a
            end
            return n
        end
    end
    local function readByte()
        if bitpointer == 1 then
            return readByteRaw()
        else
            return readBit() * 128 + readBit() * 64 + readBit() * 32 + readBit() * 16 + readBit() * 8 + readBit() * 4 + readBit() * 2 + readBit()
        end
    end
    local function readWord()
        return readByte()  *  256 + readByte()
    end
    local function readInteger()
        return readByte() * 2^24 + readByte() * 2^16 + readByte() * 256 + readByte()
    end

    if readNumber( 24 ) ~= UCG_SIGNATURE then
        error( "invalid signature!", 2 )
    end

    local version = readByte()
    
    local pixels = {}
    local width, height
    if version == 1 then
        width, height = readWord(), readWord()
        local numCodes = readNumber( 5 )
        local codes = {}
        for a = 1, numCodes do
            local colorcode = readNumber( 5 )
            if colorcode == 16 then
                colorcode = 0
            else
                colorcode = 2^colorcode
            end
            local huffcode_len = readNumber( 4 ) +1
            local huffcode = readBits( huffcode_len )
            local nt = codes
            for b = 1, #huffcode-1 do
                nt[huffcode[b]] = nt[huffcode[b]] or {}
                nt = nt[huffcode[b]]
            end
            nt[huffcode[#huffcode]] = colorcode
        end
        
        local hcach, thcach
        for y = 1, height do
            for x = 1, width do
                hcach = codes
                while true do
                    thcach = type(hcach)
                    if thcach == "number" then
                        break
                    elseif thcach == "table" then
                        local b = readBit()
                        hcach = hcach[b]
                    else
                        error("huffman code reader errored: error in huffman tree; node type = "..thcach, 2)
                    end
                end
                pixels[(y - 1) * width + x] = hcach
            end
        end
    else
        error("unsupported version: "..(tostring(version) or "unknown"), 2)
    end

    return Image( pixels, width, height )
end

function Image:toUniversalCompressedGraphics()
    -- first, count colors
    local counter = {}            -- stores the amount of pixels per color (index = color code; value = pixels using it)
    local counter2 = {}           -- same as counter, but keeps the data for efficiency calculation
    local pixels = self.pixels
    local w, h = self.width, self.height
    local numPixels = w * h           -- number of colored pixels
    local numColors = 0           -- number of used colors
    local simpleTree = {}         -- the used huffman tree if numColors is less or equal 2
    for i=1, numPixels do
        local code = pixels[i] or TRANSPARENT
        if not counter[code] then
            if numColors < 2 then
                simpleTree[code]=numColors  -- numColors is 0 or 1 during assignment, building the huffman code
            end
            numColors = numColors +1
        end
        counter[code] = (counter[code] or 0) +1 -- increases the number of pixels colored in this color
        counter2[code] = (counter2[code] or 0) +1
    end
    
    if w > 65535 or h > 65535 then
        error("Image too large: width and height can not be greater than 65535")
    end
    
    local bytes = {}
    local bitcache = {}
    local function writeByteRaw(b)
        bytes[#bytes +1] = b
    end
    local function writeByte(b)
        if #bitcache > 0 then
            writeBit(b >= 128)
            writeBit((b % 128) >= 64)
            writeBit((b % 64) >= 32)
            writeBit((b % 32) >= 16)
            writeBit((b % 16) >= 8)
            writeBit((b % 8) >= 4)
            writeBit((b % 4) >= 2)
            writeBit((b % 2) >= 1)
        else
            writeByteRaw(b)
        end
    end
    local function writeCharRaw(c)
        writeByteRaw(c:byte())
    end
    local function writeChar(c)
        writeByte(c:byte())
    end
    local function writeBit(b)
        if b == true then
            b = 1
        elseif b == false then
            b = 0
        elseif b == nil then
            b = 0
        end
        bitcache[#bitcache +1] = b
        while #bitcache >= 8 do
            writeByteRaw(bitcache[1]*128 + bitcache[2]*64 + bitcache[3]*32 + bitcache[4]*16 + bitcache[5]*8 + bitcache[6]*4 + bitcache[7] * 2 + bitcache[8])
            for a = 1, 8 do
                table.remove(bitcache, 1)
            end
        end
    end
    local function writeBits(bits)
        for a = 1, #bits do
            writeBit(bits[a])
        end
    end
    local function writeNumber(nbits, n)
        nbits = math.floor(nbits)
        if nbits <= 0 then
            return
        elseif nbits == 1 then
            writeBit(n)
            return
        end
        for a = nbits, 1, -1 do
            writeBit((n % 2^a) >= 2^(a-1))
        end
    end
    local function writePalette(hufftree)   -- hufftree is a table: {[color code] = {bit1, bit2, bit3, ...}}
        writeNumber(5, numColors)
        
        for a, b in pairs(hufftree) do
            local ncolor = math.floor(math.log(a)/math.log(2) +0.5)
            if a == 0 then
                writeNumber(5, 16)
            else
                writeNumber(5, ncolor)
            end
            
            local nhuff = #b-1
            writeNumber(4, nhuff)
        
            --write huffman code
            writeBits(b)
        end
    end
    local function finishByte(b)            -- fill up the current unfinished byte with b (0 or 1)
        while #bitcache >= 8 do
            writeByteRaw(bitcache[1]*128 + bitcache[2]*64 + bitcache[3]*32 + bitcache[4]*16 + bitcache[5]*8 + bitcache[6]*4 + bitcache[7] * 2 + bitcache[8])
            for a = 1, 8 do
                table.remove(bitcache, 1)
            end
        end
        if #bitcache > 0 then
            local c = bitcache
            writeByteRaw((c[1] or b)*128 + (c[2] or b)*64 + (c[3] or b)*32 + (c[4] or b)*16 + (c[5] or b)*8 + (c[6] or b)*4 + (c[7] or b)*2 + (c[8] or b))
            for a = 1, 8 do
                table.remove(bitcache, 1)
            end
        end
    end
    local function writeWord(b)
        writeNumber(16, b)
    end
    local function writeInteger(b)
        writeNumber(32, b)
    end
    
    -- Header: 0xFF2137
    -- U is the 21st letter in the alphabet
    -- C is the 3rd letter in the alphabet
    -- G is the 7th letter in the alphabet
    writeByte(0xFF)
    writeByte(0x21)
    writeByte(0x37)
    writeByte(UCG_VERSION)
    
    writeWord(w)
    writeWord(h)
    
    if numColors <= 2 then
        -- less or equal 2 colors, huffman tree algorithm would fail
        writePalette(simpleTree)
    else
        -- generate huffman tree
        
        local codes, low1p, low1v, low2p, low2v, lastkey = {}
            -- the huffman codes,
            -- the lowest probability of a color/node, the value of the color/node,
            -- the 2nd lowest probability of a color/node, the value of the color/node
        
        local numentries
        while true do
            low1p = numPixels+1
            low1v = -1
            low2p = numPixels+2
            low2v = -1
            
            numentries = 0
            for a, b in pairs(counter) do
                if b then
                    if b < low1p then
                        if low1p < low2p then
                            low2p = low1p
                            low2v = low1v
                        end
                        low1p = b
                        low1v = a
                    elseif b < low2p then
                        low2p = b
                        low2v = a
                    end
                    numentries = numentries +1
                end
            end
            
            counter[low1v] = nil
            counter[low2v] = nil
            lastkey = {[0]=low2v, [1]=low1v}
            counter[lastkey] = low1p+low2p
            
            if numentries <= 2 then
                break
            end
        end
        
        local touch;
        function touch(t, huffcode)
            if type(t) == "number" then
                local huffcode2 = {}
                for a = 1, #huffcode do
                    huffcode2[a] = huffcode[a]
                end
                codes[t] = huffcode2
            else
                huffcode[#huffcode +1] = 0
                touch(t[0], huffcode)
                huffcode[#huffcode] = 1
                touch(t[1], huffcode)
                huffcode[#huffcode] = nil
            end
        end
        touch(lastkey, {})
        
        writePalette(codes)
        
        -- replace color codes by huffman codes
        local function writeColor(c)
            writeBits(codes[c])
        end
        
        for i = 1, numPixels do
            local code = pixels[i] or TRANSPARENT
            writeColor(code)
        end
        
        finishByte(0)
        
        return bytes
    end
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
    local TRANSPARENT = TRANSPARENT
    local xLimit, yLimit = math.min( selfWidth, appendingWidth + x - 1 ), math.min( selfHeight, appendingHeight + y - 1 )
    for _y = y, yLimit do
        for _x = x, xLimit do
            local appendingPixel = appendingPixels[(_y - y) * appendingWidth + (_x - x + 1)]
            if appendingPixel and appendingPixel ~= TRANSPARENT then
                selfPixels[(_y - 1) * selfWidth + _x] = appendingPixel
            end
        end
    end
    self.pixels = selfPixels
end
