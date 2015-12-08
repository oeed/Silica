
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

local NO_CHAR_MAP = {
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

	alignments = Enum( Number, {
		LEFT = 0;
		CENTER = 1;
		CENTRE = 1;
		RIGHT = 2;
		JUSTIFIED = 3;
	} );

	static = {
		systemFont = Font;
		cache = Table( {} );
	};

}

--[[
	@constructor
	@desc Create a font with the given name
	@param [string] fontName -- the name of the desired font
	@param [number] desiredHeight -- the height of the desired font (i.e what it should scale to)
	@param [boolean] reload -- default is false, whether the cache should be ignored and the font reloaded
]]
function Font:initialise( name, desiredHeight, reload )
	local characters, height
	desiredHeight = desiredHeight or 8
	if cache[name] and cache[name][desiredHeight] and not reload then
		characters, height = cache[name][desiredHeight][1], cache[name][desiredHeight][2]
	else
		local resource = Resource( name, Metadata.mimes.SFONT, "fonts" )
		characters, height = BitmapFont.static:decodeResource( resource )
		cache[name] = cache[name] or {}
		cache[name][desiredHeight] = { characters, height }
	end
	self.characters = characters
	self.height = height
	self.desiredHeight = desiredHeight or height
	self.scale = ( desiredHeight or height ) / height
end

function Font.static:fromName( String name, String.allowsNil alias )
	local cache = self.cache
	local cacheValue = cache[name]
	if cacheValue then return cacheValue end
	local font = Font( name )
	cache[name] = font
	if alias then
		cache[alias] = font
	end
	return font
end

function Font.static:initialisePresets()
	-- TODO: make this come from the theme
	-- Font.systemFont = Font( "Napier" )
	Font.static.systemFont = Font.static:fromName( "Auckland", "systemFont" )
end

function Font.static:readMetadata( file )
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

function Font.static:encodeFile( file, characters, height, metadata )
	local h = fs.open( file, "wb" )
	return Font.encodeHandle( handle, characters, height, metadata)
end

function Font.static:encodeHandle( h, characters, height, metadata )
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
			bytes = VectorFont.static:encodeSet( characters, height )
		else
			bytes = BitmapFont.static:encodeSet( characters, height )
		end
		for _, byte in ipairs( bytes ) do
			h.write( byte )
		end
		h.close()
		return true
	end
end

function Font.static:decodeResource( resource )
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

		return Font.static:decodeHandle( h )
	end
end

function Font.static:decodeFile( file )
	local h = fs.open( file, "rb" )
	return Font.static:decodeHandle( h )
end

function Font.static:decodeHandle( h )
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
			characters = BitmapFont.static:decodeSet( bytes, height )
		else
			characters = VectorFont.static:decodeSet( bytes, height )
		end
		return characters, height, metadata
	end
end

function Font:getWidth( text, withLastSpace )
	if not text then return 0 end
	local width = 0
	local scale, characters, desiredHeight, spacing = self.scale, self.characters, self.desiredHeight, self.spacing
	for i = 1, #text do
		local char = text:byte( i )
		local scale, bitmap = scale -- localise scale so it can be changed if the character isn't defined
		if characters[char] then
			bitmap = characters[char]
		else
			bitmap = NO_CHAR_MAP
			scale = desiredHeight / 6
		end
		width = width + bitmap.width * scale + spacing * scale
	end
	return width - ( withLastSpace and 0 or spacing * scale )
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
			bitmap = NO_CHAR_MAP
			scale = desiredHeight / 6
		end
		width = width + bitmap.width * scale
	end
	return width
end
