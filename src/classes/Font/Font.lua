
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
	characters = false;
	scale = false;
	systemFont = false;

	alignments = {
		LEFT = 0;
		CENTER = 1;
		CENTRE = 1;
		RIGHT = 2;
		JUSTIFIED = 3;
	};
}

--[[
	@constructor
	@desc Create a font with the given name
	@param [string] fontName -- the name of the desired font
	@param [number] desiredHeight -- the height of the desired font
	@param [boolean] reload -- default is false, whether the cache should be ignored and the font reloaded
]]
function Font:initialise( name, desiredHeight, reload )
	local characters, height
	desiredHeight = desiredHeight or 8
	if cache[name] and cache[name][desiredHeight] and not reload then
		characters, height = cache[name][desiredHeight][1], cache[name][desiredHeight][2]
	else
		local resource = Resource( name, Metadata.mimes.SFONT, "fonts" )
		characters, height = BitmapFont.decodeResource( resource )
		cache[name] = cache[name] or {}
		cache[name][desiredHeight] = { characters, height }
	end
	self.characters = characters
	self.height = height
	self.desiredHeight = desiredHeight or height
	self.scale = ( desiredHeight or height ) / height
end

function Font.initialisePresets()
	-- TODO: make this come from the theme
	-- Font.systemFont = Font( "Napier" )
	Font.systemFont = Font( "Auckland" )
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
	return Font.encodeHandle( handle, characters, height, metadata)
end

function Font.encodeHandle( h, characters, height, metadata )
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
			bytes = VectorFont.encodeSet( characters, height )
		else
			bytes = BitmapFont.encodeSet( characters, height )
		end
		for _, byte in ipairs( bytes ) do
			h.write( byte )
		end
		h.close()
		return true
	end
end

function Font.decodeResource( resource )
	-- log(resource)
	local contents = resource.contents
	-- log(resource.path)
	-- log(contents)
	if contents then
		local i = 1
		local contentsLen = #contents
		local b = string.byte
		local sub = string.sub
		local h = {}

		function h.read()
			if i <= contentsLen then
				local value = b( sub( contents, i, i ) )
				i = i + 1
				return value
			end
		end

		return Font.decodeHandle( h )
	end
end

function Font.decodeFile( file )
	local h = fs.open( file, "rb" )
	return Font.decodeHandle( h )
end

function Font.decodeHandle( h )
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

		if fontType == "bitmap" then
			characters = BitmapFont.decodeSet( bytes, height )
		else
			characters = VectorFont.decodeSet( bytes, height )
		end
		return characters, height, metadata
	end
end

function Font:getHeight()
	return self.height
end

function Font:getWidth( text )
	if not text then return 0 end
	local width = 0
	local scale, characters, desiredHeight, spacing = self.scale, self.characters, self.desiredHeight, self.spacing
	for i = 1, #text do
		local char = text:byte( i )
		local scale, bitmap = scale -- localise scale so it can be changed if the character isn't defined
		if characters[char] then
			bitmap = characters[char]
		else
			bitmap = no_char_map
			scale = desiredHeight / 6
		end
		width = width + bitmap.width * scale + spacing * scale
	end
	return width - spacing
end

function Font:getRawWidth( text )
	if not text then return 0 end
	local width = 0
	local scale, characters, desiredHeight, spacing = self.scale, self.characters, self.desiredHeight, self.spacing
	for i = 1, #text do
		local char = text:byte( i )
		local scale, bitmap = scale -- localise scale so it can be changed if the character isn't defined
		if characters[char] then
			bitmap = characters[char]
		else
			bitmap = no_char_map
			scale = desiredHeight / 6
		end
		width = width + bitmap.width * scale
	end
	return width
end

function Font:render( canvas, text, x, y, cropWidth, cropHeight, colour )
	y = y - 1
	x = x - 1
	text = text == nil and "" or tostring( text )
	local buffer = canvas.buffer
	local width, height, _height = canvas.width, canvas.height, self.height
	local cropX, cropY = math.min( x + cropWidth, width ), math.min( y + cropHeight, height )
	local TRANSPARENT = Graphics.colours.TRANSPARENT
	local scale, characters, desiredHeight, spacing = self.scale, self.characters, self.desiredHeight, self.spacing
	local function setPixel( x, y, colour )
		if colour ~= TRANSPARENT and x >= 1 and y >= 1 and x <= cropX and y <= cropY then
	        buffer[ ( y - 1 ) * width + x ] = colour
	    end
	end
	for i = 1, #text do
		local char = text:byte( i )
		local bitmap
		if characters[char] then
			bitmap = characters[char]
		else
			bitmap = no_char_map
			scale = desiredHeight / 6
		end
		local cwidth = bitmap.width * scale
		if scale < 1 then
			renderCharacterScaledDown( setPixel, bitmap, x, y, bitmap.width, _height, scale, colour )
		else
			for _y = 1, desiredHeight do
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
