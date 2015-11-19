
local floor, ceil = math.floor, math.ceil

local function readstring( handle )
	local v = handle.read()
	local s = ""
	while v ~= 0 do
		s = s .. string.char( v )
		v = handle.read()
	end
	return s
end
local function writestring( handle, text )
	for i = 1, #text do
		handle.write( text:byte( i ) )
	end
end

local function bhasbit( n, i )
	if not n then log(debug.traceback()) end
	return floor( n / 2 ^ ( 8 - i ) ) % 2 == 1
end

class "BitmapFont" extends "Font" {
	
}

function BitmapFont.static:decodeCharacter( bytes, width, height )
	local character = {}
	local s = ceil( height / 8 )
	local function hasbit( x, y )
		local byte = ( x - 1 ) * s + ceil( y / 8 )
		local index = y % 8
		if index == 0 then index = 8 end
		local s = ""
		for i = 1, 8 do
			-- log(bytes[byte])
			s = s .. ( bhasbit( bytes[byte], i ) and 1 or 0 )
		end
		return bhasbit( bytes[byte], index )
	end
	character.width = width
	for y = 1, height do
		character[y] = {}
		for x = 1, width do
			character[y][x] = hasbit( x, y )
		end
	end
	return character
end

function BitmapFont.static:encodeCharacter( character, width, height )
	local bytes = {}
	for x = 1, width do
		local byte = {}
		local function close()
			if #byte == 0 then return end
			local n = 0
			for i = 1, #byte do
				n = n * 2 + byte[i]
			end
			byte = {}
			bytes[#bytes + 1] = n
		end
		local function append( b )
			byte[#byte + 1] = b and 1 or 0
			if #byte == 8 then
				close()
			end
		end
		for y = 1, ceil( height / 8 ) * 8 do
			if character[y] then
				append( character[y][x] )
			else
				append()
			end
		end
		close()
	end
	return bytes
end

function BitmapFont.static:encodeSet( characters, height )
	local bytes = {}
	for k, v in pairs( characters ) do
		local width = v.width or ( v[1] and #v[1] or 0 )
		bytes[#bytes + 1] = k
		bytes[#bytes + 1] = width
		for _, byte in ipairs( BitmapFont.encodeCharacter( v, width, height ) ) do
			bytes[#bytes + 1] = byte
		end
	end
	return bytes
end

function BitmapFont.static:decodeSet( bytes, height )
	local hf = ceil( height / 8 )
	local characters = {}
	while bytes[1] do
		local character = bytes[1]
		local width = bytes[2]
		table.remove( bytes, 1 )
		table.remove( bytes, 1 )
		local bitmapcount = hf * width
		characters[character] = BitmapFont.static:decodeCharacter( bytes, width, height )
		for i = 1, bitmapcount do
			table.remove( bytes, 1 )
		end
	end
	return characters
end

function BitmapFont.static:encodeFile( file, characters, height, metadata )
	local h = fs.open( file, "wb" )
	if h then
		for k, v in pairs( metadata or {} ) do
			h.write( 0 )
			writestring( h, tostring( k ) )
			h.write( 0 )
			writestring( h, tostring( v ) )
			h.write( 0 )
		end
		h.write( 1 )
		h.write( height )
		for _, byte in ipairs( BitmapFont.static:encodeSet( characters, height ) ) do
			h.write( byte )
		end
		h.close()
		return true
	end
end

function BitmapFont.static:decodeFile( file )
	local h = fs.open( file, "rb" )
	if h then
		local metadata = {}
		local v = h.read()
		while v == 0 do
			local key, value = readstring( h ), readstring( h )
			metadata[key] = value
			v = h.read()
		end
		local height = h.read()
		local bytes = {}
		for byte in h.read do
			bytes[#bytes + 1] = byte
		end
		local characters = BitmapFont.static:decodeSet( bytes, height )
		return characters, height, metadata
	end
end

function BitmapFont.static:convertFile( input, output, charsetStart, height, metadata )
	local newchar = colours.red
	local filled = colours.white
	local image = paintutils.loadImage( input )
	local n = charsetStart or 0

	local chars = { [n] = {} }
	for x = 1, #image[1] do
		if image[1][x] == newchar then
			n = n + 1
			chars[n] = {}
		else
			for y = 1, #image do
				chars[n][y] = chars[n][y] or {}
				chars[n][y][#chars[n][y] + 1] = image[y][x] == filled
			end
		end
	end

	return BitmapFont.encodeFile( output, chars, height, metadata )
end
