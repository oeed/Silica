
class "FilesApplication" extends "Application" {
	name = "Files";
	interfaceName = "files";
}

-- For the demo the below code isn't really needed, it's just for debug

--[[
	@constructor
	@desc Initialise the custom application
]]
function FilesApplication:initialise()
	self:super()
	self:event( CharacterEvent, self.onChar )

	-- try( function() 
	-- 	log("one")
	-- 	Exception( "Blah" ):throw()
	-- 	log("two")
	-- end ) {

	-- 	catch( Exception, function()
	-- 		log( "Exception" )
	-- 		log( exception )
	-- 	end );

	-- 	default( function( exception )
	-- 		log( "default" )
	-- 		log( exception )
	-- 	end );

	-- }


	-- local file = File( "/application/test.txt" ) -- subclass of FileSystemItem. you can also do FileSystemItem( “/path” ) and it will return a File or Folder
	-- log( file.contents ) -- does all the fs.open stuff in the getter/setters. so to write you simply set .contents. there is also .binaryContents and .serialisedContents
	-- log( file.path ) -- /src/loadfirst.cfg
	-- log( file.fullName ) -- loadfirst.cfg
	-- log( file.name ) -- loadfirst
	-- log( file.extension ) -- cfg
	-- log( file.icon ) -- Image instance of the file's icon
	-- log( file.sizeString ) -- Image instance of the file's icon

	-- local parent = file.parent -- is :typeOf Folder, subclass of FileSystemItem
	-- -- has the same properties as File, except for contents
	-- local _fs = parent.fs -- a sandboxed fs api (same available for io)
	-- for i, file in ipairs( parent.items ) do -- lists the files and folders in the folder. .files and .folders is also available for just one type
	-- 	-- file is :typeOf FileSystemItem (File or Folder)
	-- 	log( file.fullName )
	-- end

	-- local file = FileSystemItem( "/testfolder/anotherfolder")
	-- local metadata = file.metadata
	-- log(metadata.mime)
	-- file:moveTo(file.parent.parent)
	-- file:copyTo(file.parent.parent)
	-- file:rename("Hai!.txt")
	-- file:delete()
end

--[[
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function FilesApplication:onChar( CharacterEvent event, Event.phases phase )
	if not self:hasFocus() and event.character == '\\' then
		os.reboot()
	elseif event.character == "s" then
		self.container.fileStyle = 3 - self.container.fileStyle
	end
end