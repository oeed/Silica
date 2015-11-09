
class "FilesApplicationContainer" extends "ApplicationContainer" {
    
    filesContainer = InterfaceOutlet();
    fileStyle = 1;

}

function FilesApplicationContainer:initialise( ... )
	self.super:initialise( ... )
	self:event( ReadyInterfaceEvent, self.onReady)
end

function FilesApplicationContainer:initialiseCanvas()
    self.super:initialiseCanvas()
    -- local path = Path( 20, 50, 7, 7, 1, 4 )
    -- path:lineTo( 4, 1 )
    -- path:lineTo( 4, 3 )
    -- path:lineTo( 7, 3 )
    -- path:lineTo( 7, 5 )
    -- path:lineTo( 4, 5 )
    -- path:lineTo( 4, 7 )
    -- path:close()
    -- log(textutils.serialise(path:getSerialisedPath()))
    -- path.fillColour = colours.grey
    -- self.canvas:insert(path)
end

function FilesApplicationContainer:setFileStyle( fileStyle )
    self.fileStyle = fileStyle
    -- for i, fileItem in ipairs( self.filesContainer.children ) do
    --     fileItem.style = fileStyle
    -- end
end

function FilesApplicationContainer:onReady( event )
end