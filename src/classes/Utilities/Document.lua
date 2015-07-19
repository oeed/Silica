
class "Document" {
	path = false;
	contents = false;
	readMode = "r";
	writeMode = "w";
	isModified = false;
}

--[[
	@constructor
	@desc Creates a document from the given path
	@param [string] path -- the path of the document
]]
function Document:initialise( path )
	self.path = path

	local rawContents, err = self:read()
	if rawContents then
		local contents, err = self:parse( rawContents )
		if contents then
			self.contents = contents
		end
	end

	if err then
		self:onError( err )
	end
end

--[[
	@static
	@desc Opens a file and sets it as the application's active document, opening a file dialouge if neccesary. If there was an error the application's active document will not be changed. Simply use Document( path ) if you want to open a document but not set it as active.
	@param [string] path -- the path of the document
	@return [Document] document -- the opened document
]]
function Document.open( path )
	local function f( path )
		local document = Document( path )
		if document.contents then
			local oldDocument = Document.application.document
			if oldDocument then
				oldDocument:close( function( isClosed )
					if isClosed then Document.application.document = document end
				end )
			else
				Document.application.document = document
			end
		end
	end

	if path then
		f( path )
	else 
		-- TODO: open file dialouge
		f( "test.txt" )
	end
end

--[[
	@instance
	@desc Reads the raw contents from the path.
	@return [string] rawContents -- the raw contents. return false if there was an error.
	@return [string] err -- the error message if rawContents is false.
]]
function Document:read()
	local path = self.path
	if not fs.exists( path ) then return false, "Document path does not exist." end
	if fs.isDir( path ) then return false, "Document path is a folder." end

	local h = fs.open( path, self.readMode )
	if not h then return false, "Document path unreadable." end
	if not h.readAll then return false, "Invalid read mode (doesn't support readAll)." end

	local rawContents = h.readAll()
	if not rawContents then return false, "Document has nil contents." end
	h.close()

	return rawContents
end

--[[
	@instance
	@desc Parses the raw string from the document. When subclassing you MUST override this! (what's the point of subclassing otherwise?)
	@param [string] rawContents -- the contents of the document
	@return contents -- the parsed contents. return false if rawContents is invalid.
	@return [string] err -- the error message if rawContents is invalid. this is REQUIRED if contents is returned as false, be helpful to your users.
]]
function Document:parse( rawContents )
	return rawContents
end

--[[
	@instance
	@desc Called when there was an error reading or writing the document. By default makes the application show an alert box. Override this if you want to change that.
	@param [string] err -- a description of the error encountered
]]
function Document:onError( err )
	-- TODO: alert window
	error( err )
end

function Document:setContents( contents )
	self.contents = contents
	if self.hasInitialised then
		self.isModified = true
	end
end


--[[
	@instance
	@desc Saves the document's contents to it's path. Calls :write with self.path
	@return [string/nil] err -- the error message if there was an issue with saving, nil otherwise.
]]
function Document:save()
	local err = self:write( self.path )
	if not err then
		self.isModified = false
	end
	return err
end

--[[
	@instance
	@desc Saves the document's contents to the given path.
	@param [string] path -- the path to save to
	@return [string/nil] err -- the error message if there was an issue with saving, nil otherwise.
]]
function Document:saveAs( path )
	return self:write( path )
end

--[[
	@instance
	@desc Serialises the document's contents to it's raw form for saving. When subclassing you MUST override this! (what's the point of subclassing otherwise?)
	@param [string] contents -- the contents to serialise (don't asume it's equal to self.contents)
	@return serialisedContents -- the serialised contents. return false if there was an eror.
	@return [string] err -- the error message if there was an issue in serialising. this is REQUIRED if contents is returned as false, be helpful to your users.
]]
function Document:serialise( contents )
	return contents
end

Document:alias( "serialize", "serialise" )

--[[
	@instance
	@desc Writes the document's serialised contents to the given path.
	@param [string] path -- the path to save to
	@return [string/nil] err -- the error message if there was an issue with saving, nil otherwise.
]]
function Document:write( path )
	if fs.exists( path ) then
		if fs.isReadOnly( path ) then return "Document path is read only." end
		if self.path ~= path and not self:onOverwrite( path ) then return end
		if fs.isDir( path ) then fs.delete( path ) end
	end

	local h = fs.open( path, self.writeMode )
	if not h then return "Document path unwritable." end
	if not h.write then return false, "Invalid read mode (doesn't support write)." end

	local serialisedContents, err = self:serialise( self.contents )
	if not serialisedContents then return err end

	h.write(serialisedContents)
	h.close()
end

--[[
	@instance
	@desc Called when the path being written to already exists (but not when it's the document's own path). By default makes the application show an alert box. Override this if you want to change that.
	@param [string] path -- the path being overwritten
]]
function Document:onOverwrite( path )
	-- TODO: alert window
	error( "Already exists: " .. path )
end

--[[
	@instance
	@desc Tries to close the document, prompting the user (calling :onClose) if it's been modified
	@param [function( [boolean] isClosed )] callback -- the callback to call either after it was closed or the user cancelled. the argument is true if the document was closed, false it's still open
]]
function Document:close( callback )
	if not self.isModified then
		self.application.document = false
		callback( true )
	else
		self:onClose( function( isClosed ) 
			if isClosed then self.application.document = false end
			callback( isClosed )
		end )
	end
end

--[[
	@instance
	@desc Called when the user is asked whether they want to close and save their document. By default makes the application show an alert box. Override this if you want to change that.
	@param [function( [boolean] isClosed )] callback -- the callback to call either after it was closed or the user cancelled. the argument is true if the document was closed, false it's still open
]]
function Document:onClose( callback )
	-- self:save()
	callback( false )
end