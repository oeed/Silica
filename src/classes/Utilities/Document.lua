
class "Document" {

	contents = false;
	file = false;
	isBinary = false;
	isModified = false;

}

--[[
	@constructor
	@desc Creates a document from the given path
	@param [string] path -- the path of the document
]]
function Document:initialise( path )
	self.path = path
		
	local file = FileSystemItem( path )

	if file then
		if file:typeOf( IEditableFileSystemItem ) then
			local isBinary = self.isBinary
			if isBinary and not file:typeOf( File ) then
				-- TODO: error, binary cannot be used on non-File FileSystemItems (i.e. Bundles)
			end
			-- TODO: error handling
			local rawContents = self.isBinary and file.binaryContents or file.contents
			if rawContents then
				local contents, err = self:parse( rawContents )
				if contents then
					self.contents = contents
				else
					-- TODO: Error, content empty or corrupt
				end
			else
				-- TODO: Error, content empty or corrupt
			end
		else
			-- TODO: Error, tried to open folder
		end
	else
		self:blank()
	end

	if err then
		self:onError( err )
	end
end

--[[
	@static
	@desc Opens a file and sets it as the application's active document, opening a file dialouge if neccesary. If there was an error the application's active document will not be changed. Simply use Document( path ) if you want to open a document but not set it as active.
	@param [Document] documentClass -- the type of Document class you want to use (it's probably easier to do MyDocument:open)
	@param [string] path -- the path of the document. if empty an open file dialouge will be shown
]]
function Document.open( documentClass, path )
	local function f( path )
		local document = documentClass( path )
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
	@static
	@desc Sets self.contents to whatever is required for a blank document. You will normally want to override this.
]]
function Document:blank()
	self.contents = ""
end

--[[
	@instance
	@desc Parses the read handle. If this returns nil :parse is used with the content of .readAll(). When subclassing you MUST override this or parse! (what's the point of subclassing otherwise?)
	@param [handle] handle -- the handle of the document
	@return contents -- the parsed contents. return false if handle is invalid.
	@return [string] err -- the error message if rawContents is invalid. this is REQUIRED if contents is returned as false, be helpful to your users.
]]
function Document:parseHandle( handle )
end

--[[
	@instance
	@desc Parses the raw string from the document. When subclassing you MUST override this or parseHandle! (what's the point of subclassing otherwise?)
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
	if self.isBinary then
		self.file.binaryContents = self.contents
	else
		self.file.contents = self.contents
	end
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
	if not path then
		-- show save as dialouge
	else
		local file = self.file.new( path )
		if self.isBinary then
			file.binaryContents = self.contents
		else
			file.contents = self.contents
		end
	end
end

--[[
	@instance
	@desc Serialises the document's contents to the handle. When subclassing you MUST override this! (what's the point of subclassing otherwise?)
	@param [handle] handle -- the contents to serialise (don't asume it's equal to self.contents)
	@return okay -- whether serialisation was okay. return nil if the handle isn't used (you want to use :serialise) return false if there was an eror.
	@return [string] err -- the error message if there was an issue in serialising. this is REQUIRED if contents is returned as false, be helpful to your users.
]]
function Document:serialiseHandle( handle )
end

Document:alias( "serializeHandle", "serialieHandle" )

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