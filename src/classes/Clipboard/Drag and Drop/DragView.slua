
class DragView extends View {

    image = Image;

}

function DragView:onDraw()
    self.canvas:image( self.image, 1, 1, self.width, self.height )
end

function DragView.image:set( image )
    self.image = image
    self.needsDraw = true
end

function DragView.shadowMask:get()
    return self.shadowMask
end

function DragView.shadowMask:set( shadowMask )
    self.shadowMask = shadowMask
    self.needsDraw = true
end
