
local file = ...
local output = select( 2, ... )
local height = tonumber( select( 3, ... ) or "" )
local offset = tonumber( select( 4, ... ) or "" ) or 32
local meta = { unpack( { ... }, 5 ) }

if not file then
	print "Usage:"
	print "file - the file to decode"
	print "output - the output file"
	print "height - the height of the font"
	print "offset - the number offset where the charset starts"
	print "... - the metadata formatted 'k=v'"
	return
end

if not fs.exists( file ) then
	print "no such file"
end

for i = 1, #meta do
	local k, v = meta[i]:match "^(.-)=( .+ )$"
	if not k then
		return error( "malformed metadata '" .. meta[i] .. "', no '='" )
	end
	meta[i] = nil
	meta[k] = v
end

local n = 0
local characters = { [0] = {} }

local start = colours.red
local filled = colours.white
local image = paintutils.loadImage( file )

if not height then
	height = #image
end

local row = image[1]
for x = 1, #row do
	if row[x] == start then
		n = n + 1
		characters[n] = {}
	else
		local c = characters[n]
		local col = {}
		for y = 1, #image do
			col[y] = image[y][x] == filled
		end
		c[#c + 1] = col
	end
end

local function writestring( handle, str )
	for i = 1, #str do
		handle.write( str:byte( i ) )
	end
end
local function encodebitlevel( t, l, n )
	local n = 0
	for i = n + 1, n + 8 do
		if t[i] then
			n = n * 2 + ( t[i][l] and 1 or 0 )
		else
			n = n * 2 + 0
		end
	end
	return n
end

local h = fs.open( output, "wb" )
for k, v in pairs( meta ) do
	h.write( 0 )
	writestring( h, k )
	h.write( 0 )
	writestring( h, v )
	h.write( 0 )
end
h.write( 1 )
h.write( height )

for i = 0, #characters do
	local width = #characters[i]
	h.write( i + offset )
	h.write( width )
	for y = 1, height do
		h.write( encodebitlevel( characters[i], y, 0 ) )
		if width > 8 then
			h.write( encodebitlevel( characters[i], y, 8 ) )
		end
	end
end

h.close()
