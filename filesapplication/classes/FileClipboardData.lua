
class "FileClipboardData" extends "ClipboardData" {
    
    type = "Files:file";
    path = false;

}

function FileClipboardData:initialise( path )
    self.super:initialise()
    self.path = path
end