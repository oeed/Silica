
class "Resource" {
	path = false;
}

--[[
	@constructor
	@desc Creates a resource class, allowing ease resolving and loading of files
	@param [string] match -- the string the path should match (i.e. using file name 'default', file name w. extension 'default.stheme' or a partial/full path 'themes/default.stheme')
	@param [string] extension -- default none (nil), the extension the file must have (omit the fullstop)
	@param [boolean] allowDirectories -- default false, whether directories are able to be matched
]]
function Resource:init( match, extension, allowDirectories )
	-- TODO: for now tack the extension on the end of the match until proper extension handling is done.
	match = extension and match .. "%." .. extension or match

	local function search( path )
		if type( path ) == "table" then
			for i, _path in ipairs( path ) do
				local value = search( _path )
				if value then return value end
			end
		else
			local files = fs.list( path )
			for i, v in ipairs( files ) do
				local _path = path .. v
				local isDir = fs.isDir( _path .. '/' )
				-- TODO: match extension and bundles
				if ( allowDirectories or not isDir ) and string.match( _path, match ) then
					return _path
				end

				if isDir then
					local value = search( _path .. '/' )
					if value then return value end
				end
			end
		end
	end

	self.path = search( self.application.resourceDirectories )
end
