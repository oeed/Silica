
class "String" {
	str = false;
}

--[[
	@constructor
	@desc Creates a string object
	@param [string] str -- the string to use
]]
function String:initialise( str )
	self.str = str
end

--[[
	@instance
	@desc Splits a string in to an array with a delimeter
	@param [string] delimeter -- the delimeter
	@return [table] components -- the split string components
]]
function String:split( delimeter )
	local components = {}
	local t = string.format( "([^%s]+)", delimeter )
	self.str:gsub( t, function( t )
		components[#components+1] = t
	end )
	return components
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