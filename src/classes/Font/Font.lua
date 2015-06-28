
local cache = {}

class "Font" {
	height = 0;
	desiredHeight = 0;
	spacing = 1;
}

function Font:init( source, desiredHeight, reload )
	local characters, height
	desiredHeight = desiredHeight or 8
	if cache[source] and cache[source][desiredHeight] and not reload then
		characters, height = cache[source][desiredHeight][1], cache[source][desiredHeight][2]
	else
		characters, height = self.decodeFile( source )
		cache[source] = cache[source] or {}
		cache[source][desiredHeight] = { characters, height }
	end
	self.characters = characters
	self.height = height
	self.desiredHeight = desiredHeight or height
	self.scale = ( desiredHeight or height ) / height
end
