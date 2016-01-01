
class ListClipboardData extends ClipboardData {
    
    type = "Silica:ListItem";
    listItem = false;

}

function ListClipboardData:initialise( listItem )
    self:super()
    self.listItem = listItem
end