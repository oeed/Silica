
local SHADOW_RATIO = 2/3
local MAX_SHADOW_SIZE = 3

class "DragView" extends "View" {

    imageObject = false;
    shadowObject = false;
    image = false;
    shadowImage = false;
}

function DragView:initialiseCanvas()
    self:super()

    local width, height, canvas = self.width, self.height, self.canvas

    local shadowObject = canvas:insert( ImageObject( 1, 1, width - SHADOW_RATIO * MAX_SHADOW_SIZE, height - MAX_SHADOW_SIZE, self.shadowImage ) )
    local imageObject = canvas:insert( ImageObject( 1, 1, width - SHADOW_RATIO * MAX_SHADOW_SIZE, height - MAX_SHADOW_SIZE, self.image ) )

    self.shadowObject = shadowObject
    self.imageObject = imageObject
end

function DragView.image:set( image )
    self.image = image
    self.imageObject.image = image
end

function DragView.shadowImage:set( shadowImage )
    self.shadowImage = shadowImage
    self.shadowObject.image = shadowImage
end

function DragView.shadowSize:set( shadowSize )
    self.shadowSize = shadowSize
    local shadowObject = self.shadowObject
    shadowObject.x = 1 + math.floor( SHADOW_RATIO * shadowSize + 0.5 )
    shadowObject.y = 1 + math.floor( shadowSize + 0.5 )
end

function DragView:updateWidth( width )
    self.imageObject.width = width - SHADOW_RATIO * MAX_SHADOW_SIZE
    self.shadowObject.width = width - SHADOW_RATIO * MAX_SHADOW_SIZE
end

function DragView:updateHeight( height )
    self.imageObject.height = height - MAX_SHADOW_SIZE
    self.shadowObject.height = height - MAX_SHADOW_SIZE
end