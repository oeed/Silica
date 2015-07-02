
local floor, ceil = math.floor, math.ceil
local cache = {}

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

local function renderCharacterScaledDown( setPixel, character, _x, _y, cw, ch, scale, colour )
	_x = _x - 1
	_y = _y - 1
	for x = 1, cw do
		for y = 1, ch do
			if character[y] and character[y][x] then
				setPixel( ceil( _x + x * scale - .5 ), ceil( _y + y * scale - .5 ), colour )
			end
		end
	end
end

local no_char_map = {
	width = 5;
	{ true,  true,  true,  true, true };
	{ true, false, false, false, true };
	{ true, false, false, false, true };
	{ true, false, false, false, true };
	{ true, false, false, false, true };
	{ true,  true,  true,  true, true };
}

class "Font" {
	height = 0;
	desiredHeight = 0;
	spacing = 1;

	alignments = {
		LEFT = 0;
		CENTER = 0;
		RIGHT = 0;
		JUSTIFIED = 0;
	};
}

function Font:init( source, desiredHeight, reload )
	local characters, height
	desiredHeight = desiredHeight or 8
	if cache[source] and cache[source][desiredHeight] and not reload then
		characters, height = cache[source][desiredHeight][1], cache[source][desiredHeight][2]
	else
		characters, height = BitmapFont.decodeFile( source )
		cache[source] = cache[source] or {}
		cache[source][desiredHeight] = { characters, height }
	end
	self.characters = characters
	self.height = height
	self.desiredHeight = desiredHeight or height
	self.scale = ( desiredHeight or height ) / height
end

function Font.readMetadata( file )
	local h = fs.open( file, "rb" )
	if h then
		local metadata = {}
		local v = h.read()
		while v == 0 do
			local key, value = readstring( h ), readstring( h )
			metadata[key] = value
			v = h.read()
		end
		h.close()
		return metadata
	end
end

function Font.encodeFile( file, characters, height, metadata )
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
		local bytes
		if metadata.fontType == "vector" then
			bytes = BitmapFont.encodeSet( characters, height )
		else
			bytes = VectorFont.encodeSet( characters, height )
		end
		for _, byte in ipairs( bytes ) do
			h.write( byte )
		end
		h.close()
		return true
	end
end

function Font.decodeFile( file )
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

		local fontType = metadata.fontType
		local characters
		if fontType == "vector" then
			characters = BitmapFont.decodeSet( bytes, height )
		else
			characters = VectorFont.decodeSet( bytes, height )
		end
		return characters, height, metadata
	end
end

--[[
	@static
	@desc Returns a font with the given name
	@param [string] fontName -- the name of the desired font
	@param [number] desiredHeight -- the height of the desired font
	@return [Font] font -- the font
]]
function Font.named( fontName, desiredHeight )
	-- TODO: real font locating
	return Font( "src/fonts/" .. fontName .. ".sfont", desiredHeight )
end

function Font:getHeight()
	return self.height
end

function Font:getWidth( text )
	local width = 0
	for i = 1, #text do
		local scale = self.scale
		local char = text:byte( i )
		local bitmap
		if self.characters[char] then
			bitmap = self.characters[char]
		else
			bitmap = no_char_map
			scale = self.desiredHeight / 6
		end
		width = width + bitmap.width * scale + self.spacing * scale
	end
	return width
end

function Font:render( canvas, text, x, y, colour )
	y = y - 1
	x = x - 1
	text = text == nil and "" or tostring( text )
	local buffer = canvas.buffer
	local width, height = canvas.width, canvas.height
	local TRANSPARENT = Graphics.colours.TRANSPARENT
	local spacing, scale = self.spacing, self.scale
	local function setPixel( x, y, colour )
		if colour ~= TRANSPARENT and x >= 1 and y >= 1 and x <= width and y <= height then
	        buffer[ ( y - 1 ) * width + x ] = colour
	    end
	end
	for i = 1, #text do
		local scale = self.scale
		local char = text:byte( i )
		local bitmap
		if self.characters[char] then
			bitmap = self.characters[char]
		else
			bitmap = no_char_map
			scale = self.desiredHeight / 6
		end
		local cwidth = bitmap.width * scale
		if scale < 1 then
			renderCharacterScaledDown( setPixel, bitmap, x, y, bitmap.width, self.height, scale, colour )
		else
			for _y = 1, self.desiredHeight do
				for _x = 1, ceil( cwidth ) do
					local bx, by = ceil( _x / scale ), ceil( _y / scale )
					local char_is_on = bitmap[by] and bitmap[by][bx]
					if char_is_on then
						setPixel( floor( x + _x + .5 ), floor( y + _y + .5 ), colour ) -- oh no, not this...
					end
				end
			end
		end
		x = x + cwidth + spacing * scale
	end
end
