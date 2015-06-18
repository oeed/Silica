
class "String" {
	str = nil;
}

--[[
	@constructor
	@desc Creates a string object
	@param [string] str -- the string to use
]]
function String:init( str )
	self.str = str
end

--[[
	@instance
	@desc Splits a string in to an array with a delimeter
	@param [string] delimeter -- the delimeter
	@return [table] splitString -- the split string
]]
function String:split( delimeter )
	local splitString = {}
	local t = string.format( "([^%s]+)", delimeter )
	self.str:gsub( t, function(t)
		splitString[#splitString+1] = t
	end )
	return splitString
end


--[[
	@instance
	@desc The file extension of the string
	@return [table] components -- a table with the directory path, file name and then extension
]]
function String:pathComponents()
	return string.match( self.str, "(.-)([^/]-([^%.]+))$" )
end

-- TODO: more string methods