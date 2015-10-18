
class "SeparatorView" extends "View" {

    separatorObject = false;

}

function SeparatorView:initialiseCanvas()
    self.super:initialiseCanvas()
    local theme = self.theme
    local separatorObject = self.canvas:insert( Separator( 1, 1, self.width, self.height ) )

    theme:connect( separatorObject, "fillColour", "fillColour" )
    theme:connect( separatorObject, "isDashed" )

    self.separatorObject = separatorObject
end

function SeparatorView:updateWidth( width )
    self.separatorObject.width = width
end

function SeparatorView:updateHeight( height )
    self.separatorObject.height = height
end
