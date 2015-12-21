
local ucgValues = Image.ucgValues
local iconValues = {
    SIGNATURE = 0xFF2138
}

class "Icon" extends "Image" {

    images = Table;
    iconValues = Enum( Number, iconValues );

}

function Icon:initialise( Table images )
    local maxSize = 0
    local maxWidth, maxWidth
    local pixels
    for i, image in ipairs( images ) do
        local width, height = image.width, image.height
        local size = width * height
        if size > maxSize then
            maxSize = size
            pixels = image.pixels
            maxWidth = width
            maxHeight = height
        end
    end
    self.images = images
    self:super( pixels, maxWidth, maxHeight )
end

function Icon.static:fromIcon( Table bytes )
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

    local images = {}
    if readNumber( 24 ) ~= iconValues.SIGNATURE then
        error( "invalid signature!", 2 )
    end
    local sizeCount = readByte()
    local startIndex = 6 + 4 * sizeCount
    for i = 1, sizeCount do
        local length = readInteger()
        local sizeBytes = {}
        for n = 1, length do
            table.insert( sizeBytes, readByte() )
        end
        local image = Image.static:fromUniversalCompressedGraphics( sizeBytes )
        table.insert( images, image )
        startIndex = startIndex + length + 1 
    end
    return Icon( images )
end
