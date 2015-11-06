
class "Resource" {
	path = false;
	contents = false;
}

--[[
	@constructor
	@desc Creates a resource class, allowing ease resolving and loading of files
	@param [string] match -- the exact file name of the file
	@param [string] category -- the category (folder, such as classes, interfaces) to look in
	@param [boolean] allowDirectories -- default false, whether directories are able to be matched
]]
function Resource:initialise( name, category, allowDirectories )
	category = category or "resources"
	-- TODO: path tidying
	-- TODO: maybe do this backwards? so you can override files in other libraries
	
	-- search the resource tables
	local resourceTables = self.application.resourceTables
	if #resourceTables > 0 then
		for i = 1, #resourceTables do
			local categoryFiles = resourceTables[i][category]
			if categoryFiles then
				local contents = categoryFiles[name]
				if contents and ( allowDirectories or type( contents ) ~= "table" ) then
					self.contents = contents
					return
				end
			end
		end
	end

	-- otherwise search the resource directories
	local function searchDirectories( path )
		if type( path ) == "table" then
			for i, _path in ipairs( path ) do
				local value = searchDirectories( _path .. "/" .. category )
				if value then return value end
			end
		elseif fs.exists( path ) and fs.isDir( path ) then
			local files = fs.list( path )
			for i, v in ipairs( files ) do
				local _path = path .. "/" .. v
				local isDir = fs.isDir( _path )

				-- TODO: bundles
				if ( allowDirectories or not isDir ) and name == v then
					return _path
				end

				if isDir then
					local value = searchDirectories( _path .. '/' )
					if value then return value end
				end
			end
		end
	end

	local path = searchDirectories( self.application.resourceDirectories )
	self.path = path or false

	if path and not fs.isDir( path ) then
		local f = fs.open( path, "r" )
		if f then
			self.contents = f.readAll()
			f.close()
		end
	end
end
