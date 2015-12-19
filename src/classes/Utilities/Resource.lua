
-- TODO: thrown an error when there is an identically named file in a resource folder

class "Resource" {

	file = false;
	contents = false;

}

--[[
	@constructor
	@desc Creates a resource class, allowing ease resolving and loading of files
	@param [string] match -- the name of the file without the extension
    @param [Metadata.mimes/table{Metadata.mimes}] mimes -- a mime or table of mimes
	@param [string] category -- the category (folder, such as classes, interfaces) to look in
	@param [boolean] allowDirectories -- default false, whether directories are able to be matched
]]
function Resource:initialise( name, mimes, category, allowDirectories )
	if not name then error( "Resource() requires a file name (without extension)", 5 ) end
	if not mimes then error( "Resource() requires a mime type (e.g. text/lua)", 5 ) end
	if type( mimes ) == "string" then mimes = { mimes } end
	category = category or "resources"
	-- TODO: path tidying
	-- TODO: maybe do this backwards? so you can override files in other libraries
	-- search the resource tables
	local resourceTables = Application.static.resourceTables
	if #resourceTables > 0 then
		for i = 1, #resourceTables do
			local categoryFiles = resourceTables[i][category]
			if categoryFiles then
				local nameCategoryFiles = categoryFiles[name]
				if nameCategoryFiles then
					for i, mime in ipairs( mimes ) do
						local contents = nameCategoryFiles[mime]
						if contents and ( allowDirectories or type( contents ) ~= "table" ) then
							self.contents = contents
							return
						end
					end
				else

				end
			end
		end
	end
	
	local file
	for i, folder in ipairs( Application.static.resourceFolders ) do
		file = folder:find( name, mimes )
		break
	end
	
	self.file = file or false
	if file then
		self.contents = file.contents
	else
		error('File not found: '..name.." of mime "..serialise(mimes))
		-- TODO: error, file not found
	end
end
