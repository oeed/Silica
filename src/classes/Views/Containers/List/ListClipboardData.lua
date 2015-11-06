
class "ListClipboardData" extends "ClipboardData" {
    
    type = "Silica:ListItem";
    listItem = false;

}

function ListClipboardData:initialise( listItem )
    self.super:initialise()
    self.listItem = listItem
end